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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    List<String> errors = [];
    if (_passwordController.text.length < 6) {
      errors.add('Password must be at least 6 characters\n');
    }

    if (_nameController.text.isEmpty) {
      errors.add('Please enter your name\n');
    }

    if (_nameController.text.isEmpty || !isValidEmail(_emailController.text)) {
      errors.add('Please enter a valid email\n');
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errors.join())));
      return;
    }

    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')));
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hint: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
              hint: Text(
            'Email',
            style: TextStyle(fontWeight: FontWeight.w300),
          )),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            hint: Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
          obscureText: true,
        ),
        TextButton(onPressed: _submitForm, child: const Text('Submit'))
      ],
    );
  }
}
