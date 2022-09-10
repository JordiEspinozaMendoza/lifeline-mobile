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
    socket = IO.io("http://192.168.100.26:5051", <String, dynamic>{
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

      socket.on("search__ambulance", (msg) {
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

  Future<LocationData> RecuperarLocation(
      Location location, var _locationData) async {
    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    var location = Location();
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(socket.connected ? "Conected to the server" : "Disconnected"),
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
                  return Center(
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: Material(
                        borderRadius: BorderRadius.circular(130),
                        color: Colors.white,
                        elevation: 3,
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.health_and_safety_outlined,
                            size: 120,
                          ),
                          onPressed: () {
                            _locationData = snapshot.data;

                            print(_locationData.latitude);
                            print(_locationData.longitude);

                            var location = {
                              "latitude": _locationData.latitude,
                              "longitude": _locationData.longitude,
                            };
                            print(location);
                            socket.emit(
                                'request__ambulance', {"location": location});

                            // set up the button

                            // set up the AlertDialog

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
                          },
                          backgroundColor: Color.fromARGB(175, 203, 46, 231),
                        ),
                      ),
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
