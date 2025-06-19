import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              key: const Key("name"),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
              validator: (name) {
                if (name == null || name.isEmpty) {
                  return "Please enter your name";
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key("email"),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              validator: (email) {                
                if (
                  email == null ||
                  email.isEmpty ||
                  !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email)
                ) {
                  return "Please enter a valid email";
                }
                
                return null;
              },
            ),
            TextFormField(
              key: const Key("password"),
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              validator: (password) {
                if (password == null || password.isEmpty || password.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Submit"),
            ),
          ]
        )
      )
    );
  }
}
