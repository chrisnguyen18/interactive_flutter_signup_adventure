import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

class SignupScreen extends StatefulWidget {
  // ... all the code for SignupScreen and _SignupScreenState ...
  
  void _submitForm() {
    // ...
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(userName: _nameController.text),
      ),
    );
    // ...
  }
  // ...
}