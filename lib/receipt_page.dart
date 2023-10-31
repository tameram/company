import 'dart:ffi';
import 'dart:io';
import 'package:company/User.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ReceiptPage extends StatefulWidget {
  final User user;

  ReceiptPage({required this.user});
  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  File? _imageFile;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _controller!.takePicture();

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isSending = true;
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isSending = true;
        });
      }
    } else {
      if (status.isPermanentlyDenied) {
        openAppSettings();
      } else {}
    }
  }

  Future<void> _sendImageToServer() async {
    ///MultiPart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://www.ziad.website/api/create_mission/"),
    );
    Map<String, String> headers = {
      "X-CSRFToken": "${widget.user.csrfToken ?? ""}",
      "Content-type": "multipart/form-data",
      "Cookie":
          "csrftoken=${widget.user.csrfToken}; sessionid=${widget.user.sessionId}"
    };
    request.files.add(
      http.MultipartFile(
        'image',
        _imageFile!.readAsBytes().asStream(),
        _imageFile!.lengthSync(),
        filename: _imageFile?.uri.pathSegments.last,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    request.headers.addAll(headers);
    request.fields.addAll({"driver": widget.user.driverId ?? ""});
    print("request: " + request.toString());

    var res = await request.send();

    if (res.statusCode == 200 || res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image uploaded successfully'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed. Status code: ${res.statusCode}'),
        ),
      );
    }
  }

  /*Future<void> _sendImageToServer() async {
    try {
      final url = Uri.parse('https://www.ziad.website/api/create_mission/');
      var request = http.MultipartRequest('POST', url);

      // Add CSRF token to the headers
      request.headers['X-CSRFToken'] = widget.user.csrfToken!;

      // Add the image file
      final fileStream = http.ByteStream(_imageFile!.openRead());
      final fileLength = await _imageFile!.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: 'image.jpg',
      );

      request.files.add(multipartFile);

      // Add the cookie ID to the request body
      request.fields['driver'] = widget.user.driverId!;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed. Status code: ${streamedResponse.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
        ),
      );
    }
  }*/

  void _handleSendButtonPress() async {
    if (_isSending) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 16.0),
                Text('Uploading Image...'),
              ],
            ),
          ),
        );

        await _sendImageToServer();

        // Dismiss the loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set text direction to RTL
      child: Scaffold(
        appBar: AppBar(
          title: Text('מצלמה'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 173, 216, 230),
                Color.fromARGB(255, 170, 184, 214),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: _imageFile == null
                      ? (_controller != null && _controller!.value.isInitialized
                          ? CameraPreview(_controller!)
                          : CircularProgressIndicator())
                      : Image.file(_imageFile!),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: Text('צלם תמונה'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Set button color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: Text('העלה תמונה'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Set button color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _handleSendButtonPress,
                child: const Text('שלח תמונה'),
                style: ElevatedButton.styleFrom(
                  primary: _isSending
                      ? Colors.blue
                      : Colors.grey, // Set button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
