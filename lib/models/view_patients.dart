// To parse this JSON data, do
//
//     final patients = patientsFromMap(jsonString);

import 'dart:convert';

class Patients {
  Patients({
    this.id,
    this.name,
    this.lastName,
    this.age,
    this.disease,
  });

  int? id;
  String? name;
  String? lastName;
  int? age;
  String? disease;

  factory Patients.fromJson(String str) => Patients.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Patients.fromMap(Map<String, dynamic> json) => Patients(
        id: json["id"],
        name: json["name"],
        lastName: json["lastName"],
        age: json["age"],
        disease: json["disease"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "lastName": lastName,
        "age": age,
        "disease": disease,
      };
}
