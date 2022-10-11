import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vector_math/vector_math.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hackathonpaciente/screens/map_screen.dart';
import 'package:hackathonpaciente/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../providers/screen_provider.dart';
import '../widgets/screen_selector.dart';
import 'package:location/location.dart';

class EmergencyScreen extends StatefulWidget {
  EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late IO.Socket socket;
  bool isConnected = false;
  bool ambulanceFound = false;
  String room = '';
  double latitudE = 0;
  double longitudE = 0;

  double latitudL = 0;
  double longitudL = 0;

  bool joinedRoom = false;
  @override
  void initState() {
    super.initState();
    // connect();
    connect();
  }

  void connect() {
    // MessageModel messageModel = MessageModel(sourceId: widget.sourceChat.id.toString(),targetId: );
    socket = IO.io("https://lifeline-socket.herokuapp.com/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.onConnect((data) {
      setState(() {
        isConnected = true;
      });
      print("Connected");
      socket.emit('user__joined', {
        'id': 1,
        'username': 'Leonardo',
        'location': {
          'longitude': longitudE,
        }
      });

      socket.on("success__request__ambulance", (msg) {
        print(msg);
      });

      socket.on("error__request__ambulance", (msg) {
        print(msg);
      });

      socket.on("search__ambulance", (msg) {
        print(msg);
      });

      socket.on("ambulances__not__found", (msg) {
        print(msg);
      });
      // socket.on("ambulance__change__location", (data) {
      //   print('sadas');
      //   latitudL = data['latitude'];
      //   longitudL = data['longitude'];

      //   // Navigator.push(
      //   //     context,
      //   //     MaterialPageRoute(
      //   //         builder: (context) => HomeScreen(
      //   //               latsuya: latitudE,
      //   //               lonsuya: longitudE,
      //   //               latmia: latitudL,
      //   //               lonmia: longitudL,
      //   //             )));
      // });

      socket.on("ambulance__found", (data) {
        joinedRoom = true;
        print(data);
        room = data['room'];
        longitudL = data['location']["longitude"];
        latitudL = data['location']["latitude"];
        longitudE = data['myLocation']['longitude'];
        latitudE = data['myLocation']['latitude'];

        // Map<String, dynamic> loca = jsonDecode(data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    latsuya: latitudE,
                    lonsuya: longitudE,
                    latmia: latitudL,
                    lonmia: longitudL,
                    socket: socket,
                    room: room)));
      });
    });
    print(socket.connected);
  }

  Future<void> CheckServices(
    Location location,
    bool _serviceEnabled,
    PermissionStatus _permissionGranted,
  ) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }

      print(_serviceEnabled);
      print(_permissionGranted);
    }
  }

  Future<LocationData> RecuperarLocation(
      Location location, var _locationData) async {
    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider =
        Provider.of<ScreensProvider>(context, listen: false);
    var location = Location();
    location.onLocationChanged.listen((LocationData currentLocation) {
      // Use current location
      if (joinedRoom == true) {
        print('object');
        socket.emit("change__user__location", {
          "latitude": currentLocation.latitude,
          "longitude": currentLocation.longitude,
          "room": room
        });
      }
    });
    bool _serviceEnabled = false;
    PermissionStatus _permissionGranted = PermissionStatus.denied;
    var _locationData;

    CheckServices(
      location,
      _serviceEnabled,
      _permissionGranted,
    );

    return Scaffold(
      appBar: AppBar(
          title: Text('Lifeline'),
          backgroundColor: Color(0xff8fb9fc),
          actions: [
            IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                }),
          ]),
      // add more IconButton

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            ScreenSelector(),
            SizedBox(
              height: 150,
            ),
            FutureBuilder(
              future: RecuperarLocation(location, _locationData),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return SnackBar(
                      content: Text("Sorry, we couldn't find your location."));
                } else {
                  return InkWell(
                    onTap: () {
                      _locationData = snapshot.data;
                      latitudE = _locationData.latitude;
                      longitudE = _locationData.longitude;

                      var location = {
                        "latitude": _locationData.latitude,
                        "longitude": _locationData.longitude,
                      };
                      socket.emit('request__ambulance', {
                        "location": location,
                        'id': 1,
                        'username': 'Leonardo',
                      });
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Material(
                              borderRadius: BorderRadius.circular(130),
                              color: ui.Color.fromARGB(0, 255, 255, 255),
                              elevation: 3,
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(130),
                                  color: Color(0xff8fb9fc),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 37,
                            ),
                            Center(
                              child: Image(
                                image: AssetImage('lib/assets/boton.png'),
                                width: 130,
                                height: 130,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class HomeScreen extends StatefulWidget {
//   static const id = "HOME_SCREEN";
//   double lonmia;
//   double latmia;
//   double lonsuya;
//   double latsuya;
//   late Socket socket; 

//   HomeScreen({
//     Key? key,
//     required this.lonmia,
//     required this.latmia,
//     required this.lonsuya,
//     required this.latsuya,
//     required this.socket,
//   }) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   List<Marker> _markers = <Marker>[];
//   Animation<double>? _animation;
//   late GoogleMapController _controller;

//   final _mapMarkerSC = StreamController<List<Marker>>();

//   StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

//   Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

//   @override
//   void initState() {
//     super.initState();
//     // Starting the animation after 1 second.
//     Future.delayed(const Duration(seconds: 1)).then((value) {
//       animateCar(
//         widget.latmia,
//         widget.lonmia,
//         widget.latsuya,
//         widget.lonsuya,
//         _mapMarkerSink,
//         this,
//         _controller,
//       );
//       animateCar1(
//         widget.latsuya,
//         widget.lonsuya,
//         widget.latmia,
//         widget.lonmia,
//         _mapMarkerSink,
//         this,
//         _controller,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentLocationCamera = CameraPosition(
//       target: LatLng(widget.latmia, widget.lonmia),
//       zoom: 12,
//     );

//     final googleMap = StreamBuilder<List<Marker>>(
//         stream: mapMarkerStream,
//         builder: (context, snapshot) {
//           return GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: currentLocationCamera,
//             rotateGesturesEnabled: false,
//             tiltGesturesEnabled: false,
//             mapToolbarEnabled: false,
//             myLocationEnabled: false,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             onMapCreated: (GoogleMapController controller) {
//               _controller = controller;
//             },
//             markers: Set<Marker>.of(snapshot.data ?? []),
//             padding: EdgeInsets.all(8),
//           );
//         });

//     return Scaffold(
//       body: Stack(
//         children: [
//           googleMap,
//         ],
//       ),
//     );
//   }

//   setUpMarker() async {
//     final currentLocationCamera = LatLng(widget.latsuya, widget.lonsuya);

//     final pickupMarker = Marker(
//       markerId: MarkerId("${currentLocationCamera.latitude}"),
//       position: LatLng(
//           currentLocationCamera.latitude, currentLocationCamera.longitude),
//       icon: BitmapDescriptor.fromBytes(
//           await getBytesFromAsset('lib/assets/ambulance.png', 200)),
//     );

//     //Adding a delay and then showing the marker on screen
//     await Future.delayed(const Duration(milliseconds: 500));

//     _markers.add(pickupMarker);
//     _mapMarkerSink.add(_markers);
//   }

//   Future<Uint8List> getBytesFromAsset(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetWidth: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }

//   double getBearing(LatLng begin, LatLng end) {
//     double lat = (begin.latitude - end.latitude).abs();
//     double lng = (begin.longitude - end.longitude).abs();

//     if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
//       return degrees(atan(lng / lat));
//     } else if (begin.latitude >= end.latitude &&
//         begin.longitude < end.longitude) {
//       return (90 - degrees(atan(lng / lat))) + 90;
//     } else if (begin.latitude >= end.latitude &&
//         begin.longitude >= end.longitude) {
//       return degrees(atan(lng / lat)) + 180;
//     } else if (begin.latitude < end.latitude &&
//         begin.longitude >= end.longitude) {
//       return (90 - degrees(atan(lng / lat))) + 270;
//     }
//     return -1;
//   }

//   animateCar(
//     double fromLat, //Starting latitude
//     double fromLong, //Starting longitude
//     double toLat, //Ending latitude
//     double toLong, //Ending longitude
//     StreamSink<List<Marker>>
//         mapMarkerSink, //Stream build of map to update the UI
//     TickerProvider
//         provider, //Ticker provider of the widget. This is used for animation
//     GoogleMapController controller, //Google map controller of our widget
//   ) async {
//     final double bearing =
//         getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

//     _markers.clear();

//     var carMarker = Marker(
//         markerId: const MarkerId("driverMarker"),
//         position: LatLng(fromLat, fromLong),
//         icon: BitmapDescriptor.fromBytes(
//             await getBytesFromAsset('lib/assets/ambulance.png', 200)),
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//         rotation: bearing,
//         draggable: false);

//     //Adding initial marker to the start location.
//     _markers.add(carMarker);
//     mapMarkerSink.add(_markers);

// //     final animationController = AnimationController(
// //       duration: const Duration(seconds: 20), //Animation duration of marker
// //       vsync: provider, //From the widget
// //     );

//     // Tween<double> tween = Tween(begin: 0, end: 1);

// //     _animation = tween.animate(animationController)
// //       ..addListener(() async {
// //         //We are calculating new latitude and logitude for our marker
// //         final v = _animation!.value;
// //         double lng = v * toLong + (1 - v) * fromLong;
// //         double lat = v * toLat + (1 - v) * fromLat;
// //         LatLng newPos = LatLng(lat, lng);

// //         //Removing old marker if present in the marker array
// //         if (_markers.contains(carMarker)) _markers.remove(carMarker);

// //         //New marker location
// //         carMarker = Marker(
// //             markerId: const MarkerId("driverMarker"),
// //             position: newPos,
// //             icon: BitmapDescriptor.fromBytes(
// //                 await getBytesFromAsset('lib/assets/ambulance.png', 200)),
// //             anchor: const Offset(0.5, 0.5),
// //             flat: true,
// //             rotation: bearing,
// //             draggable: false);

// //         //Adding new marker to our list and updating the google map UI.
//     _markers.add(carMarker);
//     mapMarkerSink.add(_markers);

// //         //Moving the google camera to the new animated location.
// //         controller.animateCamera(CameraUpdate.newCameraPosition(
// //             CameraPosition(target: newPos, zoom: 15.5)));
// //       });

// //     //Starting the animation
// //     animationController.forward();
// //   }
//   }

//   animateCar1(
//     double fromLat, //Starting latitude
//     double fromLong, //Starting longitude
//     double toLat, //Ending latitude
//     double toLong, //Ending longitude
//     StreamSink<List<Marker>>
//         mapMarkerSink, //Stream build of map to update the UI
//     TickerProvider
//         provider, //Ticker provider of the widget. This is used for animation
//     GoogleMapController controller, //Google map controller of our widget
//   ) async {
//     final double bearing =
//         getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

//     _markers.clear();

//     var carMarker1 = Marker(
//         markerId: const MarkerId("personMarker"),
//         position: LatLng(fromLat, fromLong),
//         icon: BitmapDescriptor.fromBytes(
//             await getBytesFromAsset('lib/assets/ambulance.png', 200)),
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//         rotation: bearing,
//         draggable: false);

//     //Adding initial marker to the start location.

//     _markers.add(carMarker1);
//     mapMarkerSink.add(_markers);

// //     final animationController = AnimationController(
// //       duration: const Duration(seconds: 20), //Animation duration of marker
// //       vsync: provider, //From the widget
// //     );

//     // Tween<double> tween = Tween(begin: 0, end: 1);

// //     _animation = tween.animate(animationController)
// //       ..addListener(() async {
// //         //We are calculating new latitude and logitude for our marker
// //         final v = _animation!.value;
// //         double lng = v * toLong + (1 - v) * fromLong;
// //         double lat = v * toLat + (1 - v) * fromLat;
// //         LatLng newPos = LatLng(lat, lng);

// //         //Removing old marker if present in the marker array
// //         if (_markers.contains(carMarker)) _markers.remove(carMarker);

// //         //New marker location
// //         carMarker = Marker(
// //             markerId: const MarkerId("driverMarker"),
// //             position: newPos,
// //             icon: BitmapDescriptor.fromBytes(
// //                 await getBytesFromAsset('lib/assets/ambulance.png', 200)),
// //             anchor: const Offset(0.5, 0.5),
// //             flat: true,
// //             rotation: bearing,
// //             draggable: false);

// //         //Adding new marker to our list and updating the google map UI.

//     _markers.add(carMarker1);
//     mapMarkerSink.add(_markers);
// //         //Moving the google camera to the new animated location.
// //         controller.animateCamera(CameraUpdate.newCameraPosition(
// //             CameraPosition(target: newPos, zoom: 15.5)));
// //       });

// //     //Starting the animation
// //     animationController.forward();
// //   }
//   }
// }
