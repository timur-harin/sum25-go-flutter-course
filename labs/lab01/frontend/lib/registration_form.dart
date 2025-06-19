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
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      setState(() {
        _isSuccess = true;
      });
      print('Registration successful!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement registration form UI
    return Container(
      child: Form (
        key: _formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSuccess && _formKey.currentState?.validate() == true)
          const Text(
            'Registration successful!'
          ),
          TextFormField(
            key: Key("name"),
            decoration: InputDecoration(labelText: 'Please enter your name'),
            controller: _nameController,
          ),
          TextFormField(
            key: Key("email"),
            decoration: InputDecoration(labelText: 'Please enter a valid email'),
            controller: _emailController,
          ),
          TextFormField(
            key: Key("password"),
            decoration: InputDecoration(labelText: 'Password must be at least 6 characters'),
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Inncorrect password!';
              }
              return null;
            },
          ),
          ElevatedButton(onPressed: _submitForm, child: Text('Submit'))
        ]
        )
      )
    );
  }
}
