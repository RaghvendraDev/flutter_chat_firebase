import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'crate_login_account.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  File? _imageFile;

  bool _isLoading = false;

  Future<void> takePicture() async {
    print("image");
    final _picker = ImagePicker();
    final _pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 20);
    setState(() {
      _imageFile = File(_pickedImage!.path);
    });
  }

  void submit() {
    print("hello");
    final _isValid = _formKey.currentState!.validate();
    print(_isValid);

    if (!_isValid) {
      return null;
    } else {
      setState(() {
        _isLoading = true;
      });

      createAccount(_name.text, _email.text, _pass.text, _imageFile!)
          .then((user) {
        if (user != null) {
          print("Account created");
          setState(() {
            _isLoading = false;
          });
        } else {
          print("Account creation failed");
        }
      });
    }

    if (_imageFile == null) {
      return null;
    }

    // _formKey.currentState!.save();

    // if (_name.text.isNotEmpty &&
    //     _email.text.isNotEmpty &&
    //     _pass.text.isNotEmpty &&
    //     _imageFile != null) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: size.width,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  Container(
                    width: size.width / 1.3,
                    child: Text(
                      "Create account to continue",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: _imageFile == null
                              ? null
                              : FileImage(_imageFile!),
                        ),
                        // SizedBox(
                        //   height: size.height / 95,
                        // ),
                        TextButton.icon(
                            onPressed: takePicture,
                            icon: Icon(Icons.camera),
                            label: Text("take picture")),
                        //field(size, "name", Icons.account_box, "name"),
                        Container(
                          // height: size.height / 15,
                          width: size.width / 1.2,
                          child: TextFormField(
                            controller: _name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Name can not be empty";
                              } else {
                                return null;
                              }
                            },
                            autocorrect: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Name",
                              label: Text("Enter Name"),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 20,
                        ),
                        // field(size, "email", Icons.account_box, "email"),
                        Container(
                          // height: size.height / 15,
                          width: size.width / 1.2,
                          child: TextFormField(
                            controller: _email,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "email can not be empty";
                              } else {
                                return null;
                              }
                            },
                            autocorrect: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Email",
                              label: Text("Enter Email"),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 20,
                        ),
                        //field(size, "password", Icons.password, "password"),
                        Container(
                          // height: size.height / 15,
                          width: size.width / 1.2,
                          child: TextFormField(
                            controller: _pass,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "password can not be empty";
                              } else {
                                return null;
                              }
                            },
                            autocorrect: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Password",
                              label: Text("Enter Password"),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 20,
                        ),
                        customButton(
                          size,
                        ),
                        SizedBox(
                          height: size.height / 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: submit,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blue),
        height: size.height / 14,
        width: size.width / 1.2,
        child: Text(
          "Signup",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget field(
  //     Size size, String hintText, IconData iconData, String filedType) {
  //   return Container(
  //     height: size.height / 15,
  //     width: size.width / 1.2,
  //     child: TextFormField(
  //       validator: (value) {
  //         if (filedType == "name") {
  //           if (value == null && value!.isNotEmpty) {
  //             return "Name can not be empty";
  //           }
  //         }
  //         if (filedType == "email") {
  //           if (value == null && value!.isNotEmpty) {
  //             return "email can not be empty";
  //           }
  //         }

  //         if (filedType == "password") {
  //           if ((value == null && value!.isNotEmpty) || value.length < 4) {
  //             return "password should be more than 4 digit";
  //           }
  //         }
  //         return null;
  //       },
  //       autocorrect: false,
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(iconData),
  //         hintText: hintText,
  //         hintStyle: TextStyle(color: Colors.grey),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
