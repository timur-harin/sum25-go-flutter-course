import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key}); // IntelliSense suggestion

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _message = "Registration successful!";
      });

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Registration Form"),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name text field
                TextFormField(
                  key: const Key("name"),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Name",
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // Email text field
                TextFormField(
                  key: const Key("email"),
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a valid email";
                    }

                    if (!value.contains('@') || !value.contains('.')) {
                      return "Please enter a valid email";
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // Password text field
                TextFormField(
                  key: const Key("password"),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must be at least 6 characters";
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Password",
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                    onPressed: _submitForm, child: const Text("Submit")),

                const SizedBox(height: 20),

                Text(_message),
              ],
            ),
          ),
        ));
  }
}
