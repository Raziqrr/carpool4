/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:32:56
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-01 23:16:47
/// @FilePath: lib/pages/add.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:carpool4/widgets/CustomTextField.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyline;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webapi/src/core.dart' as google_maps;
import 'package:map_location_picker/map_location_picker.dart';

import '../widgets/PrimaryButton.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.uid, required this.user});
  final String uid;
  final Map<String, dynamic> user;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController searchOriginController = TextEditingController();
  TextEditingController searchDestinationController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  LatLng? originLocation;
  LatLng? destinationLocation;

  int pageIndex = 0;
  GoogleMapController? mapController;
  Marker originMarker = Marker(markerId: MarkerId("origin"));
  Marker destinationMarker = Marker(markerId: MarkerId("destination"));

  Polyline route = Polyline(polylineId: PolylineId("route"));
  List<LatLng> polylineCoordinates = [];

  void HandlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      LocationPermission newPermission = await Geolocator.requestPermission();
      HandlePermission();
    } else {
      Position currentLocation = await Geolocator.getCurrentPosition();
      originLocation =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      SetMarker("origin", originLocation!, BitmapDescriptor.hueGreen, "start");
      setState(() {
        originLocation;
      });
    }
  }

  Marker SetMarker(String name, LatLng location, double hue, String title) {
    return Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        position: location,
        infoWindow: InfoWindow(title: title),
        markerId: MarkerId(name));
  }

  void MoveMap() {
    mapController?.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(tilt: 54, zoom: 13.9, target: originLocation!)));
    setState(() {
      mapController;
    });
  }

  void FindRoute(LatLng start, LatLng end) async {
    polyline.PolylinePoints polylinePoints = polyline.PolylinePoints();
    polyline.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
      request: polyline.PolylineRequest(
        origin: polyline.PointLatLng(start.latitude, start.longitude),
        destination: polyline.PointLatLng(end.latitude, end.longitude),
        mode: polyline.TravelMode.driving,
      ),
    );
    polylineCoordinates.clear();
    result.points.forEach((point) =>
        {polylineCoordinates.add(LatLng(point.latitude, point.longitude))});

    setState(() {
      polylineCoordinates;
    });
    route = Polyline(
        width: 5,
        color: Colors.red,
        points: polylineCoordinates,
        polylineId: PolylineId("route"));
    print(result.points);
  }

  void MakeRide(String originAddress, String destinationAddress, String date,
      String time, String price) async {
    final db = FirebaseFirestore.instance;

    try {
      await db.collection('Rides').add({
        'origin': originAddress.split(',').first,
        'destination': destinationAddress.split(',').first,
        'date': date,
        'time': time,
        'price': int.tryParse(price),
        'driverID': widget.uid,
        'driver': widget.user,
        'status': 'pending',
        'passengers': []
      }).then((doc) {
        print('Document added with ID: ${doc.id}');
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error adding document: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    HandlePermission();
    final date = DateTime.now();
    if (date != null) {
      setState(() {
        dateController.text = DateFormat.MMMd().format(date);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: pageIndex < 2
          ? Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Primarybutton(
                      buttonText: "Next",
                      onPressed: (originLocation != null ||
                              destinationLocation != null)
                          ? () {
                              setState(() {
                                pageIndex += 1;
                              });
                              if (pageIndex == 2) {
                                print("making ride");
                                MakeRide(
                                    searchOriginController.text,
                                    searchDestinationController.text,
                                    dateController.text,
                                    timeController.text,
                                    priceController.text);
                              }
                            }
                          : null),
                ],
              ),
            )
          : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text("Ride Location"),
      ),
      body: [
        Column(
          children: [
            Card(
              child: Column(
                children: [
                  PlacesAutocomplete(
                    controller: searchOriginController,
                    searchController: searchOriginController,
                    hideBackButton: true,
                    apiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
                    mounted: mounted,
                    top: false,
                    topCardMargin: EdgeInsets.zero,
                    onSuggestionSelected: (location) async {
                      final String address = location.description ?? "";
                      List<geocoding.Location> locations =
                          await geocoding.locationFromAddress(address);
                      originLocation =
                          LatLng(locations[0].latitude, locations[0].longitude);
                      setState(() {
                        originMarker = SetMarker("origin", originLocation!,
                            BitmapDescriptor.hueGreen, "start");
                      });
                      MoveMap();
                      if (destinationLocation != null) {
                        FindRoute(originLocation!, destinationLocation!);
                      }
                    },
                  ),
                  PlacesAutocomplete(
                    controller: searchDestinationController,
                    searchController: searchDestinationController,
                    onReset: () {
                      searchDestinationController.clear();
                      setState(() {
                        searchDestinationController;
                      });
                    },
                    onSuggestionSelected: (location) async {
                      final String address = location.description ?? "";
                      List<geocoding.Location> locations =
                          await geocoding.locationFromAddress(address);
                      destinationLocation =
                          LatLng(locations[0].latitude, locations[0].longitude);
                      setState(() {
                        searchDestinationController.text = address;
                        destinationMarker = SetMarker(
                            "destination",
                            destinationLocation!,
                            BitmapDescriptor.hueRed,
                            "destination");
                      });
                      MoveMap();
                      if (originLocation != null) {
                        FindRoute(originLocation!, destinationLocation!);
                      }
                    },
                    hideBackButton: true,
                    topCardMargin: EdgeInsets.zero,
                    apiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
                    mounted: mounted,
                    top: false,
                  ),
                ],
              ),
            ),
            originLocation != null
                ? Expanded(
                    child: GoogleMap(
                        fortyFiveDegreeImageryEnabled: true,
                        mapType: MapType.satellite,
                        markers: {
                          if (originLocation != null) originMarker,
                          if (destinationLocation != null) destinationMarker,
                        },
                        onMapCreated: (controller) {
                          setState(() {
                            mapController = controller;
                          });
                        },
                        polylines: {
                          if (originLocation != null &&
                              destinationLocation != null)
                            route
                        },
                        initialCameraPosition: CameraPosition(
                            tilt: 10, zoom: 13.9, target: originLocation!)),
                  )
                : Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
          ],
        ),
        Column(
          children: [
            Text("Ride Details"),
            TextField(
              onTap: () async {
                final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2025));
                if (date != null) {
                  setState(() {
                    dateController.text = DateFormat.MMMd().format(date);
                  });
                }
              },
              controller: dateController,
              readOnly: true,
            ),
            TextField(
              keyboardType: TextInputType.number,
              readOnly: true,
              controller: timeController,
              onTap: () async {
                TimeOfDay time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(DateTime.now())) ??
                    TimeOfDay.fromDateTime(DateTime.now());
                timeController.text = "${time.hour}:${time.minute}";
                setState(() {
                  timeController;
                });
              },
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price",
              ),
            )
          ],
        ),
        Expanded(
            child: Center(
          child: CircularProgressIndicator(),
        ))
      ][pageIndex],
    );
  }
}

//gotta win one more (another one)
