import 'package:company/User.dart';
import 'package:company/receipt_history.dart';
import 'package:company/receipt_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final User user;

  MainPage({required this.user});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth / 2;
    final buttonHeight = 200.0;
    print(widget.user.driverId);

    return Directionality(
      textDirection: TextDirection.rtl, // Set text direction to RTL
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(top: 50.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 173, 216, 230),
                Color.fromARGB(255, 170, 184, 214),
              ],
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'ברוך הבא, ${widget.user.username}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(193, 0, 0, 0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReceiptPage(
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'שליחת מסמך',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(193, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReceiptHistory(
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'צפיה במסמכים',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(193, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
