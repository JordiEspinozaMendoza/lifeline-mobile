import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackathonpaciente/models/view_patients.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class PatientsProvider extends ChangeNotifier {
  final String? nombre;
  final String? apellido;
  final int? edad;
  final String? enfermedad;

  PatientsProvider({
    this.nombre,
    this.apellido,
    this.edad,
    this.enfermedad,
  });

  factory PatientsProvider.fromJson(Map<String, dynamic> json) {
    return PatientsProvider(
      nombre: json['name'],
      apellido: json['lastName'],
      edad: json['age'],
      enfermedad: json['disease'],
    );
  }
  Future<Patients> fetchPost() async {
    http.Response response = await http
        .get(Uri.parse('https://lifeline-hack.herokuapp.com/api/patient/'));
    return Patients.fromJson(jsonDecode(response.body));
  }
}
