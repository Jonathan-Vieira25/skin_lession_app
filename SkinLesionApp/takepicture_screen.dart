import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinlesionv2/bargraph.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  bool _loading = false;
  bool _response = false;
  File? _image;
  List<dynamic>? _results;
  bool encryption = true;
  String testresult =
      "[{label: \"1\", probability: 0.1},{label: \"2\", probability: 0.2},{label: \"3\", probability: 0.1},{label: \"4\", probability: 0.1},{label: \"5\", probability: 0.1},{label: \"6\", probability: 0.1},{label: \"7\", probability: 0.3}]";

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  _pickImagefromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _loading = true;
          _response = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select an image")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error processing image")));
    }
  }

  _pickImagefromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _loading = true;
          _response = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select an image")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Processing image")));
    }
  }

  Future classifyImage(File image) async {
    String uriText = "";
    if (encryption) {
      uriText = 'https://192.168.8.190:5000/process_image';
    } else {
      uriText = 'https://192.168.8.190:5000/classify';
    }
    try {
      var uri = Uri.parse(uriText);
      var request = http.MultipartRequest('POST', uri);
      if (encryption) {
        // Ler a imagem como bytes
        final bytes = await image.readAsBytes();
        final prefs = await SharedPreferences.getInstance();
        //Pass Definition
        final key = encrypt.Key.fromUtf8(
            'secretpasswordxxxxxxxxxxxxxxxxxx'); //chars for AES-256
        final iv = encrypt.IV.fromUtf8('Sixteen byte IV.'); // Random IV

        // Encrypt the image
        final encrypter =
            encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
        final encryptedData = encrypter.encrypt(base64Encode(bytes), iv: iv);
        String savedToken = prefs.getString('saved_token') ?? 'Error';

        if (savedToken == 'Error') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Configure Token")));
          setState(() {
            _loading = false;
            _response = false;
          });
        } else {
          // Send encrypted data to the server
          try {
            final response = await http.post(
              Uri.parse(uriText),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': savedToken, // Adicione o token no cabeçalho
              },
              body: jsonEncode({'data': encryptedData.base64, 'iv': iv.base64}),
            );

            if (response.statusCode == 200) {
              // Decrypt the response
              final responseBody = jsonDecode(response.body);
              final encryptedResponseData = responseBody['data'];
              final responseIv = encrypt.IV.fromBase64(responseBody['iv']);
              final decryptedResponse =
                  encrypter.decrypt64(encryptedResponseData, iv: responseIv);

              var decodedResponse = json.decode(decryptedResponse);
              setState(() {
                _results = decodedResponse['predictions'];
                _response = true;
                testresult = _results.toString();
                _loading = true;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Request error")));
              setState(() {
                _loading = false;
                _response = false;
              });
            }
          } on SocketException catch (e) {
            print('Erro de conexão: ${e.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Connection error: Verify internet and token')),
            );
          } on HttpException catch (e) {
            print('Erro HTTP: ${e.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Server Error: ${e.message}')),
            );
          } catch (e) {
            print('Erro desconhecido: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected error')),
            );
          } 
        }
      } else {
        //encryption=false
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedResponse = json.decode(responseData);
          setState(() {
            _results = decodedResponse['predictions'];
            testresult = _results.toString();
            _loading = true;
            _response = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Image Classification Error. Code: ${response.statusCode}')));
          setState(() {
            _loading = false;
            _response = false;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Processing Image")));

      setState(() {
        _loading = false;
        _response = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //var h= MediaQuery.of(context).size.height;
    //var w= MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SKAPP: Skin Lesion Classifier'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: Container(
          //height:h,
          //width:w,

          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 24),
            SizedBox(
                width: 200, // Largura desejada
                height: 50, // Altura desejada
                //padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    await _pickImagefromCamera();
                  },
                  child: const Text('Camera'),
                )),
            const SizedBox(height: 24),
            SizedBox(
                width: 200, // Largura desejada
                height: 50, // Altura desejada
                //padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    await _pickImagefromGallery();
                  },
                  child: const Text('Gallery'),
                )),
            _loading
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: FileImage(_image!),
                      ),
                    ),
                  )
                : Container(),
            _loading
                ? ElevatedButton(
                    onPressed: () async {
                      await classifyImage(_image!);
                    },
                    child: const Text('Classify Image'),
                  )
                : Container(),
            _response
                ? BarGraph(
                    testresult: testresult,
                  )
                  :Container(),
            const SizedBox(height: 24),
            SizedBox(
                width: 200, // Largura desejada
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Voltar à tela anterior
                  },
                  child: const Text('Back'),
                ))
          ])),
    );
  }
}


