import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:parking2/parkingObject.dart';
import 'package:parking2/spaces.dart';
import 'package:http/http.dart' as http;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(1),
  ));
}

class MyApp extends StatefulWidget {
  int view = 1;
  MyApp(this.view);
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

Widget getLoading(bool x, double width1) {
  if (x)
    return Container(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(
        strokeWidth: 4,
      ),
    );
  else
    return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Search For Your Parking Here",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            RotatedBox(quarterTurns: 1, child: Image.asset("assets/down4.png")),
          ],
        ));
}

class _MyAppState extends State<MyApp> {
  String location = "";
  bool loading = false;
  double arrowWidth = 60;
  double arrowD = 2;
  Widget myFunction() {
    return location == "" ? Text("Search for location") : Text("");
  }

  String googleApikey = "AIzaSyBJ7WREY_s3Drexv8D7oCaXbI3GrK7T88Y";
  final _places =
      GoogleMapsPlaces(apiKey: "AIzaSyBJ7WREY_s3Drexv8D7oCaXbI3GrK7T88Y");
  GoogleMapController? mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.view == 1
          ? AppBar(
              title: Center(child: Text('Parking Finder')),
            )
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getLoading(loading, arrowWidth),
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Positioned(
                        //search input bar
                        top: 10,
                        child: InkWell(
                            onTap: () async {
                              var place = await PlacesAutocomplete.show(
                                  context: context,
                                  apiKey: googleApikey,
                                  mode: Mode.overlay,
                                  types: [],
                                  strictbounds: false,
                                  components: [
                                    Component(Component.country, 'eg')
                                  ],
                                  //google_map_webservice package
                                  onError: (err) {
                                    print(err);
                                  });

                              if (place != null) {
                                setState(() {
                                  location = place.description.toString();
                                });

                                //form google_maps_webservice package
                                final plist = GoogleMapsPlaces(
                                  apiKey: googleApikey,
                                  apiHeaders:
                                      await GoogleApiHeaders().getHeaders(),
                                  //from google_api_headers package
                                );
                                String placeid = place.placeId ?? "0";
                                final detail =
                                    await plist.getDetailsByPlaceId(placeid);
                                final geometry = detail.result.geometry!;
                                final lat = geometry.location.lat;
                                final lang = geometry.location.lng;
                                var newlatlang = LatLng(lat, lang);

                                //move map camera to selected place with animation
                                mapController?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: newlatlang, zoom: 17)));
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Card(
                                child: Container(
                                    padding: EdgeInsets.all(0),
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    child: ListTile(
                                      title: Text(
                                        location,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      trailing: Icon(Icons.search),
                                      dense: true,
                                    )),
                              ),
                            )))

                    // TextField(
                    //   onChanged: (String value) {
                    //     setState(() {
                    //       location = value;
                    //       print(location);
                    //     });
                    //   },
                    //   textAlign: TextAlign.center,
                    //   textAlignVertical: TextAlignVertical.center,
                    //   decoration: InputDecoration(
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(
                    //           width: 3, color: Colors.greenAccent), //<-- SEE HERE
                    //       borderRadius: BorderRadius.circular(50.0),
                    //     ),
                    //     labelText: 'Enter The Location',
                    //   ),
                    // ),
                    ),

                // Container(
                //   padding: EdgeInsets.all(16.0),
                //   child: TypeAheadField(
                //     textFieldConfiguration: TextFieldConfiguration(
                //       decoration: InputDecoration(
                //         labelText: 'Search for location',
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //     suggestionsCallback: (pattern) async {
                //       final response = await _places.autocomplete(pattern,
                //           components: [Component(Component.country, 'eg')]);
                //       if (response.isOkay) {
                //         return response.predictions
                //             .map((prediction) => prediction.description);
                //       } else {
                //         return [];
                //       }
                //     },
                //     itemBuilder: (context, suggestion) {
                //       return ListTile(
                //         title: Text(suggestion.toString()),
                //       );
                //     },
                //     onSuggestionSelected: (suggestion) {
                //       print('Selected: $suggestion');
                //     },
                //   ),
                // ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                      onPressed: (loading || location == "")
                          ? null
                          : () async {
                              print(location);
                              setState(() {
                                loading = true;
                              });
                              List<ParkingObject> temp = [];
                              double generalLat = 0;
                              double generalLng = 0;
                              var client = new http.Client();
                              bool empty = false;
                              try {
                                // https://492e-102-186-63-238.ngrok-free.app
                                //http://10.0.2.2:8080
                                http.Response x = await http.get(Uri.parse(
                                    "http://10.0.2.2:8080/$location"));
                                final result = jsonDecode(x.body)["result"];
                                print(result);
                                if (result.length == 0) {
                                  empty = true;
                                }
                                for (int i = 0; i < result.length; i++) {
                                  temp.add(ParkingObject(
                                      result[i]["available"],
                                      result[i]["occupied"],
                                      result[i]["name"],
                                      result[i]["location"],
                                      result[i]["lat"],
                                      result[i]["lng"],
                                      result[i]["img"]));
                                }
                                if (!empty) {
                                  generalLat = result[0]["generalLat"];
                                  generalLng = result[0]["generalLng"];
                                }
                              } finally {
                                client.close();
                                setState(() {
                                  loading = false;
                                });
                              }
                              if (!empty) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllDiv(
                                            temp, generalLat, generalLng)));
                              } else {
                                print(12);
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Error'),
                                      content: Text(
                                          'This location is not in database'),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                      child: const Center(
                        child: Text('Search'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
