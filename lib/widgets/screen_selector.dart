import 'package:flutter/material.dart';
import 'package:hackathonpaciente/providers/screen_provider.dart';
import 'package:provider/provider.dart';

class ScreenSelector extends StatefulWidget {
  const ScreenSelector({Key? key}) : super(key: key);

  @override
  State<ScreenSelector> createState() => _ScreenSelectorState();
}

class _ScreenSelectorState extends State<ScreenSelector> {
  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider =
        Provider.of<ScreensProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    screensProvider.selectedEmergencyPage = true;
                    screensProvider.selectedProfilePage = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                    primary: screensProvider.selectedEmergencyPage
                        ? Colors.lightBlueAccent
                        : Colors.grey),
                child: const Text(
                  'Emergency Call',
                )),
          ),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    screensProvider.selectedEmergencyPage = false;
                    screensProvider.selectedProfilePage = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                    primary: screensProvider.selectedProfilePage
                        ? Colors.lightBlueAccent
                        : Colors.grey),
                child: const Text(
                  'Profile',
                )),
          ),
        ],
      ),
    );
  }
}
