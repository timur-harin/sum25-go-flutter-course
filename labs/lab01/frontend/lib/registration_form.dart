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
  bool _submitted = false;

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
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
        return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('name'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if ('$value'.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key('email'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch('$value')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key('password'),
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if ('$value'.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
            if (_submitted) ...[
              const SizedBox(height: 16),
              const Text('Registration successful!'),
            ],
          ],
        ),
      ),
    );
  }
}
