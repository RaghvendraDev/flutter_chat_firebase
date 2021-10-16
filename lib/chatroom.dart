import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  TextEditingController _message = TextEditingController();
  final Map<String, dynamic> selectedUserToChat;
  final String chatRoomId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatRoom(
      {Key? key, required this.selectedUserToChat, required this.chatRoomId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // title: Text(selectedUserToChat['name']),

        //setting tilte and status in app bar
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(selectedUserToChat['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    Text(
                      selectedUserToChat['name'],
                    ),
                    Text(
                      snapshot.data!['status'],
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // return Text(snapshot.data!.docs[index]['message']);
                          Map<String, dynamic>? map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>?;
                          return message(size, map!, context);
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              // height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    Container(
                      height: size.height / 12,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 0),
                            gapPadding: 10,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(Icons.attachment)),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onSendMessage,
                      icon: Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget message(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: map['sendby'] == _auth.currentUser!.displayName
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green,
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue,
                    ),
              child: Text(
                map['message'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ShowMessageImage(imageUrl: map['message'])));
              },
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }

  Future<void> onSendMessage() async {
    if (_message.text != null) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);

      _message.clear();
    } else {
      print("Enter Some text");
    }
  }

  //getimage to send

  late File _imageFile;

  Future<void> getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        _imageFile = File(xFile.path);
        uploadImages();
      } else {}
    });
  }

  //now upload image

  uploadImages() async {
    String imageNameToUpload = Uuid().v1();
    int status = 1;
//saving image in firestore chat document
    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(imageNameToUpload)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    //creating image to url
    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(imageNameToUpload + ".jpg");

    var uploadTask = await ref.putFile(_imageFile).catchError((onError) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(imageNameToUpload)
          .delete();

      status = 0;
    });

    if (status == 1) {
      final url = await uploadTask.ref.getDownloadURL();
      print(url);
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(imageNameToUpload)
          .update({'message': url});
    }
  }
}

class ShowMessageImage extends StatelessWidget {
  final String imageUrl;
  const ShowMessageImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
