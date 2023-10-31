import 'dart:math';

import 'package:company/User.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

class FullScreenImage extends StatelessWidget {
  final String base64Image;

  FullScreenImage(this.base64Image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // You can include an app bar if needed
      body: Center(
        child: GestureDetector(
          onTap: () {
            // When the user taps the full-size image, navigate back
            Navigator.pop(context);
          },
          child: Image.memory(
            base64Decode(base64Image),
            // You might want to adjust the fit and other properties here
          ),
        ),
      ),
    );
  }
}
