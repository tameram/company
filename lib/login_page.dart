import 'dart:math';

import 'package:company/User.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> saveCredentials(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('password', password);
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final User loggedInUser = User();
  String driver_id = '';

  bool _isLoading = false;
  String? savedUsername;
  String? savedPassword;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUsername = prefs.getString('username');
      savedPassword = prefs.getString('password');
      _usernameController.text = savedUsername ?? '';
      _passwordController.text = savedPassword ?? '';
    });
  }

  Future<bool> authenticateUser(String username, String password) async {
    final apiUrl = Uri.parse('http://www.ziad.website/api/user_login/');
    final body = {
      'username': username,
      'password': password,
    };

    setState(() {
      // Show loading indicator while making the API call
      _isLoading = true;
    });

    try {
      // Perform the POST request without cookies
      final response = await http.post(apiUrl, body: body);

      if (response.statusCode == 200) {
        // Check the response for authentication success
        await saveCredentials(username, password);
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['message'] == 'Login successful') {
          // If authentication is successful, extract the CSRF token from cookies
          final cookies = response.headers['set-cookie'] ?? '';
          final csrfToken = extractCSRFTokenFromCookies(cookies);
          final sessionId = extractSessionIdFromCookies(cookies);
          print("csrfToken-->${csrfToken}");
          print("sessionId-->${sessionId}");

          driver_id = responseData['driver_id'];
          // Create a new HTTP client that includes the CSRF token in headers
          final client = http.Client();
          final headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-CSRFToken': csrfToken,
          };
          print("widget.user.csrfToken $csrfToken");

          // Perform the same request with the updated headers
          final authenticatedResponse =
              await client.post(apiUrl, headers: headers, body: body);

          authenticatedResponse.headers.forEach((name, values) {
            print('$name: $values');
          });

          // Close the client when done
          client.close();
          if (authenticatedResponse.statusCode == 200) {
            // Authentication succeeded
            loggedInUser.username = username;
            loggedInUser.password = password;
            loggedInUser.driverId = driver_id;
            loggedInUser.csrfToken = csrfToken;
            loggedInUser.sessionId = sessionId;
            loggedInUser.header = authenticatedResponse.headers;
            // final prefs = await SharedPreferences.getInstance();
            // prefs.setString('driver_id', driver_id);
            // Navigate to the next page upon successful authentication
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainPage(user: loggedInUser),
              ),
            );

            return true;
          } else {
            print('Failed to authenticate user');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('שגיאה בהתחברות'),
              ),
            );
            return false;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('שם משתמש או סיסמה שגויים'),
            ),
          );
          return false; // Authentication failed
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בהתחברות'),
          ),
        );
        return false; // Authentication failed
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה בהתחברות'),
        ),
      );
      return false;
    } finally {
      setState(() {
        // Hide loading indicator after API call
        _isLoading = false;
      });
    }
  }

  String extractCSRFTokenFromCookies(String cookies) {
    final parts = cookies.split(';');
    for (var part in parts) {
      if (part.trimLeft().startsWith('csrftoken=')) {
        final csrfToken = part.trimLeft().substring('csrftoken='.length);
        return csrfToken;
      }
    }
    return '';
  }

  String extractSessionIdFromCookies(String cookies) {
    /* final parts = cookies.split(';');
    for (var part in parts) {
      if (part.trimLeft().startsWith('sessionid=')) {
        final csrfToken = part.trimLeft().substring('sessionid='.length);
        return csrfToken;
      }
    }
     SameSite=Lax,sessionid=yrc0nmrr3vxocazdlbkwu8ow0ek9e8bd
    return '';*/
    List<String> parts = cookies.split(';');
    for (String part in parts) {
      if (part.trim().startsWith("SameSite=Lax,sessionid=")) {
        return part.trim().substring("SameSite=Lax,sessionid=".length);
      }
    }
    return ""; // Session ID not found
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 173, 216, 230),
                Color.fromARGB(255, 170, 184, 214),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'כניסה',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: AutofillHints.sublocality,
                    color: Color.fromARGB(193, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'שם משתמש',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'סיסמה',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final username = _usernameController.text;
                    final password = _passwordController.text;

                    // Check if the API call is already in progress
                    if (!_isLoading) {
                      // Start the API call only if it's not already in progress
                      await authenticateUser(username, password);
                    }
                  },
                  child: Text('התחבר'),
                ),
                // Show a loading indicator while making the API call
                if (_isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
