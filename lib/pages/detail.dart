/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:33:02
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-02 00:09:55
/// @FilePath: lib/pages/detail.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.ride, required this.rideId});
  final Map<String, dynamic> ride;
  final String rideId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(widget.ride["date"]), Text(widget.ride["time"])],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black),
                        width: 10,
                        height: 10,
                      ),
                    ),
                    Container(
                      height: 30,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 2,
                        color: Colors.black,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black),
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.ride["origin"]),
                    Container(
                      height: 20,
                    ),
                    Text(widget.ride["destination"])
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person),
                    Text(
                        "Passengers ${widget.ride["passengers"].length}/${widget.ride["driver"]["capacity"]}"),
                  ],
                ),
                Text("RM${widget.ride["price"]} / seat")
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.ride["passengers"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile();
              },
            ),
            ElevatedButton(
                onPressed: () {
                  final db = FirebaseFirestore.instance;
                  final rideRef = db.collection("Rides").doc(widget.rideId);
                  rideRef.update({"status": "completed"}).then(
                      (value) =>
                          print("DocumentSnapshot successfully updated!"),
                      onError: (e) => print("Error updating document $e"));
                },
                child: Text("Finished"))
          ],
        ),
      ),
    );
  }
}
