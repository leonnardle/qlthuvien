import 'package:flutter/material.dart';

class FormValidator {
  static bool checkValidateAndSave(GlobalKey<FormState> key) {
    final form = key.currentState;
    if (form != null && form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
