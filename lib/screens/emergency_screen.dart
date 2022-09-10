import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/screen_selector.dart';
import 'package:location/location.dart';

class EmergencyScreen extends StatefulWidget {
  EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late IO.Socket socket;
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
      print("Connected");
      socket.emit('user__joined');

      socket.on("success__request__ambulance", (msg) {
        print(msg);
      });

      socket.on("error__request__ambulance", (msg) {
        print(msg);
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

  Future<LocationData> RecuperarLocation(Location location) async {
    return await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    var location = Location();
    bool _serviceEnabled = false;
    PermissionStatus _permissionGranted = PermissionStatus.denied;
    LocationData _locationData;

    CheckServices(
      location,
      _serviceEnabled,
      _permissionGranted,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Lifeline'),
      ),
      body: Column(
        children: [
          ScreenSelector(),
          SizedBox(
            height: 150,
          ),
          Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Material(
                borderRadius: BorderRadius.circular(130),
                color: Colors.white,
                elevation: 3,
                child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(175, 203, 46, 231),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 120,
                  ),
                  onPressed: () {
                    _locationData = RecuperarLocation(location) as LocationData;
                    print(_locationData.latitude);
                    print(_locationData.longitude);

                    socket.emit('request__ambulance', {});

                    // set up the button

                    // set up the AlertDialog
                    FutureBuilder(
                        future: RecuperarLocation(location),
                        builder: (BuildContext context, snapshot) {
                          if (!snapshot.hasData) {
                            return SnackBar(
                              content: Text(
                                'We couldnt find your location',
                              ),
                            );
                          } else {
                            AlertDialog alert = AlertDialog(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(29)),
                              insetPadding: EdgeInsets.symmetric(
                                  vertical: 250, horizontal: 80),
                              clipBehavior: Clip.antiAlias,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text("Loading..."),
                                  LoadingAnimationWidget.prograssiveDots(
                                    color: Colors.lightBlueAccent,
                                    size: 89,
                                  ),
                                ],
                              ),
                              actions: [],
                            );

                            // show the dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                            setState(() {
                              _locationData = snapshot.data as LocationData;
                            });
                            print(_locationData.latitude);
                            print(_locationData.latitude);
                            return Container();
                          }
                        });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
