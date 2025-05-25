import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveToken extends StatefulWidget {
  const SaveToken({super.key});

  @override
  _SaveTokenState createState() => _SaveTokenState();
}

class _SaveTokenState extends State<SaveToken> {
  final TextEditingController _textController = TextEditingController();
  String _savedToken = '';

  @override
  void initState() {
    super.initState();
    _loadSavedString();
  }

  // Carregar string salva
  Future<void> _loadSavedString() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedToken = prefs.getString('saved_token') ?? 'Empty Token.';
    });
  }

  // Salvar string
  Future<void> _saveString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_token', value);
    setState(() {
      _savedToken = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token saved sucessfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Token'),backgroundColor: Colors.black,titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200, // Largura desejada
              height: 50,
              child:
            ElevatedButton(
              onPressed: () {
                final input = _textController.text;
                if (input.isNotEmpty) {
                  _saveString(input);
                  _textController.clear();
                  
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insert token before saving!')),
                  );
                }
              },
              child: const Text('Save'),
            )),
            const SizedBox(height: 24),
            Text(
              'Saved Token: $_savedToken',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200, // Largura desejada
              height: 50,
              child:ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Voltar à tela anterior
              },
              child: const Text('Back'),
            ))
          ],
          
        ),
      ),
    );
  }
}