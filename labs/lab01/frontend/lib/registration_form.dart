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
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key("name"),
              controller: _nameController,
              decoration: const InputDecoration(labelText: "name"),
              validator: (value) {
                if (value == null || value == "") {
                  return "Please enter your name";
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key("email"),
              controller: _emailController,
              decoration: const InputDecoration(labelText: "email"),
              validator: (value) {
                if (value == null || value == "") {
                  return "Please enter a valid email";
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key("password"),
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "password"),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: _submitForm, child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}
