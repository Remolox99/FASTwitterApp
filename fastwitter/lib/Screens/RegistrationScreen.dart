import 'package:flutter/material.dart';
import 'package:FASTwitter/Constants/Constants.dart';
import 'package:FASTwitter/Services/auth_service.dart';
import 'package:FASTwitter/Widgets/RoundedButton.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _email;
  String _password;
  String _name;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StdColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Registration',
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
                hintText: 'Name',
              ),
              onChanged: (value) {
                _name = value;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
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
                hintText: 'Password',
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
                'Create Account',
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
                bool isValid =
                await AuthService.signUp(_name, _email, _password);
                if (isValid) {
                  Navigator.pop(context);
                } else {
                  print('Something went wrong');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
