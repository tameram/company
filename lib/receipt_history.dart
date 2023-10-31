import 'dart:math';

import 'package:company/User.dart';
import 'package:company/full_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

class ReceiptHistory extends StatefulWidget {
  final User user;

  ReceiptHistory({required this.user});

  @override
  _ReceiptHistoryState createState() => _ReceiptHistoryState();
}

class _ReceiptHistoryState extends State<ReceiptHistory> {
  bool isLoading = true;
  late List<dynamic> receiptHistoryData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Perform your API call here
    try {
      Map<String, String> headers = {
        "X-CSRFToken": "${widget.user.csrfToken ?? ""}",
        "Content-type": "multipart/form-data",
        "Cookie":
            "csrftoken=${widget.user.csrfToken}; sessionid=${widget.user.sessionId}"
      };
      print(widget.user.driverId);
      final response = await http.get(
        Uri.parse(
            'http://www.ziad.website/api/missions/driver/${widget.user.driverId}/'),
        headers: headers, // Pass headers to the get method
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final data = json.decode(response.body);
        print(data);
        setState(() {
          isLoading = false;
          receiptHistoryData = data;
        });
      } else {
        print('neg');
        // Handle any error cases here
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle any exceptions or errors here
      setState(() {
        isLoading = false;
      });
    }
  }

  Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      height: 300, // Set the height of the image
      width: 200, // Set the width of the image
      fit: BoxFit.cover, // Adjust the fit as required (cover, contain, etc.)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('צפיה במסמכים'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 173, 216, 230),
                      Color.fromARGB(255, 170, 184, 214),
                    ],
                  ),
                ),
                child: receiptHistoryData.isEmpty
                    ? Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: receiptHistoryData.length,
                        itemBuilder: (context, index) {
                          String base64Image =
                              receiptHistoryData[index]['image'];
                          String createdDate =
                              receiptHistoryData[index]['created_on'];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigate to the FullScreenImage passing the base64Image
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImage(base64Image),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: imageFromBase64String(base64Image),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'תאריך : $createdDate',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                            ],
                          );
                        },
                      )),
      ),
    );
  }
}
