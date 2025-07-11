import 'package:flutter/material.dart';

import 'package:talk/services/auth_service.dart';

class RegisterWidget extends StatelessWidget {
  const RegisterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var enteredEmail = '';
    var enteredPassword = '';
    var enteredUsername = '';

    var color = Theme.of(context).colorScheme.surface;
    final formKey = GlobalKey<FormState>();

    void submit() async {
      final authService = AuthService();
      final isValid = formKey.currentState!.validate();

      if (!isValid) {
        return;
      }

      formKey.currentState!.save();

      try {
        authService.signUpWithEmailPassword(
          enteredEmail,
          enteredPassword,
          enteredUsername,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 30,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          width: 200,
          child: Icon(Icons.favorite, size: 70, color: Colors.pink),
        ),
        Text(
          'Hello, Let\'s Talk!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 30),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    style: TextStyle(color: color),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: color),
                      labelText: 'Username',
                      labelStyle: TextStyle(color: color),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 2.0),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 4) {
                        return 'Username must be atleast 4 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredUsername = value!;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(color: color),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: color),
                      labelText: 'Email',
                      labelStyle: TextStyle(color: color),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 2.0),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter the correct email address.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredEmail = value!;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(color: color),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: color),
                      prefixIcon: Icon(Icons.lock, color: color),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 2.0),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70.0),
                        borderSide: BorderSide(color: color, width: 1.5),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 8) {
                        return 'Password must be atleast 8 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredPassword = value!;
                    },
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70.0),
                        ),
                      ),
                      child: Text('SIGNUP', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
