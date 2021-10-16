import 'package:chat_firebase_test1/chatroom.dart';
import 'package:chat_firebase_test1/crate_login_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> userMap = [];
  late Map<String, dynamic> singleUserDetail;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadAllUser();

    //check if user online
    WidgetsBinding.instance!.addObserver(this);

    //passing status online initally, when user logged in
    setStatus("Online");
  }

//checking if app's current state is equal to user's state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if (state == AppLifecycleState.resumed) {
        //online
        setStatus("Online");
      } else {
        //offline
        setStatus("Offline");
      }
    });
  }

//setting online/offline status to current user
  Future<void> setStatus(String status) async {
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "status": status,
      });
    } catch (e) {
      print("status cant be change");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
              onPressed: () {
                logout(context);
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: userMap != null
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(20),
              itemCount: userMap.length,
              itemBuilder: (context, index) {
                // return Text(userMap[index]['name']);
                return UserList(user: userMap[index]);
              })
          : Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Future<void> loadAllUser() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _firestore
        .collection("users")
        .where("email", isNotEqualTo: _auth.currentUser!.email)
        .get()
        .then((value) {
      int userLength = value.docs.length;

      userMap = [];
      for (var i = 0; i < userLength; i++) {
        singleUserDetail = value.docs[i].data();
        setState(() {
          userMap.add(singleUserDetail);
        });
      }

      // print("test");
      // print(singleUserDetail.length);
      // print(singleUserDetail);
      // print("Hello");
      // print(userMap.length);
      // print(userMap);
    });
  }
}

class UserList extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, dynamic> user;
  UserList({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black87,
              radius: 40,
              backgroundImage: NetworkImage(user['profilepic']),
            ),
            title: Text(
              user['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(user['email']),
            onTap: () {
              print('${user['name']} pressed');

              // print("display name ${_auth.currentUser!.displayName}");
              String roomId = chatRoomId(
                  _auth.currentUser!.displayName.toString(), user['name']);

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatRoom(
                          selectedUserToChat: user, chatRoomId: roomId)));
            },
          ),
        ],
      ),
    );
  }

  String chatRoomId(String user1, String user2) {
    print("user1 ");
    print(user1);
    print(user1.toLowerCase().codeUnits);
    print("user2 ");
    print(user2);
    print(user2.toLowerCase().codeUnits);

    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }
}
