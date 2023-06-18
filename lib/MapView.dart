import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:label_marker/label_marker.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:parking2/parkingObject.dart';

Future<Marker> buildMarker(MarkerId markerId, LatLng position, double width,
    double height, String label, Color color) async {
  return Marker(
    markerId: markerId,
    position: position,
    icon: await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(20, 20)),
      'assets/available.png',
    ),
    infoWindow: InfoWindow(
      title: label,
    ),
    onTap: () {
      // handle marker tap event
    },
  );
}

class MapView extends StatelessWidget {
  List<ParkingObject> widgets;
  double lat;
  double lng;
  Set<Marker> markers = {};
  MapView(this.widgets, this.lat, this.lng) {
    fillMarkers();
  }
  void fillMarkers() async {
    for (int i = 0; i < widgets.length; i++) {
      markers.add(Marker(
        icon: widgets[i].available < 1
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : widgets[i].available <= 3
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
            title: widgets[i].name,
            onTap: () {
              String location = widgets[i].location;
              MapsLauncher.launchQuery('$location');
            }),

        //label: widgets[i].name,
        markerId: MarkerId(widgets[i].name),
        position: LatLng(widgets[i].lat, widgets[i].lng),
        // backgroundColor: widgets[i].available < 1
        //     ? Colors.red
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    print(lat);
    print(lng);
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng), zoom: 16, tilt: 0, bearing: 0),
          markers: markers),
    );
  }
}
