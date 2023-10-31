import 'package:company/User.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main_page.dart';
import 'receipt_page.dart';
import 'receipt_history.dart';
import 'package:flutter/services.dart';

void main() {
  final User loggedInUser = User();
  runApp(
    MaterialApp(
      initialRoute: '/',
      locale: const Locale('he', ''),
      routes: {
        '/': (context) => LoginPage(),
        '/receipt': (context) => ReceiptPage(
              user: loggedInUser,
            ),
        '/receipthistory': (context) => ReceiptHistory(
              user: loggedInUser,
            ),
        '/main': (context) => MainPage(
              user: loggedInUser,
            ),
      },
    ),
  );
}
