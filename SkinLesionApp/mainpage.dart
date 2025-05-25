
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:skinlesionv2/save_token.dart';
import 'package:skinlesionv2/takepicture_screen.dart';


class Mainpage extends StatelessWidget {
  const Mainpage({
    super.key,
    required this.selectedCamera,// required camera,
  });
  
  final CameraDescription selectedCamera;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKAPP: Skin Lesion Classifier',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SKAPP: Skin Lesion Classifier'),backgroundColor: Colors.black,titleTextStyle: const TextStyle(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              SizedBox(
              width: 200, // Largura desejada
              height: 50, // Altura desejada
              child: ElevatedButton(
                 onPressed: () {
                  Navigator.push(
                  context,
                  // Ação do terceiro botão
                  MaterialPageRoute(builder: (context) =>  TakePictureScreen(
                        // Pass the appropriate camera to the TakePictureScreen widget.
                        camera: selectedCamera,
                      ),
                    ),
                  );
                },
                child: const Text('Classify lesion'),
              )
              ),
              const SizedBox(height: 20), // Espaçamento entre os botões
              SizedBox(
              width: 200, // Largura desejada
              height: 50, // Altura desejada
              child:ElevatedButton(
                
                onPressed: () {
                  Navigator.push(
                  context,
                  // Ação do terceiro botão
                 MaterialPageRoute(builder: (context) => const SaveToken())
                  );
                  print('Token');
                },
                child: const Text('Configure Token'),
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}