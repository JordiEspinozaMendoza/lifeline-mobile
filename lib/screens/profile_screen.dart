import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/screen_selector.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 120,
                  ),
                  onPressed: () {
                    // set up the button

                    // set up the AlertDialog
                  },
                  backgroundColor: Color.fromARGB(175, 203, 46, 231),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
