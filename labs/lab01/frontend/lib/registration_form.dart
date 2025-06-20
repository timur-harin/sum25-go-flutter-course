import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _message = "";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    if (email.contains(".") && email.contains("@")) {
      return true;
    }
    return false;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _message = "Registration successful!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
          TextFormField(
            key: const Key("name"),
            controller: _nameController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Enter your name"
            ),
            validator: (value) {
              if (value == null || value == "") {
                return "Please enter your name";
              }
              return null;
            }
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key("email"),
            controller: _emailController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.blue,
              labelText: "Enter your email"
            ),
            validator: (value) {
              if (value == null || value == "" || !isEmailValid(value)) {
                return "Please enter a valid email";
              }
              return null;
            }
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: const Key("password"),
            controller: _passwordController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.red,
              labelText: "Enter your password"
            ),
            validator: (value) {
              if (value == null || value == "" || value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            }
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white
            ),
            child: const Text(
              "Submit"
            )
          ),
          Text(
            _message
          )
      ],
      )
    );
  }  
}