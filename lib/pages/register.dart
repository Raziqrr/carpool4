import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carpool4/pages/login.dart';
import 'package:carpool4/widgets/CustomTextField.dart';
import 'package:carpool4/widgets/GenderCard.dart';
import 'package:carpool4/widgets/PrimaryButton.dart';
import 'package:carpool4/widgets/SecondaryButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:32:24
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-31 17:50:03
/// @FilePath: lib/pages/register.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController icController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String selectedGender = "";
  Uint8List? image;
  TextEditingController carBrandController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carPlateNumberController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  int pageIndex = 0;

  String? imagePath;

  bool isIcError = true;
  bool isPhoneError = true;
  bool isEmailError = true;
  bool isGenderError = true;
  bool isNameError = true;
  bool isImageError = true;
  bool isAddressError = true;
  bool isCarBrandError = true;
  bool isCarModelError = true;
  bool isCarPlateNumberError = true;
  bool isCapacityError = true;
  bool isPasswordError = true;

  String icError = "";
  String phoneError = "";
  String emailError = "";
  String nameError = "";
  String imageError = "";
  String addressError = "";
  String carBrandError = "";
  String carModelError = "";
  String carPlateNumberError = "";
  String capacityError = "";
  String passwordError = "";

  List<String> carSpecialFeatures = [];
  List<TextEditingController> carSpecialFeaturesController = [];

  bool ValidateInputs() {
    if (isEmailError == false &&
        isNameError == false &&
        isPhoneError == false &&
        isAddressError == false &&
        isGenderError == false &&
        isImageError == false) {
      return true;
    } else {
      return false;
    }
  }

  void CheckIC(
    String ic,
  ) async {
    if (ic.length < 1) {
      ShowError("IC number or password cannot be empty", "Error loggin in");
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "$ic@driver.cc", password: "123456");
      ShowError('User already exists', 'IC number error');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          pageIndex += 1;
        });
      } else if (e.code == 'wrong-password') {
        ShowError('User already exists', 'IC number error');
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

  void PickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? chosenImage = await imagePicker.pickImage(source: source);
    if (chosenImage != null) {
      final imageData = await File(chosenImage.path).readAsBytes();
      if (imageData != null) {
        setState(() {
          isImageError = false;
          image = imageData;
          imagePath = chosenImage.name;
        });
        Navigator.pop(context);
      }
    }
  }

  void ShowSuccess(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                      child: Primarybutton(
                          buttonText: "Login",
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }))
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void Register(
    String ic,
    String password,
    String name,
    String phone,
    String email,
    String address,
    String gender,
    Uint8List image,
    String carBrand,
    String carModel,
    String carPlateNumber,
    String capacity,
    List<String> carSpecialFeatures,
  ) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${ic}@driver.cc",
        password: password,
      );

      final storageRef = FirebaseStorage.instance
          .ref("drivers/images/${ic}/${DateTime.now()}.jpg");
      await storageRef.putData(image);
      final String imageURL = await storageRef.getDownloadURL();

      final db = FirebaseFirestore.instance;
      print(credential.user!.uid);
      db.collection("Users").doc(credential.user!.uid).set(<String, dynamic>{
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "gender": gender,
        "image": imageURL,
        "carBrand": carBrand,
        "carModel": carModel,
        "carPlateNumber": carPlateNumber,
        "capacity": int.parse(capacity),
        "carSpecialFeatures": carSpecialFeatures,
      });

      ShowSuccess("Account Registration Successful");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ShowError(
            'The password provided is too weak.', 'Error Registering Account');
      } else if (e.code == 'email-already-in-use') {
        ShowError('The account already exists for that IC number',
            'Error Registering Account');
      }
    } catch (e) {
      ShowError('${e}', 'Unknown Error');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ([
          Column(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 30 / 100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Register"),
                    Text("Access your driver account")
                  ],
                ),
              ),
              CustomTextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(12),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: icController,
                  onChanged: (String value) {
                    if (value.length < 12) {
                      setState(() {
                        isIcError = true;
                        icError = "IC number must be 12 digits";
                      });
                    } else {
                      setState(() {
                        isIcError = false;
                        icError = "";
                      });
                    }
                  },
                  hintText: "IC Number",
                  errorText: icError),
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Expanded(
                    child: Primarybutton(
                        buttonText: "Next",
                        onPressed: isIcError == true
                            ? null
                            : () {
                                CheckIC(icController.text);
                              }),
                  )
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
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Login with an existing account",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemGreen),
                          )))
                ],
              )
            ],
          ),
          Column(
            children: [
              Text("Complete Driver Registration",
                  style: GoogleFonts.montserrat()),
              CustomTextField(
                  controller: nameController,
                  onChanged: (String value) {
                    if (value.isEmpty) {
                      setState(() {
                        nameError = "Name cannot be empty";
                        isNameError = true;
                      });
                    } else {
                      setState(() {
                        nameError = "";
                        isNameError = false;
                      });
                    }
                  },
                  hintText: "Name",
                  errorText: nameError),
              CustomTextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  onChanged: (String value) {
                    bool isEmailValid = EmailValidator.validate(value);
                    if (isEmailValid == false) {
                      setState(() {
                        isEmailError = true;
                        emailError = "Invalid email";
                      });
                    } else {
                      setState(() {
                        isEmailError = false;
                        emailError = "";
                      });
                    }
                  },
                  hintText: "Email address",
                  errorText: emailError),
              CustomTextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ],
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: (String value) {
                    if (value.length < 10) {
                      setState(() {
                        isPhoneError = true;
                        phoneError = "Phone number must be 10 digits";
                      });
                    } else {
                      setState(() {
                        isPhoneError = false;
                        phoneError = "";
                      });
                    }
                  },
                  hintText: "Phone Number",
                  errorText: phoneError),
              CustomTextField(
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 3,
                  controller: addressController,
                  onChanged: (String value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        addressError = "";
                        isAddressError = false;
                      });
                    } else {
                      setState(() {
                        addressError = "Address cannot be empty";
                        isAddressError = true;
                      });
                    }
                  },
                  hintText: "Home address",
                  errorText: addressError),
              Row(
                children: [
                  Text("Gender"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Gendercard(
                    onTap: () {
                      setState(() {
                        isGenderError = false;
                        selectedGender = "Male";
                      });
                    },
                    value: "Male",
                    icon: Icons.male,
                    isSelected: selectedGender,
                    primary: CupertinoColors.activeBlue,
                    secondary: Colors.lightBlueAccent,
                  ),
                  Gendercard(
                    onTap: () {
                      setState(() {
                        isGenderError = false;
                        selectedGender = "Female";
                      });
                    },
                    value: "Female",
                    icon: Icons.female,
                    isSelected: selectedGender,
                    primary: Colors.pink,
                    secondary: Colors.pinkAccent.shade100,
                  ),
                  Gendercard(
                    onTap: () {
                      setState(() {
                        isGenderError = false;
                        selectedGender = "Other";
                      });
                    },
                    value: "Other",
                    icon: Icons.transgender,
                    isSelected: selectedGender,
                    primary: Colors.blueGrey,
                    secondary: Colors.blueGrey.shade100,
                  )
                ],
              ),
              Row(
                children: [Text("Profile Photo")],
              ),
              imagePath == null || image == null
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Choose upload method"),
                                    actions: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      PickImage(
                                                          ImageSource.camera);
                                                    },
                                                    child: Text("Camera")),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      PickImage(
                                                          ImageSource.gallery);
                                                    },
                                                    child: Text("Gallery")),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              "Upload",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent),
                          ),
                        ),
                      ],
                    )
                  : Card(
                      child: ListTile(
                        trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                image = null;
                                imagePath = null;
                              });
                            },
                            icon: Icon(
                              CupertinoIcons.xmark_circle,
                              color: Colors.red,
                            )),
                        title: Text("${imagePath}"),
                      ),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Secondarybutton(
                      onPressed: () {
                        setState(() {
                          pageIndex -= 1;
                        });
                      },
                      buttonText: "Back"),
                  Primarybutton(
                      buttonText: "Next",
                      onPressed: (isEmailError ||
                              isNameError ||
                              isPhoneError ||
                              isAddressError ||
                              isGenderError ||
                              isImageError)
                          ? null
                          : () {
                              setState(() {
                                pageIndex += 1;
                              });
                            })
                ],
              )
            ],
          ),
          Column(
            children: [
              Text("Complete Driver Registration",
                  style: GoogleFonts.montserrat()),
              CustomTextField(
                  controller: carBrandController,
                  onChanged: (String value) {},
                  hintText: "Car Brand",
                  errorText: carBrandError),
              CustomTextField(
                  controller: carModelController,
                  onChanged: (String value) {},
                  hintText: "Car Model",
                  errorText: carModelError),
              CustomTextField(
                  controller: carPlateNumberController,
                  onChanged: (String value) {},
                  hintText: "Car Plate Number",
                  errorText: carPlateNumberError),
              CustomTextField(
                  controller: capacityController,
                  onChanged: (String value) {},
                  hintText: "Car Capacity",
                  errorText: ""),
              Row(
                children: [
                  Text("Special Features"),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          carSpecialFeatures.add("");
                          carSpecialFeaturesController
                              .add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add))
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: carSpecialFeatures.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 15,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            carSpecialFeatures.removeAt(index);
                            carSpecialFeaturesController[index].clear();
                            carSpecialFeaturesController.removeAt(index);
                          });
                        },
                        icon: Icon(Icons.add)),
                    title: TextField(
                      controller: carSpecialFeaturesController[index],
                      onChanged: (String value) {
                        setState(() {
                          carSpecialFeatures[index] = value;
                        });
                      },
                    ),
                  );
                },
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Secondarybutton(
                      onPressed: () {
                        setState(() {
                          pageIndex -= 1;
                        });
                      },
                      buttonText: "Back"),
                  Primarybutton(
                      buttonText: "Next",
                      onPressed: (isEmailError ||
                              isNameError ||
                              isPhoneError ||
                              isAddressError ||
                              isGenderError ||
                              isImageError)
                          ? null
                          : () {
                              setState(() {
                                pageIndex += 1;
                              });
                            })
                ],
              )
            ],
          ),
          Column(
            children: [
              Text("Complete Driver Registration",
                  style: GoogleFonts.montserrat()),
              CustomTextField(
                  controller: passwordController,
                  onChanged: (String value) {},
                  hintText: "",
                  errorText: passwordError),
              Row(
                children: [
                  Secondarybutton(
                      onPressed: () {
                        setState(() {
                          pageIndex -= 1;
                        });
                      },
                      buttonText: "Back"),
                  Primarybutton(
                      buttonText: "Register",
                      onPressed: () {
                        Center(child: CircularProgressIndicator());
                        Register(
                            icController.text,
                            passwordController.text,
                            nameController.text,
                            phoneController.text,
                            emailController.text,
                            addressController.text,
                            selectedGender,
                            image!,
                            carBrandController.text,
                            carModelController.text,
                            carPlateNumberController.text,
                            capacityController.text,
                            carSpecialFeatures);
                      }),
                ],
              )
            ],
          )
        ][pageIndex]),
      ),
    );
  }
}
