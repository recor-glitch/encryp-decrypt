import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohashing/encryption.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var picker = ImagePicker();
  List s_converted = ["", "", ""];
  List encrypted_strings = [0, "", "", ""]; // first index stores the length
  String tmp = "";
  int tmp_len = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Hello',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var picked = await picker.pickImage(source: ImageSource.gallery);
            var tobytes = await File(picked!.path).readAsBytes();
            print(
                'start timer : ${DateFormat('hh:ss:ms').format(DateTime.now())}');

            int i = tobytes.length;
            encrypted_strings[0] = i;
            bool status = true;
            // String will be divided in reverse order
            while (status) {
              i--;
              tmp = tobytes[i].toString();
              tmp_len = tmp.length;
              if (tmp_len == 2) {
                tmp = "0$tmp";
              } else if (tmp_len == 1) {
                tmp = "00$tmp";
              }

              s_converted[i % 3] = s_converted[i % 3] + tmp;
              if (i - 1 == -1) {
                status = false;
              }
            }

            for (int i = 0; i < 3; i++) {
              final key = "This 32 char key have 256 bits..";

              print('Plain text for encryption: ${s_converted[i]}');

              //Encrypt
              Encrypted encrypted = encryptWithAES(key, s_converted[i]);
              String encryptedBase64 = encrypted.base64;
              print('Encrypted data in base64 encoding: $encryptedBase64');
              encrypted_strings[i] = encryptedBase64;
              //Decrypt
              String decryptedText = decryptWithAES(key, encrypted);
              print('Decrypted data: $decryptedText');
            }

            print(
                'stop timer : ${DateFormat('hh:ss:ms').format(DateTime.now())}');
          },
          child: const Icon(Icons.add),
        ));
  }
}
