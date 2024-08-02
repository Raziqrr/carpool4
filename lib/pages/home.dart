/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:32:35
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-02 00:18:40
/// @FilePath: lib/pages/home.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:carpool4/pages/add.dart';
import 'package:carpool4/widgets/CustomRideOverview.dart';
import 'package:carpool4/widgets/PrimaryButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> myRide =
      FirebaseFirestore.instance.collection('Rides').snapshots();

  Map<String, dynamic> userData = {};
  Map<String, dynamic> userRides = {};
  void GetUserData() {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("Users").doc(widget.user.uid).get();
    docRef.then((value) {
      userData = value.data() as Map<String, dynamic>;
    });
  }

  void RemoveCredentials() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove("ic");
    _prefs.remove("password");
  }

  @override
  void initState() {
    // TODO: implement initState
    GetUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Primarybutton(
                  buttonText: "Schedule Ride",
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return AddPage(
                        uid: widget.user.uid,
                        user: userData,
                      );
                    }));
                  }),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userData["image"] != null
              ? CircleAvatar(
                  radius: 3, backgroundImage: NetworkImage(userData["image"]))
              : SizedBox(),
        ),
        title: Text("Kongsi Kereta"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                RemoveCredentials();
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.logout_rounded,
                color: CupertinoColors.systemGreen,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Text("Schedule"),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: myRide,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  final rides = snapshot.data!.docs.where((doc) {
                    return doc["driverID"] == widget.user.uid;
                  }).toList();
                  return ListView.builder(
                    itemCount: rides.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomRideOverview(
                        ride: rides[index].data() as Map<String, dynamic>,
                        rideId: rides[index].id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
