import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File _image;
  String message = '';
  bool loading = false;
  pickImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() => _image = image);
  }

  upload(File file) async {
    if (file == null) return;

    setState(() {
      loading = true;
    });
    Map<String, String> headers = {
      "Accept": "application/json",
    };
    var uri = Uri.parse("http://192.168.1.32/chatApp/public/api/upload");
    var length = await file.length();
    print(length);
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile('file', file.openRead(), length,
            filename: 'test.png'),
      );
    var respons = await http.Response.fromStream(await request.send());
    print(respons.statusCode);
    setState(() {
      loading = false;
    });
    if (respons.statusCode == 201) {
      setState(() {
        message = ' image upload with success';
      });
      return;
    } else
      setState(() {
        message = ' image not upload';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          loading
              ? Padding(
                  padding: EdgeInsets.only(top: 52),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _image != null
                  ? Image.file(
                      _image,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      'https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg'),
          Text(message),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  onPressed: () => pickImage(),
                  child: Text('Pick Image'),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  onPressed: () => upload(_image),
                  child: Text('upload image'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
