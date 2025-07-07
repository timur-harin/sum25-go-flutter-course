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
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _successMessage = 'Registration successful!';
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('name'),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('email'),
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a valid email';
                  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                  if (!regex.hasMatch(value.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('password'),
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('submitButton'),
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _successMessage!,
                  key: const Key('successMessage'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}