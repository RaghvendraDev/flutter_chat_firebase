import 'dart:io';
import 'dart:typed_data';

import 'package:chat_firebase_test1/chat_screens/pdf_viewer.dart';
import 'package:chat_firebase_test1/chat_screens/show_msg_images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker/emoji_picker.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  TextEditingController _message = TextEditingController();
  final Map<String, dynamic> selectedUserToChat;
  final String chatRoomId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final fileName = Uuid().v1();

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
                          hintText: "Type Something",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 0),
                            gapPadding: 10,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // prefixIcon: IconButton(
                          //   icon: Icon(Icons.emoji_emotions_outlined),
                          //   onPressed: () {},
                          // ),
                          suffixIcon: IconButton(
                              onPressed: () {
                                // getImage();

                                showModalBottomSheet(
                                  isDismissible: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (builder) =>
                                      bottomsheet(size, context),
                                );
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

  // Widget emojiSelected() {
  //   return EmojiPicker(onEmojiSelected: (emoji, category) {
  //     print(emoji);
  //   });
  // }

  Widget message(Size size, Map<String, dynamic> map, BuildContext context) {
    if (map['type'] == "text") {
      return Container(
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else if ((map['type'] == "img")) {
      return Container(
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
    } else if (map['type'] == "doc") {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        alignment: map['sendby'] == _auth.currentUser!.displayName
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: map['sendby'] == _auth.currentUser!.displayName
                    ? Colors.green
                    : Colors.blue,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text(
                  map['name'],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Icon(
                  Icons.download,
                  color: Colors.white,
                )
              ],
            ),
          ),
          onTap: () async {
            var file = await downloadFile(map['message'], map['name']);
            // openPDF(context, file, map['name']);
            OpenFile.open(file.path);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> onSendMessage() async {
    if (_message.text != null) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "name": "NA",
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

  Future<void> getImage(String type) async {
    ImagePicker _picker = ImagePicker();
    if (type == "Camera") {
      await _picker
          .pickImage(source: ImageSource.camera, imageQuality: 50)
          .then((xFile) {
        if (xFile != null) {
          _imageFile = File(xFile.path);
          uploadImages();
        } else {}
      });
    } else if (type == "Photo") {
      await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
        if (xFile != null) {
          _imageFile = File(xFile.path);
          uploadImages();
        } else {}
      });
    }
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
      "name": "",
      "time": FieldValue.serverTimestamp(),
    });

    //creating image to url
    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(imageNameToUpload + ".jpg");

    // print("ref $ref");

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
          .update({'message': url, 'name': imageNameToUpload + ".jpg"});
    }
  }

  //getimage to send

  late File _docFile;

  Uint8List? fileBytes;

  Future<void> getFile() async {
    ImagePicker _picker = ImagePicker();

    FilePickerResult? _filePicker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (_filePicker != null) {
      // fileBytes = _filePicker.files.first.bytes;
      // String fileName = _filePicker.files.first.name;
      PlatformFile file = _filePicker.files.first;
      fileBytes = file.bytes;
      String fileName = file.name;
      String fileExtension = file.extension.toString();

      print("file $fileExtension");

      _docFile = File(file.path.toString());

      // _docFile = File(_filePicker.files.first.path.toString());

      uploadFile(fileName, fileExtension);
    }
  }

  //now upload image

  uploadFile(var fileName, var extension) async {
    String docNameToUpload = fileName;
    int status = 1;
    String _type;
//saving image in firestore chat document
    if (extension == "jpg") {
      _type = "img";
    } else {
      _type = "doc";
    }
    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(docNameToUpload)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": _type,
      "name": "",
      "time": FieldValue.serverTimestamp(),
    });

    //creating image to url
    final ref = FirebaseStorage.instance
        .ref()
        .child('docs')
        .child(docNameToUpload + "." + extension);

    var uploadTask = await ref.putFile(_docFile).catchError((onError) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(docNameToUpload)
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
          .doc(docNameToUpload)
          .update({'message': url, "name": docNameToUpload});
    }
  }

  Widget bottomsheet(Size size, BuildContext context) {
    return Container(
      height: size.height / 4,
      width: size.width,
      child: Card(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    getImage("Photo");
                    //to close bottom model
                    Navigator.pop(context);
                  },
                  child: bottomAttachementIconCreation(
                      icon: Icons.photo, color: Colors.indigo, name: "Photo"),
                ),
                SizedBox(width: 40),
                InkWell(
                  onTap: () {
                    getImage("Camera");
                    Navigator.pop(context);
                  },
                  child: bottomAttachementIconCreation(
                      icon: Icons.camera, color: Colors.pink, name: "Camera"),
                ),
                SizedBox(width: 40),
                InkWell(
                  onTap: () {
                    getFile();
                    Navigator.pop(context);
                  },
                  child: bottomAttachementIconCreation(
                      icon: Icons.file_copy_outlined,
                      color: Colors.purple,
                      name: "Documents"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget bottomAttachementIconCreation(
      {required IconData icon, required Color color, required String name}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 30,
          child: Icon(
            icon,
            size: 29,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          name,
          style: TextStyle(fontSize: 12),
        )
      ],
    );
  }

  Future<File> downloadFile(String fileUrl, String fileName) async {
    print("file url $fileUrl");

    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(fileUrl));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String _fileName = fileName.toString();
    File file = new File('$dir/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  void openPDF(BuildContext context, File file, String fileName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PDFViewerClass(file: file, fileName: fileName)));
  }
}
