import 'package:flutter/material.dart';
import 'package:mobilino_app/styles/colors.dart';

Widget customTextField(
    {String? title,
    bool? enable,
      bool? auto,

    TextInputType? keyboardType,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
        autofillHints: (auto != null) ? [AutofillHints.username] : null,
          validator: (value) {
            if (value == null || value.isEmpty) return "champs vide !";
          },
          enabled: enable,
          cursorColor: primaryColor,
          keyboardType: keyboardType,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldPassword(
    {String? title,
    bool? enable,
    bool? autoComplete,
    TextInputType? keyboardType,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) return "champs vide !";
          },
          autocorrect: (autoComplete != null) ? autoComplete : false,
          enabled: enable,
          cursorColor: primaryColor,
          keyboardType: keyboardType,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldActivity(
    {String? title,
    bool? enable,
    required VoidCallback reload,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          onChanged: (val) {
            reload();
          },
          validator: (value) {
            if (value == null || value.isEmpty) return "champs vide !";
          },
          enabled: enable,
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldParameter(
    {String? title,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) return "champs vide !";
          },
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration: txtInputDecoration.copyWith(labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

const txtInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: Color(0xff049a9b),
    width: 2,
  )),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff808080), width: 2)),
  errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffff0000), width: 2)),
);

Widget customTextFieldEmpty(
    {String? title,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          onChanged: (val) {},
          validator: (value) {
            // if (value == null || value.isEmpty)
            //   return "champs vide !";
          },
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldEmptyMulti(
    {String? title,
    String? hint,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 20}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          onChanged: (val) {},
          validator: (value) {
            // if (value == null || value.isEmpty)
            //   return "champs vide !";
          },
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldEmptyActivity(
    {String? title,
    String? hint,
    required VoidCallback reload,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          onChanged: (val) {
            reload();
          },
          validator: (value) {
            // if (value == null || value.isEmpty)
            //   return "champs vide !";
          },
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}

Widget customTextFieldEmptyActivityContacts(
    {String? title,
    String? hint,
    bool? enable,
    TextEditingController? controller,
    Icon? icon,
    required bool obscure,
    int? maxLines = 1}) {
  return Column(
    children: [
      // Container(
      //   alignment: Alignment.centerLeft,
      //   child: Text(
      //     title!,
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: black,
      //     ),
      //   ),
      // ),
      TextFormField(
          enabled: enable,
          onChanged: (val) {},
          validator: (value) {
            // if (value == null || value.isEmpty)
            //   return "champs vide !";
          },
          cursorColor: primaryColor,
          obscureText: obscure,
          controller: controller,
          maxLines: maxLines,
          decoration:
              txtInputDecoration.copyWith(prefixIcon: icon, labelText: hint)
          // InputDecoration(hintText: hint, border: InputBorder.none, prefixIcon: icon),
          )
    ],
  );
}
