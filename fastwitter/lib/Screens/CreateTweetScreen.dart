import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastwitter/Constants/Constants.dart';
import 'package:fastwitter/Models/Tweet.dart';
import 'package:fastwitter/Services/DatabaseServices.dart';
import 'package:fastwitter/Services/StorageService.dart';
import 'package:fastwitter/Widgets/RoundedButton.dart';

class CreateTweetScreen extends StatefulWidget {
  final String currentUserId;

  const CreateTweetScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _CreateTweetScreenState createState() => _CreateTweetScreenState();
}

class _CreateTweetScreenState extends State<CreateTweetScreen> {
  String _tweetText;
  File _pickedImage;
  bool _loading = false;

  handleImageFromGallery() async {
    try {
      PickedFile imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          _pickedImage = File(imageFile.path);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: StdColor,
        centerTitle: true,
        title: Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              TextField(
                maxLength: 280,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'Write Something...',
                ),
                onChanged: (value) {
                  _tweetText = value;
                },
              ),
              SizedBox(height: 10),
              _pickedImage == null
                  ? SizedBox.shrink()
                  : Column(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: StdColor,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_pickedImage),
                        )),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              GestureDetector(
                onTap: handleImageFromGallery,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: StdColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 50,
                    color: StdColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(
                  'Post',
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
                  setState(() {
                    _loading = true;
                  });
                  if (_tweetText != null && _tweetText.isNotEmpty) {
                    String image;
                    if (_pickedImage == null) {
                      image = '';
                    } else {
                      image =
                      await StorageService.uploadTweetPicture(_pickedImage);
                    }
                    Tweet tweet = Tweet(
                      text: _tweetText,
                      image: image,
                      authorId: widget.currentUserId,
                      likes: 0,
                      retweets: 0,
                      timestamp: Timestamp.fromDate(
                        DateTime.now(),
                      ),
                    );
                    DatabaseServices.createTweet(tweet);
                    Navigator.pop(context);
                  }
                  setState(() {
                    _loading = false;
                  });
                },
              ),
              SizedBox(height: 20),
              _loading ? CircularProgressIndicator() : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
