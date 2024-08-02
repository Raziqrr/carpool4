/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-31 18:20:06
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-02 00:04:27
/// @FilePath: lib/widgets/CustomRideOverview.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:carpool4/pages/detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomRideOverview extends StatefulWidget {
  const CustomRideOverview(
      {super.key, required this.ride, required this.rideId});
  final Map<String, dynamic> ride;
  final String rideId;

  @override
  State<CustomRideOverview> createState() => _CustomRideOverviewState();
}

class _CustomRideOverviewState extends State<CustomRideOverview> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      color: Colors.lightGreen.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.ride["date"],
                  style: GoogleFonts.b612Mono(),
                ),
                Text(
                  widget.ride["time"],
                  style: GoogleFonts.b612Mono(),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.yellowAccent),
                      child: Text("RM${widget.ride["price"]}/seat"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.yellowAccent),
                      child: Text(widget.ride["status"]),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 2, bottom: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.yellowAccent),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                          ),
                          Text(
                              "${widget.ride["passengers"].length}/${widget.ride["driver"]["capacity"]}"),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
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
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return DetailPage(
                              ride: widget.ride,
                              rideId: widget.rideId,
                            );
                          }));
                        },
                        child: Text("View Ride")))
              ],
            )
          ],
        ),
      ),
    );
  }
}
