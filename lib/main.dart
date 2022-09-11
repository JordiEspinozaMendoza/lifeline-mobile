import 'package:flutter/material.dart';
import 'package:hackathonpaciente/providers/screen_provider.dart';
import 'package:hackathonpaciente/screens/emergency_screen.dart';
import 'package:hackathonpaciente/screens/map_screen.dart';
import 'package:hackathonpaciente/widgets/screen_selector.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScreensProvider(),
          lazy: false,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // IO.Socket socket = IO.io('http://192.168.100.16:5051');
    // socket.onConnect((_) {
    //   print('connect');
    //   socket.emit('msg', 'test');
    // });

    // socket.onDisconnect((_) => print('disconnect'));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: EmergencyScreen(),
    );
  }
}
