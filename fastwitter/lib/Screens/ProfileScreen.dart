import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:FASTwitter/Constants/Constants.dart';
import 'package:FASTwitter/Models/Tweet.dart';
import 'package:FASTwitter/Models/UserModel.dart';
import 'package:FASTwitter/Screens/EditProfileScreen.dart';
import 'package:FASTwitter/Screens/WelcomeScreen.dart';
import 'package:FASTwitter/Services/DatabaseServices.dart';
import 'package:FASTwitter/Services/auth_service.dart';
import 'package:FASTwitter/Widgets/TweetContainer.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const ProfileScreen({Key key, this.currentUserId, this.visitedUserId})
      : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  int _profileSegmentedValue = 0;
  List<Tweet> _allTweets = [];
  List<Tweet> _mediaTweets = [];

  Map<int, Widget> _profileTabs = <int, Widget>{
    0: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Tweets',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
    1: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Media',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  };

  Widget buildProfileWidgets(UserModel author) {
    switch (_profileSegmentedValue) {
      case 0:
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _allTweets.length,
            itemBuilder: (context, index) {
              return TweetContainer(
                currentUserId: widget.currentUserId,
                author: author,
                tweet: _allTweets[index],
              );
            });
        break;
      case 1:
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _mediaTweets.length,
            itemBuilder: (context, index) {
              return TweetContainer(
                currentUserId: widget.currentUserId,
                author: author,
                tweet: _mediaTweets[index],
              );
            });
        break;
      default:
        return Center(
            child: Text('Something wrong', style: TextStyle(fontSize: 25)));
        break;
    }
  }

  getFollowersCount() async {
    int followersCount =
    await DatabaseServices.followersNum(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getFollowingCount() async {
    int followingCount =
    await DatabaseServices.followingNum(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  followOrUnFollow() {
    if (_isFollowing) {
      unFollowUser();
    } else {
      followUser();
    }
  }

  unFollowUser() {
    DatabaseServices.unFollowUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  followUser() {
    DatabaseServices.followUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  setupIsFollowing() async {
    bool isFollowingThisUser = await DatabaseServices.isFollowingUser(
        widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
  }

  getAllTweets() async {
    List<Tweet> userTweets =
    await DatabaseServices.getUserTweets(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _allTweets = userTweets;
        _mediaTweets =
            _allTweets.where((element) => element.image.isNotEmpty).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowersCount();
    getFollowingCount();
    setupIsFollowing();
    getAllTweets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: usersRef.doc(widget.visitedUserId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(StdColor),
                ),
              );
            }
            UserModel userModel = UserModel.fromDoc(snapshot.data);
            return ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: StdColor,
                    image: userModel.coverImage.isEmpty
                        ? null
                        : DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(userModel.coverImage),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox.shrink(),
                        widget.currentUserId == widget.visitedUserId
                            ? PopupMenuButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 35,
                          ),
                          itemBuilder: (_) {
                            return <PopupMenuItem<String>>[
                              new PopupMenuItem(
                                child: Text('Logout'),
                                value: 'logout',
                              )
                            ];
                          },
                          onSelected: (selectedItem) {
                            if (selectedItem == 'logout') {
                              AuthService.logout();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WelcomeScreen()));
                            }
                          },
                        )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -35.0, 0.0),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: userModel.profilePicture.isEmpty
                                ? AssetImage('assets/placeholder.png')
                                : NetworkImage(userModel.profilePicture),
                          ),
                          widget.currentUserId == widget.visitedUserId
                              ? GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                    user: userModel,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child: Container(
                              width: 80,
                              height: 35,
                              padding:
                              EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(color: StdColor),
                              ),
                              child: Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: StdColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : GestureDetector(
                            onTap: followOrUnFollow,
                            child: Container(
                              width: 100,
                              height: 35,
                              padding:
                              EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _isFollowing
                                    ? Colors.white
                                    : StdColor,
                                border: Border.all(color: StdColor),
                              ),
                              child: Center(
                                child: Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: _isFollowing
                                        ? StdColor
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        userModel.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        userModel.bio,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$_followingCount Following',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$_followersCount Followers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.0,
                  child: new Center(
                    child: new Container(
                      margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                      height: 2.0,
                      color: Colors.black12,
                    ),
                  ),
                ),
                buildProfileWidgets(userModel),
              ],
            );
          },
        ));
  }
}
