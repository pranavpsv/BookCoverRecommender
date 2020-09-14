// import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter_speed_dial_material_design/flutter_speed_dial_material_design.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter/services.dart';

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
  // TODO: Clean up into extensible array
  File _image;
  bool imagePicked = false;
  bool recommendedBookReceived = false;
  String recommendedURL =
      "https://gp1.wac.edgecastcdn.net/802892/http_public_production/artists/images/2284611/original/crop:x0y0w333h333/hash:1467279653/1337190569_NTD.jpg?1467279653";

  String recommendedDescription1 = "";
  String originalTitle = "";
  String originalDescription = "";
  String originalImageLink = "";
  bool showDescription = false;
  List<String> recommendedURLs = ["", "", ""];
  List<String> recommendedTitles = ["", "", ""];
  List<int> recommendedISBNs = [0, 0, 0];
  List<String> recommendedDescriptions = ["", "", ""];
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

  Widget getColumn(int index) {
    if (!showDescription) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(
            (index != 3) ? "Recommended Book" : "Your Book",
            style: TextStyle(
                color: ((index == 1) || (index == 0))
                    ? Colors.white
                    : Colors.black,
                fontSize: 25,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          ),
          new Text(
            (index != 3) ? recommendedTitles[index] : originalTitle,
            style: TextStyle(
                color: ((index == 1) || (index == 0))
                    ? Colors.white
                    : Colors.black,
                fontSize: 17,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          ),
          (index != 3)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    recommendedURLs[index],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(originalImageLink)),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(
            (index != 3) ? "Recommended Book" : "Your Book",
            style: TextStyle(
                color: ((index == 1) || (index == 0))
                    ? Colors.white
                    : Colors.black,
                fontSize: 25,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          ),
          new Text(
            (index != 3) ? recommendedTitles[index] : originalTitle,
            style: TextStyle(
                color: ((index == 1) || (index == 0))
                    ? Colors.white
                    : Colors.black,
                fontSize: 17,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          ),
          new Text(
            (index != 3) ? recommendedDescriptions[index] : originalDescription,
            style: TextStyle(
                color: ((index == 1) || (index == 0))
                    ? Colors.white
                    : Colors.black,
                fontSize: 12,
                fontFamily: "RobotoMono",
                fontWeight: FontWeight.w600),
          )
        ],
      );
    }
  }

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

          // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
            positionSlideIcon: 0,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            pages: [
              InkWell(
                onTap: () {
                  print("Tapped");
                  setState(() {
                    showDescription = (showDescription) ? false : true;
                  });
                },
                child: Container(
                  // color: Colors.white,
                  // margin: EdgeInsets.all(20),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: double.infinity,
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    // color: Color(0xFF4e89ae),
                    gradient: new LinearGradient(
                        // colors: [Color(0xffb4005c), Color(0xffff0084)],
                        colors: [Color(0xFFffb347), Color(0xFFffcc33)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.5),
                    //     spreadRadius: 5,
                    //     blurRadius: 7,
                    //     offset: Offset(0, 3), // changes position of shadow
                    //   ),
                    // ],
                    // color: Color(0xFFffc93c),

                    borderRadius: new BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),

                  child: getColumn(3),
                ),
              ),
              InkWell(
                onTap: () {
                  print("Tapped");
                  setState(() {
                    showDescription = (showDescription) ? false : true;
                  });
                },
                child: Container(
                  // color: Colors.white,
                  // margin: EdgeInsets.all(20),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: double.infinity,
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    // color: Color(0xFF1b262c),
                    // color: Color(0xFFffc93c),
                    gradient: new LinearGradient(
                        colors: [Color(0xFF02aab0), Color(0xFF00cdac)],
                        // colors: [Color(0xff2c3e50), Color(0xff2980b9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp),

                    borderRadius: new BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),

                  child: getColumn(0),
                ),
              ),
              InkWell(
                onTap: () {
                  print("Tapped");
                  setState(() {
                    showDescription = (showDescription) ? false : true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                  // color: Colors.pinkAccent,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    // color: Color(0xFFd6e0f0),
                    // color: Color(0xff222831),
                    gradient: new LinearGradient(
                        colors: [Color(0xFF000000), Color(0xFF434343)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp),

                    borderRadius: new BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),

                  child: getColumn(1),
                ),
              ),
              InkWell(
                onTap: () {
                  print("Tapped");
                  setState(() {
                    showDescription = (showDescription) ? false : true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),

                  // color: Colors.pinkAccent,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: new BoxDecoration(
                    // color: Color(0xFFd6e0f0),
                    // color: Color(0xff4f8a8b),
                    // color: Color(0xffFF5C6E),
                    // color: Color(0xfff1f3f8),
                    gradient: new LinearGradient(
                        colors: [Color(0xFFB8C6DB), Color(0xFFf5f7fa)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp),

                    borderRadius: new BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),

                  child: getColumn(2),
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
          // color: Color(0xff68b0ab),
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
            Image.asset(
              "images/cover.jpg",
              // height: 300,
            )
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
      // int recommendedISBN = response.data["recommended_items"][0]["isbn"];
      // String recommendedTitle = response.data["recommended_items"][0]["title"];
      // recommendedBook = recommendedTitle;
      // TODO: CLEAN up this code
      // Response getResponse = await dio.get(
      //     "https://www.googleapis.com/books/v1/volumes?q==$recommendedTitle");
      // print(getResponse.data["items"][0]["volumeInfo"]["imageLinks"]
      //     ["thumbnail"]);
      // String thumbnail =
      //     getResponse.data["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"];
      originalDescription = response.data["original_item"]["book_description"];
      originalTitle = response.data["original_item"]["title"];
      originalImageLink = response.data["original_item"]["image"];
      for (var i = 0; i < 3; ++i) {
        recommendedURLs[i] = response.data["recommended_items"][i]["image"];
        recommendedTitles[i] = response.data["recommended_items"][i]["title"];
        recommendedISBNs[i] = response.data["recommended_items"][i]["isbn"];
        recommendedDescriptions[i] =
            response.data["recommended_items"][i]["description"];
      }
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF222831),
    ));
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "BookCover Recommender",
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

// TODO: iPhone problems check

// TODO: Add persistent storage
