import 'package:chat_firebase_test1/crate_login_account.dart';
import 'package:chat_firebase_test1/create_account.dart';
import 'package:chat_firebase_test1/first_screen.dart';
import 'package:chat_firebase_test1/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                    child: const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: size.width / 1.3,
                    child: const Text(
                      "Sign in to continue",
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
                        // field(size, "email", Icons.account_box),
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
                        // field(size, "password", Icons.password),
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
                          height: size.height / 10,
                        ),
                        customButton(size),
                        SizedBox(
                          height: size.height / 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateAccount()));
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> submit() async {
    final _isValid = _formKey.currentState!.validate();

    if (!_isValid) {
      return null;
    } else {
      setState(() {
        _isLoading = true;
      });

      await login(_email.text, _pass.text).then((_user) {
        if (_user != null) {
          print("Login Successful");
          setState(() {
            _isLoading = false;
          });

          Navigator.push(
              // context, MaterialPageRoute(builder: (context) => HomeScreen()));
              context,
              MaterialPageRoute(builder: (context) => FirstScreen()));
        } else {
          print("Login failed");
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    // _formKey.currentState!.save();
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
        child: const Text(
          "Login",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget field(Size size, String hintText, IconData iconData) {
  //   return Container(
  //     height: size.height / 15,
  //     width: size.width / 1.2,
  //     child: TextField(
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(iconData),
  //         hintText: hintText,
  //         hintStyle: const TextStyle(color: Colors.grey),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
