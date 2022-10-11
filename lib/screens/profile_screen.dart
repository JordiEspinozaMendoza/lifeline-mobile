import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hackathonpaciente/providers/pacientes_provider.dart';
import 'package:hackathonpaciente/widgets/text_form_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/screen_provider.dart';
import '../widgets/screen_selector.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> Calc() async {
    http.Response response = await http
        .get(Uri.parse('https://lifeline-hack.herokuapp.com/api/patient/'));

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider =
        Provider.of<ScreensProvider>(context, listen: false);
    final PatientsProvider pacienteVar =
        Provider.of<PatientsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifeline'),
      ),
      body: FutureBuilder(
          future: (Calc()),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            return Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 12, right: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextInsert(
                        icono: Icon(Icons.person),
                        hintText: 'Name',
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      TextInsert(
                        icono: Icon(Icons.person_add),
                        hintText: 'Last Name',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextInsert(
                        icono: Icon(Icons.person_pin),
                        hintText: 'Age',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextInsert(
                        icono: Icon(Icons.sick),
                        hintText: 'Sickness',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
