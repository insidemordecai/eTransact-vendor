//large based on implementation of https://github.com/itsmordecai/flash-chat/blob/master/lib/screens/registration_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'home.dart';
import 'package:etransact_vendor/constants.dart';
import 'package:etransact_vendor/model/palette.dart';

class SignUp extends StatefulWidget {
  static const String id = 'signup';

  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final String title = 'eTransact';
  final String subTitle = 'Vendor';

  final _auth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Vendors");

  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;

  late String email;
  late String password;
  late String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SizedBox(
                width: 500.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                              fontFamily: 'Roboto'),
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Text(
                          subTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                            fontFamily: 'Roboto',
                            color: Palette.kTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    // using TextFormField (instead of TextField) to make use of validate operations
                    TextFormField(
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        name = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter vendor name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter User Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter an Email Address';
                        } else if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter your password',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: kRoundedBorder,
                        fixedSize: kFixedSize,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            showSpinner = true;
                          });

                          try {
                            await _auth
                                .createUserWithEmailAndPassword(
                                    email: email, password: password)
                                .then((result) {
                              dbRef.child(result.user!.uid).set({
                                "email": email,
                                "name": name,
                              }).then((res) {
                                User? loggedUser =
                                    FirebaseAuth.instance.currentUser;
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Home(uid: loggedUser!.uid)),
                                    (Route<dynamic> route) => false);
                              });
                            });

                            setState(() {
                              showSpinner = false;
                            });
                          } catch (e) {
                            String errorMessage = e.toString();

                            setState(() {
                              showSpinner = false;
                            });

                            kShowToast(errorMessage);
                          }
                        }
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
