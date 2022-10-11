import 'package:flutter/material.dart';

class TextInsert extends StatelessWidget {
  TextInsert(
      {super.key,
      required this.icono,
      required this.hintText,
      this.textoInsert});
  final Icon icono;
  final String hintText;
  String? textoInsert;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: InputDecoration(
          iconColor: Color(0xff8fb9fc),
          icon: icono,
          hintText: hintText,
        ),
        onChanged: (value) {
          textoInsert = value;
        },
      ),
    );
  }
}
