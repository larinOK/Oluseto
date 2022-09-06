import 'package:flutter/material.dart';

class FormInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final String hint;
  final TextInputType textInputType;
  final bool obscureText;
  final IconData icon;
  //final String? Function(String?)? validator;

  const FormInputWidget(this.controller, this.textInputAction,
      this.textInputType, this.hint, this.obscureText, this.icon,
      //this.validator,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      obscureText: obscureText,
      keyboardType: textInputType,
      //validator: validator,
      onSaved: (value) {
        controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
