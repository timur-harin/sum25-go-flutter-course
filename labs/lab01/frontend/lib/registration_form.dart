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
    // TODO: Implement form submission
    if(_formKey.currentState!.validate()){
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final pwd = _passwordController.text;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));

      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();


    }

  }

  String? _validateName(String? name){
    if(name == null || name.trim().isEmpty){
      return "Please enter your name";
    } else{
      return null;
    }
  }

  String? _validateEmail(String? email){
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email!.trim()) || email == null || email.trim().isEmpty) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? psw){
    if( psw!.length < 6 || psw.trim().isEmpty || psw == null){
      return "Password must be at least 6 characters";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement registration form UI
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key("name"),
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Name"
                ),
                validator: _validateName,
              ),
              TextFormField(
                key: const Key("email"),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email"
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              TextFormField(
                key: const Key("password"),
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: "Password"
                ),
                validator: _validatePassword,
                obscureText: true,
              ),
              ElevatedButton(onPressed: _submitForm, child: const Text("Submit"))
            ]
          )

      ),

    );
  }
}
