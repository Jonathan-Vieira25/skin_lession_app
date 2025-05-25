
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:skinlesionv2/mainpage.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

late List<CameraDescription> cameras;
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final selectedCamera = cameras.first;

  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MaterialApp(
      //theme: ThemeData.dark(),
      home: Mainpage(
        // Pass the appropriate camera to the TakePictureScreen widget.
        selectedCamera: selectedCamera,
      ),
    ),
  );

  
}