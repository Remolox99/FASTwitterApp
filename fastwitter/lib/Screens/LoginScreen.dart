import 'package:flutter/material.dart';
import 'package:fastwitter/Constants/Constants.dart';
import 'package:fastwitter/Services/auth_service.dart';
import 'package:fastwitter/Widgets/RoundedButton.dart';

import 'FeedScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  String _password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: StdColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Your email',
              ),
              onChanged: (value) {
                _email = value;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Your password',
              ),
              onChanged: (value) {
                _password = value;
              },
            ),
            SizedBox(
              height: 35,
            ),
            ElevatedButton(
              child: Text(
                'Login',
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                elevation: 3,
                minimumSize: Size(250, 55),
              ),
              onPressed: () async {
                bool isValid = await AuthService.login(_email, _password);
                if (isValid) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FeedScreen(currentUserId: AuthService.signedInUser.uid);
                      },
                    ),
                  );
                  // AuthService.
                  // Navigator.pop(context);
                } else {
                  print('login problem');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
