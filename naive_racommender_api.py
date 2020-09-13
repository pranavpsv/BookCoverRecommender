from fastapi import FastAPI, File, UploadFile
from google.cloud import vision
import requests
import io
from google.cloud.vision import types
import pandas as pd
import torch
from tqdm import tqdm
from sentence_transformers import SentenceTransformer, util
import numpy as np

df = pd.read_parquet("embeddings_df.parquet") # Parquet file with books dataset and its description embedding

model = SentenceTransformer('bert-base-nli-stsb-mean-tokens') # BERT model fine tuned on STS dataset

def detect_text(uploaded_file):
    client = vision.ImageAnnotatorClient()

    # Loads the image into memory
    content = uploaded_file.file.read()
    image = types.Image(content=content)

    response = client.text_detection(image=image)
    texts = response.text_annotations
    """
        vertices = (['({},{})'.format(vertex.x, vertex.y)
                    for vertex in text.bounding_poly.vertices])

        print('bounds: {}'.format(','.join(vertices)))
    """
    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))
    return texts[0].description


app = FastAPI()

@app.get("/")
def hello():
  return {"HEllo world": 1}
# https://www.googleapis.com/books/v1/volumes?q=isbn:0521618762
# This is an example above of how to use google books api for info

@app.post("/recommendBooks")
def create_upload_file(file: UploadFile = File(...)):
    print("reached")
    ocr_book_backpage = detect_text(file)
    ocr_book_backpage_lines = ocr_book_backpage.split("\n") # split book backpage info by newlines

    ocr_book_description = ""
    ocr_book_isbn_line = None
    for line in ocr_book_backpage_lines:
        if ("ISBN" in line):
            ocr_book_isbn_line = line
            break
        else:
            ocr_book_description += (line + "\n")

    ocr_book_embeddings  = model.encode(ocr_book_description, convert_to_tensor=True)
    # TODO: Account for ISBN-10 and ISBN-13 if needed
    ocr_isbn = ocr_book_isbn_line.split(" ")[1].replace("-", "") # TODO: Write logic in more elegant way
    print(f"ISBN line: {ocr_book_isbn_line}")
    print(f"The book's ISBN: {ocr_isbn}")

    print(f"The Book's description: {ocr_book_description}")

    cos = torch.nn.CosineSimilarity(dim=1, eps=1e-6)

    cosine_similarity_values = []

    for i in tqdm(range(df.shape[0])):
        try:
            cosine_similarity = cos(torch.Tensor(ocr_book_embeddings).unsqueeze(0), torch.Tensor(df.iloc[i].embeddings).unsqueeze(0)).item()
            if cosine_similarity >= 0.95: # Removing duplicate entries of original book using a threshold of 0.95 cosine similarity
                cosine_similarity = 0
            cosine_similarity_values.append(cosine_similarity)
        except Exception as e:
            cosine_similarity_values.append(0)

    next_best_item = df.iloc[np.argmax(cosine_similarity_values)]
    decreasing_cosine_similarity_scores = np.argsort(cosine_similarity_values)[::-1]
    next_best_items = df.iloc[decreasing_cosine_similarity_scores[:3]]
    response = {}
    link = f"https://www.googleapis.com/books/v1/volumes?q=isbn:{ocr_isbn}"
    print(ocr_isbn)
    res = requests.get(link).json()
    image_link = res["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"]
    original_title = res["items"][0]["volumeInfo"]["title"]
    response["original_item"] = {"book_isbn": ocr_isbn, "title": original_title, "image": image_link, "book_description": (ocr_book_description[:400] + "...")}
    response["recommended_items"] = []
    print("ORGINAL ITEM: \n")
    # print(original_item.title) # Get isbn google books api access
    print(ocr_book_description)
    print("MOST SIMILAR ITEM(S): \n")
    print(next_best_item.title)
    print(next_best_item.description)
    print(f"{max(cosine_similarity_values)} is the cosine similarity")
    i = 0
    for next_best_item in next_best_items.itertuples():
        print(next_best_item.title)
        print(cosine_similarity_values[decreasing_cosine_similarity_scores[i]])
        print(next_best_item.description)
        recommended_item = {"title": next_best_item.title, "description": (next_best_item.description[:400] + "..."), "isbn": next_best_item.isbn13,
                "cos_similarity": cosine_similarity_values[decreasing_cosine_similarity_scores[i]]
                }
        google_books_json = requests.get(f"https://www.googleapis.com/books/v1/volumes?q=={next_best_item.title} book").json()

        recommended_item["image"] = google_books_json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"]
        response["recommended_items"].append(recommended_item)
        i += 1

    return response
