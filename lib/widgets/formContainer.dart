import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;

  const FormContainerWidget({
    Key? key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
  }) : super(key: key);

  @override
  _FormContainerWidgetState createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIcon:
              _getPrefixIcon(), // Appel de la fonction pour obtenir l'icône préfixe
          suffixIcon:
              _getSuffixIcon(), // Appel de la fonction pour obtenir l'icône suffixe
        ),
      ),
    );
  }

  // Fonction pour obtenir l'icône préfixe en fonction du hintText
  Widget? _getPrefixIcon() {
    switch (widget.hintText) {
      case 'Email':
        return Icon(Icons.email, color: Colors.black);
      case 'Password':
        return Icon(Icons.lock, color: Colors.black);
      default:
        return Icon(Icons.person, color: Colors.black);
    }
  }

  // Fonction pour obtenir l'icône suffixe pour les champs de mot de passe
  Widget? _getSuffixIcon() {
    if (widget.isPasswordField == true) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _obscureText == false ? Colors.blue : Colors.grey,
        ),
      );
    }
    return null;
  }
}
