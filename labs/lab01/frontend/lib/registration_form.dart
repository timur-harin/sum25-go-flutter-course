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

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _submitForm() {
    setState(() {
      _nameError = _emailError = _passwordError = _successMessage = null;

      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      bool hasError = false;

      if (name.isEmpty) {
        _nameError = 'Please enter your name';
        hasError = true;
      }

      if (email.isEmpty || !isValidEmail(email)) {
        _emailError = 'Please enter a valid email';
        hasError = true;
      }

      if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        hasError = true;
      }

      if (!hasError) {
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _successMessage = 'Registration successful!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('name'),
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Name',
            errorText: _nameError,
          ),
        ),
        TextField(
          key: const Key('email'),
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            errorText: _emailError,
          ),
        ),
        TextField(
          key: const Key('password'),
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            errorText: _passwordError,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _submitForm,
          child: const Text('Submit'),
        ),
        if (_successMessage != null)
          Text(
            _successMessage!,
            key: const Key('successMessage'),
            style: const TextStyle(color: Colors.green),
          ),
      ],
    );
  }
}
