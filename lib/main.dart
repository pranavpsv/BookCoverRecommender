// import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_speed_dial_material_design/flutter_speed_dial_material_design.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

void main() {
  runApp(MyApp());
}

void getHttp() async {
  try {
    Response response = await Dio()
        .get("https://www.googleapis.com/books/v1/volumes?q=isbn:0521618762");
    print(response);
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(57, 62, 70, 0.1),
      100: Color.fromRGBO(57, 62, 70, .2),
      200: Color.fromRGBO(57, 62, 70, .3),
      300: Color.fromRGBO(57, 62, 70, .4),
      400: Color.fromRGBO(57, 62, 70, .5),
      500: Color.fromRGBO(57, 62, 70, .6),
      600: Color.fromRGBO(57, 62, 70, .7),
      700: Color.fromRGBO(57, 62, 70, .8),
      800: Color.fromRGBO(57, 62, 70, .9),
      900: Color.fromRGBO(57, 62, 70, 1),
    };

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: Color(0xff393e46),
        primarySwatch: MaterialColor(0xff393e46, color),
        primaryColor: Color(0xFF393e46),
        // scaffoldBackgroundColor: const Color(0xFF393b44),
        // scaffoldBackgroundColor: const Color(0xFF00adb5),
        scaffoldBackgroundColor: const Color(0xFFf4f4f4),
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool imagePicked = false;
  bool recommendedBookReceived = false;
  String recommendedTitle1 = "";
  String recommendedTitle2 = "";
  String recommendedTitle3 = "";
  String recommendedURL =
      "https://gp1.wac.edgecastcdn.net/802892/http_public_production/artists/images/2284611/original/crop:x0y0w333h333/hash:1467279653/1337190569_NTD.jpg?1467279653";

  String recommendedURL1 = "";
  String recommendedURL2 = "";
  String recommendedURL3 = "";
  String recommendedBook = "text";
  final picker = ImagePicker();

  Future getImage(String typeOfImage) async {
    if (typeOfImage == "camera") {
      final pickedFile = await picker.getImage(source: ImageSource.camera);

      setState(() {
        _image = File(pickedFile.path);
        recommendedBookReceived = false;
        imagePicked = true;
        uploadFile(_image);
      });
    } else {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        _image = File(pickedFile.path);
        recommendedBookReceived = false;
        imagePicked = true;
        uploadFile(_image);
      });
    }
  }

  Widget _buildFloatingActionButton() {
    final icons = [
      SpeedDialAction(child: Icon(Icons.photo_camera)),
      SpeedDialAction(child: Icon(Icons.photo)),
    ];

    return SpeedDialFloatingActionButton(
      actions: icons,
      // Make sure one of child widget has Key value to have fade transition if widgets are same type.
      childOnFold: Icon(Icons.add_a_photo, key: UniqueKey()),
      childOnUnfold: Icon(Icons.add),
      useRotateAnimation: true,
      onAction: _onSpeedDialAction,
    );
  }

  _onSpeedDialAction(int selectedActionIndex) {
    if (selectedActionIndex == 0) {
      getImage("camera");
    } else {
      getImage("gallery");
    }
  }

  void getHttp() async {
    try {
      Response response = await Dio()
          .get("https://www.googleapis.com/books/v1/volumes?q=isbn:0521618762");
      print(response);
    } catch (e) {
      print(e);
    }
  }

  // Remember, containers are like divs.

  Widget _buildChild() {
    if (imagePicked) {
      if (!recommendedBookReceived) {
        return Container(
          margin: EdgeInsets.all(20),
          // color: Colors.white,
          height: 500,
          width: 350,
          child: Container(
            // margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
            decoration: new BoxDecoration(
              // color: Colors.green,
              color: Color(0xFF1b262c),
              borderRadius: new BorderRadius.all(
                Radius.circular(30.0),
              ),
            ),

            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Loading",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: "RobotoMono",
                        fontWeight: FontWeight.w600),
                  ),
                  Image.network(
                      "https://i.pinimg.com/originals/51/77/40/5177402f9a223466db995ed7c25a6311.gif"),
                ]),
          ),
        );
      } else {
        return Container(
          height: 500,
          width: 350,
          // margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
          decoration: new BoxDecoration(
            // color: Colors.green,
            borderRadius: new BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),

          child: LiquidSwipe(
            enableSlideIcon: true,
            waveType: WaveType.liquidReveal,
            positionSlideIcon: .1,
            pages: [
              Container(
                // color: Colors.white,
                // margin: EdgeInsets.all(20),
                height: double.infinity,
                width: double.infinity,
                decoration: new BoxDecoration(
                  color: Color(0xFF1b262c),
                  borderRadius: new BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(
                      "Recommended Books",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                    Image.network(recommendedURL1),
                    new Text(
                      recommendedTitle1,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.pinkAccent,
                height: double.infinity,
                width: double.infinity,
                decoration: new BoxDecoration(
                  // color: Color(0xFFd6e0f0),
                  color: Color(0xFFffc93c),
                  borderRadius: new BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(
                      "Recommended Books",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                    Image.network(recommendedURL2),
                    new Text(
                      recommendedTitle2,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.pinkAccent,
                height: double.infinity,
                width: double.infinity,
                decoration: new BoxDecoration(
                  // color: Color(0xFFd6e0f0),
                  color: Color(0xFF318fb5),
                  borderRadius: new BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Text(
                      "Recommended Books",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                    Image.network(recommendedURL3),
                    new Text(
                      recommendedTitle3,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: "RobotoMono",
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            fullTransitionValue: 500,
            // enableLoop: true,
            // enableSlideIcon: true,
            // positionSlideIcon: 0.8,
            // waveType: WaveType.circularReveal,
            // onPageChangeCallback: (page) => pageChangeCallback(page),
            // currentUpdateTypeCallback: (updateType) =>
            //     updateTypeCallback(updateType),
          ),
        );
      }
    } else {
      return Container(
        // color: Colors.pinkAccent,
        height: 500,
        width: 350,
        decoration: new BoxDecoration(
          // color: Color(0xFFd6e0f0),
          color: Color(0xFF1b262c),
          borderRadius: new BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),

        child: Column(
          // mainAxisAlignment: MainAxisAlignment,
          children: [
            SizedBox(height: 50),
            new Text(
              "Take a Picture or Upload a Book",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "RobotoMono",
                  fontWeight: FontWeight.w600),
            ),
            new Text(
              "for Recommendations",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "RobotoMono",
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 50),
            Image.network(
                "https://images.theconversation.com/files/45159/original/rptgtpxd-1396254731.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1356&h=668&fit=crop"),
          ],
        ),
      );

      return Container(
        // color: Color(0xFF1a1c20),
        child: Text(
          "Take a picture or Upload a picture of your book",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "RobotoMono",
              fontWeight: FontWeight.w600),
        ),
      );
    }
  }

  pageChangeCallback(int page) {
    print(page);
  }

  updateTypeCallback(UpdateType updateType) {
    print(updateType);
  }

  void uploadFile(File file) async {
    // TODO: Change name of this function
    try {
      String fileName = file.path.split('/').last;
      FormData formData = new FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: "test.jpg"),
      });

      Dio dio = new Dio();

      Response response = await dio
          .post("http://100.25.142.121:8000/recommendBooks", data: formData);
      print(response.data["recommended_items"][0]["title"]);
      print(response.data["recommended_items"][0]["isbn"]); // how to read data.
      // recommendedISBNs = response.data["recommended_items"];
      int recommendedISBN = response.data["recommended_items"][0]["isbn"];
      // recommendedTitles = response.data["recommended_items"];
      String recommendedTitle = response.data["recommended_items"][0]["title"];
      recommendedBook = recommendedTitle;
      recommendedTitle1 = response.data["recommended_items"][0]["title"];
      recommendedTitle2 = response.data["recommended_items"][1]["title"];
      recommendedTitle3 = response.data["recommended_items"][2]["title"];

      // TODO: CLEAN up this code
      Response getResponse = await dio.get(
          "https://www.googleapis.com/books/v1/volumes?q==$recommendedTitle");
      print(getResponse.data["items"][0]);
      print(getResponse.data["items"][0]["volumeInfo"]["imageLinks"]
          ["thumbnail"]);
      String thumbnail =
          getResponse.data["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"];
      recommendedURL = (thumbnail != null) ? thumbnail : recommendedURL;
      recommendedURL1 = response.data["recommended_items"][0]["image"];
      recommendedURL2 = response.data["recommended_items"][1]["image"];
      recommendedURL3 = response.data["recommended_items"][2]["image"];
      setState(() {
        _image = null;
        recommendedBookReceived = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Book Photo Recommender",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF222831),
      ),
      body: Center(
        child: _buildChild(),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: getImage,
      //   tooltip: 'Pick Image',
      //   backgroundColor: Colors.blue,
      //   child: Icon(Icons.add_a_photo),
      // ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomAppBar(
          notchMargin: 10,
          shape: CircularNotchedRectangle(),
          color: Color(0xFF222831),
          child: Container(height: 50.0)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
// TODO: Add a Carousel for viewing recommended books (Maybe)
// TODO: Change styling of app

// TODO: iPhone camera and gallery integration?

// TODO: On touch of recommended books, add description?

// TODO: Experiment with Colors swap for swipe button to be more visible
