import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vector_math/vector_math.dart';

class HomeScreen extends StatefulWidget {
  static const id = "HOME_SCREEN";
  String message = '';
  List<String> senders = [];
  List<String> messages = [];

  String room;
  double lonmia;
  double latmia;
  double lonsuya;
  double latsuya;
  late Socket socket;

  HomeScreen({
    Key? key,
    required this.lonmia,
    required this.latmia,
    required this.lonsuya,
    required this.latsuya,
    required this.socket,
    required this.room,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Marker> _markers = <Marker>[];

  Animation<double>? _animation;
  late GoogleMapController _controller;

  final _mapMarkerSC = StreamController<List<Marker>>();

  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  @override
  void initState() {
    super.initState();
    // Starting the animation after 1 second.
    Future.delayed(const Duration(seconds: 1)).then((value) {
      animateCar(
        widget.latmia,
        widget.lonmia,
        widget.latsuya,
        widget.lonsuya,
        _mapMarkerSink,
        this,
        _controller,
      );
      animateCar1(
        widget.latsuya,
        widget.lonsuya,
        widget.latmia,
        widget.lonmia,
        _mapMarkerSink,
        this,
        _controller,
      );
      widget.socket.on("receive__message", (data) {
        getMessage(
            widget.messages, widget.senders, data['message'], data['user']);
      });

      widget.socket.on("ambulance__change__location", (data) {
        print('sadas');
        widget.latmia = data['latitude'];
        widget.lonsuya = data['longitude'];

        _markers.clear();
        _markers.clear();
        animateCar(
          widget.latmia,
          widget.lonmia,
          widget.latsuya,
          widget.lonsuya,
          _mapMarkerSink,
          this,
          _controller,
        );
        animateCar1(
          widget.latsuya,
          widget.lonsuya,
          widget.latmia,
          widget.lonmia,
          _mapMarkerSink,
          this,
          _controller,
        );
      });
    });
  }

  @override
  void getMessage(List<String> messages, List<String> senders, String message,
      String sender) {
    setState(() {
      // updating the state
      messages.add(message);
      senders.add(sender);
    });
  }

  Widget build(BuildContext context) {
    int i = 0;

    final currentLocationCamera = CameraPosition(
      target: LatLng(widget.latmia, widget.lonmia),
      zoom: 20,
    );

    final googleMap = StreamBuilder<List<Marker>>(
        stream: mapMarkerStream,
        builder: (context, snapshot) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: currentLocationCamera,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: Set<Marker>.of(snapshot.data ?? []),
            padding: EdgeInsets.all(8),
          );
        });

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                googleMap,
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                for (var i = 0; i < widget.senders.length; i++)
                  ListTile(
                    title: Text('${widget.senders[i]}: ${widget.messages[i]}'),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Flexible(
            child: TextFormField(
              onChanged: (value) {
                widget.message = value;
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      minimumSize: MaterialStatePropertyAll(Size(80, 50)),
                      maximumSize: MaterialStatePropertyAll(Size(80, 50))),
                  child: Text('Send'),
                  onPressed: () {
                    print(widget.message);
                    getMessage(widget.messages, widget.senders, widget.message,
                        'John');
                    widget.socket.emit("send__message", {
                      "message": widget.message,
                      "room": widget.room,
                      "username": 'John'
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  setUpMarker() async {
    final currentLocationCamera = LatLng(widget.latsuya, widget.lonsuya);

    final pickupMarker = Marker(
      markerId: MarkerId("${currentLocationCamera.latitude}"),
      position: LatLng(
          currentLocationCamera.latitude, currentLocationCamera.longitude),
      icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset('lib/assets/ambulance.png', 100)),
    );

    //Adding a delay and then showing the marker on screen
    await Future.delayed(const Duration(milliseconds: 500));

    _markers.add(pickupMarker);
    _mapMarkerSink.add(_markers);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();
    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - degrees(atan(lng / lat))) + 270;
    }
    return -1;
  }

  animateCar(
    double fromLat, //Starting latitude
    double fromLong, //Starting longitude
    double toLat, //Ending latitude
    double toLong, //Ending longitude
    StreamSink<List<Marker>>
        mapMarkerSink, //Stream build of map to update the UI
    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation
    GoogleMapController controller, //Google map controller of our widget
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    _markers.clear();

    var carMarker = Marker(
        markerId: const MarkerId("driverMarker"),
        position: LatLng(fromLat, fromLong),
        icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset('lib/assets/ambulance.png', 100)),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false);

    //Adding initial marker to the start location.
    _markers.add(carMarker);
    mapMarkerSink.add(_markers);

//     final animationController = AnimationController(
//       duration: const Duration(seconds: 20), //Animation duration of marker
//       vsync: provider, //From the widget
//     );

    // Tween<double> tween = Tween(begin: 0, end: 1);

//     _animation = tween.animate(animationController)
//       ..addListener(() async {
//         //We are calculating new latitude and logitude for our marker
//         final v = _animation!.value;
//         double lng = v * toLong + (1 - v) * fromLong;
//         double lat = v * toLat + (1 - v) * fromLat;
//         LatLng newPos = LatLng(lat, lng);

//         //Removing old marker if present in the marker array
//         if (_markers.contains(carMarker)) _markers.remove(carMarker);

//         //New marker location
//         carMarker = Marker(
//             markerId: const MarkerId("driverMarker"),
//             position: newPos,
//             icon: BitmapDescriptor.fromBytes(
//                 await getBytesFromAsset('lib/assets/ambulance.png', 200)),
//             anchor: const Offset(0.5, 0.5),
//             flat: true,
//             rotation: bearing,
//             draggable: false);

//         //Adding new marker to our list and updating the google map UI.
    _markers.add(carMarker);
    mapMarkerSink.add(_markers);

//         //Moving the google camera to the new animated location.
//         controller.animateCamera(CameraUpdate.newCameraPosition(
//             CameraPosition(target: newPos, zoom: 15.5)));
//       });

//     //Starting the animation
//     animationController.forward();
//   }
  }

  animateCar1(
    double fromLat, //Starting latitude
    double fromLong, //Starting longitude
    double toLat, //Ending latitude
    double toLong, //Ending longitude
    StreamSink<List<Marker>>
        mapMarkerSink, //Stream build of map to update the UI
    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation
    GoogleMapController controller, //Google map controller of our widget
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    _markers.clear();

    var carMarker1 = Marker(
        markerId: const MarkerId("personMarker"),
        position: LatLng(fromLat, fromLong),
        icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset('lib/assets/boy.png', 100)),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false);

    //Adding initial marker to the start location.

    _markers.add(carMarker1);
    mapMarkerSink.add(_markers);

//     final animationController = AnimationController(
//       duration: const Duration(seconds: 20), //Animation duration of marker
//       vsync: provider, //From the widget
//     );

    // Tween<double> tween = Tween(begin: 0, end: 1);

//     _animation = tween.animate(animationController)
//       ..addListener(() async {
//         //We are calculating new latitude and logitude for our marker
//         final v = _animation!.value;
//         double lng = v * toLong + (1 - v) * fromLong;
//         double lat = v * toLat + (1 - v) * fromLat;
//         LatLng newPos = LatLng(lat, lng);

//         //Removing old marker if present in the marker array
//         if (_markers.contains(carMarker)) _markers.remove(carMarker);

//         //New marker location
//         carMarker = Marker(
//             markerId: const MarkerId("driverMarker"),
//             position: newPos,
//             icon: BitmapDescriptor.fromBytes(
//                 await getBytesFromAsset('lib/assets/ambulance.png', 200)),
//             anchor: const Offset(0.5, 0.5),
//             flat: true,
//             rotation: bearing,
//             draggable: false);

//         //Adding new marker to our list and updating the google map UI.

    _markers.add(carMarker1);
    mapMarkerSink.add(_markers);
//         //Moving the google camera to the new animated location.
//         controller.animateCamera(CameraUpdate.newCameraPosition(
//             CameraPosition(target: newPos, zoom: 15.5)));
//       });

//     //Starting the animation
//     animationController.forward();
//   }
  }
}
