from fastapi import FastAPI, File, UploadFile
import os
import pickle
import requests
import io
import pandas as pd
import torch
from tqdm import tqdm
from sentence_transformers import SentenceTransformer, util
import numpy as np
import faiss

df = pd.read_parquet("embeddings_df.parquet") # Parquet file with books dataset and its description embedding
df.drop_duplicates(inplace=True, subset=["description"])
top_k_hits= 3

df.dropna(inplace=True, subset=["description"] )

model = SentenceTransformer('bert-base-nli-stsb-mean-tokens') # BERT model fine tuned on STS dataset

embedding_size = 768 # Size of embeddings of each book description
top_k = 3 # Number of similarity matchings to output
embedding_cache_path = "data.pkl"
num_clusters = 200


# Define FAISS
quantizer = faiss.IndexFlatIP(embedding_size)
index = faiss.IndexIVFFlat(quantizer, embedding_size, num_clusters, faiss.METRIC_INNER_PRODUCT)

index.nprobe = 3


if not os.path.exists(embedding_cache_path):

    descriptions = []
    titles = []
    isbn13= []
    isbn = []

    for row in df.itertuples():
        descriptions.append(row.description)
        titles.append(row.title)
        isbn13.append(row.isbn13)
        isbn.append(row.isbn)


    print("Encoding")
    corpus_embeddings = model.encode(descriptions, show_progress_bar=True, convert_to_numpy=True,)

    with open(embedding_cache_path, "wb") as f:
        pickle.dump({ "title": titles, "isbn": isbn, "isbn13": isbn13, "description": descriptions, "embeddings": corpus_embeddings}, f)

    print(type(corpus_embeddings))
    df["description"] = descriptions
    df["embeddings"] = corpus_embeddings.tolist()
    print(df["embeddings"].shape)
    df.to_parquet("random.parquet")

else:
    with open(embedding_cache_path, "rb") as f:
        cache_data = pickle.load(f)
        isbn13 = cache_data["isbn13"]
        titles = cache_data["title"]
        descriptions = cache_data["description"]
        corpus_embeddings = cache_data["embeddings"]
        print(corpus_embeddings.shape)


#corpus_embeddings = corpus_embeddings / np.linalg.norm(corpus_embeddings, axis=1)[:, None]
faiss.normalize_L2(corpus_embeddings)
index.train(corpus_embeddings)

index.add(corpus_embeddings)

app = FastAPI()

@app.get("/")
def hello():
  return {"Hello world": 1}
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

    ocr_book_embeddings  = model.encode(ocr_book_description, )
    # TODO: Account for ISBN-10 and ISBN-13 if needed


    cr_isbn = ocr_book_isbn_line.split(" ")[1].replace("-", "") # TODO: Write logic in more elegant way
    print(f"ISBN line: {ocr_book_isbn_line}")
    print(f"The book's ISBN: {ocr_isbn}")

    print(f"The Book's description: {ocr_book_description}")

    faiss.normalize_L2(ocr_book_embeddings)

    # Search in FAISS. It returns a matrix with distances and corpus ids.
    distances, corpus_ids = index.search(ocr_book_embeddings, top_k_hits)

    # We extract corpus ids and scores for the first query
    hits = [{'corpus_id': id, 'score': score} for id, score in zip(corpus_ids[0], distances[0])]
    hits = sorted(hits, key=lambda x: x['score'], reverse=True)

    print("Input description:", ocr_book_description)

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
    for hit in hits[0:top_k_hits]:
        print(titles[hit["corpus_id"]])
        print("\t{:.3f}\t{}".format(hit['score'], descriptions[hit['corpus_id']]))
        recommended_item = {"title": titles[hit["corpus_ids"]], "description":  (descriptions[hit["corpus_ids"]][:400] + "..."),
                "isbn": isbn13[hit["corpus_ids"]]
                }

        google_books_json = requests.get(f"https://www.googleapis.com/books/v1/volumes?q=={recommended_item['title']} book").json()

        recommended_item["image"] = google_books_json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"]
        response["recommended_items"].append(recommended_item)

    return response
