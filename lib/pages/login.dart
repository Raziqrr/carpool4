/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:32:18
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-31 17:57:33
/// @FilePath: lib/pages/login.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:carpool4/pages/home.dart';
import 'package:carpool4/pages/register.dart';
import 'package:carpool4/widgets/CustomTextField.dart';
import 'package:carpool4/widgets/PrimaryButton.dart';
import 'package:carpool4/widgets/SecondaryButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController icController = TextEditingController();
  TextEditingController passwordEdController = TextEditingController();

  String icError = "";
  String passwordError = "";

  bool isIcValid = false;
  bool isPasswordValid = false;
  bool rememberMe = false;
  bool isPasswordVisible = false;

  int pageIndex = 0;

  void GetCredentials() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    final ic = await _prefs.getString("ic");
    final password = await _prefs.getString("password");

    if (ic != null && password != null) {
      Login(ic!, password!);
    }
  }

  void SaveCredentials(String ic, String password) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("ic", ic);
    _prefs.setString("password", password);
  }

  void Login(String ic, String password) async {
    if (ic.length < 1 || password.length < 1) {
      ShowError("IC number or password cannot be empty", "Error loggin in");
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "$ic@driver.cc", password: password);
      if (rememberMe == true) {
        SaveCredentials(ic, password);
      }

      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomePage(
          user: credential.user!,
        );
      }));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ShowError('No user found for that email.', 'Error logging in');
      } else if (e.code == 'wrong-password') {
        ShowError('Wrong password provided for that user.', 'Error logging in');
      }
    }
  }

  void ShowError(String errorMessage, String errorTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(errorTitle),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    GetCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 30 / 100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Login"), Text("Access your driver account")],
                ),
              ),
              Column(
                children: [
                  CustomTextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12)
                      ],
                      controller: icController,
                      onChanged: (String value) {
                        if (value.length < 12) {
                          setState(() {
                            icError = "Please enter valid IC number";
                            isIcValid = false;
                          });
                        } else {
                          setState(() {
                            icError = "";
                            isIcValid = true;
                          });
                        }
                      },
                      hintText: "Enter your IC Number",
                      errorText: icError),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      obsureText: isPasswordVisible,
                      suffix: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: isPasswordVisible == true
                              ? Icon(CupertinoIcons.eye_slash_fill)
                              : Icon(CupertinoIcons.eye_fill)),
                      controller: passwordEdController,
                      onChanged: (String value) {
                        if (value.length < 8) {
                          setState(() {
                            passwordError =
                                "Password must be at least 8 characters long";
                            isPasswordValid = false;
                          });
                        } else {
                          setState(() {
                            passwordError = "";
                            isPasswordValid = true;
                          });
                        }
                      },
                      hintText: "Enter your password",
                      errorText: passwordError),
                  CheckboxListTile(
                      activeColor: CupertinoColors.systemGreen,
                      checkboxShape: CircleBorder(),
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Remember me"),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      }),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Primarybutton(
                            buttonText: "Login",
                            onPressed: () {
                              Login(
                                  icController.text, passwordEdController.text);
                            }),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Divider(
                        thickness: 1.5,
                      ),
                      Container(
                          padding: EdgeInsets.all(7),
                          color: Colors.white,
                          child: Text("or"))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return RegisterPage();
                                }));
                              },
                              child: Text(
                                "Register a new account",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.systemGreen),
                              )))
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ][pageIndex],
    );
  }
}
