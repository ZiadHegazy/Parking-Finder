import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking2/parkingObject.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:parking2/MapView.dart';
import 'main.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (true) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }
}

class SpaceDiv extends StatelessWidget {
  String name;
  int available;
  int occupied;
  String location;
  double lat;
  double lng;
  String img;
  SpaceDiv(this.name, this.available, this.occupied, this.location, this.lat,
      this.lng, this.img) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: (Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
              ),
            ],
            borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$name',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          'assets/available.png',
                          width: 50,
                        ),
                        Text(
                          'FREE : $available',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/occupied.png',
                          width: 50,
                        ),
                        Text(
                          'BUSY: $occupied',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          // Image.asset(
                          //   "assets/gmaps.png",
                          //   width: 30,
                          // ),
                          Icon(
                            Icons.navigation,
                            color: Colors.blue,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                //make link blue and underline
                                text: "Maps Location",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    //MapUtils.openMap(-3.823216, -38.481700);
                                    MapsLauncher.launchQuery('$location');
                                  }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/$img',
                      width: 165,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

class AllDiv extends StatefulWidget {
  List<ParkingObject> allParkings;
  List<Widget> widgets = [];
  double generalLat;
  double generalLng;
  AllDiv(this.allParkings, this.generalLat, this.generalLng) {
    for (int i = 0; i < allParkings.length; i++) {
      widgets.add(SpaceDiv(
          allParkings[i].name,
          allParkings[i].available,
          allParkings[i].occupied,
          allParkings[i].location,
          allParkings[i].lat,
          allParkings[i].lng,
          allParkings[i].img));
    }
    print(widgets);
  }
  @override
  State<StatefulWidget> createState() => _AllDivState();
}

class _AllDivState extends State<AllDiv> {
  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Center(child: Text('Parking Finder')),
            bottom: TabBar(tabs: [
              Tab(
                text: "List View",
                icon: Icon(Icons.list),
              ),
              Tab(text: "Map View", icon: Icon(Icons.map)),
              Tab(text: "Search View", icon: Icon(Icons.search)),
            ]),
          ),
          body: TabBarView(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.widgets,
                  ),
                ),
              ),
              Center(
                  child: MapView(widget.allParkings, widget.generalLat,
                      widget.generalLng)),
              Center(child: MyApp(2)),
            ],
          )));
}
