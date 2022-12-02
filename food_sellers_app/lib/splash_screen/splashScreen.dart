import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_sellers_app/authentication/auth_screen.dart';
import 'package:food_sellers_app/global/global.dart';
import 'package:food_sellers_app/main_screen/home_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {

    Timer(const Duration(seconds: 8), ()async {
      if(firebaseAuth.currentUser !=null){
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
      else{
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/splash.jpg"),
              const SizedBox(height: 10,),
              const Padding(
                  padding:  EdgeInsets.all(10.0),
                  child: Text(
                    "Food in seconds",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 40,
                      fontFamily: "Signatra",
                      letterSpacing: 3,
                    ),
                  ),
              )
            ],
          ),
        ),
      ),
    );

  }
}
