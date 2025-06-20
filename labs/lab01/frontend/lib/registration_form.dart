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
  var _succes = "";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    setState(() {
      _succes = "Registration successful!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, child: Column(
      children: [
        TextFormField(
          key: Key('name'),
          decoration: const InputDecoration(labelText: "Name"),
          validator: (value) {
            if (value == null || value.isEmpty){
              return "Please enter your name";
            }
            return null;
          },
          onSaved: (value) => _nameController.text = value!,
        ),
        TextFormField(
          key: Key('email'),
          decoration: const InputDecoration(labelText: "email"),
          validator: (value) {
            if (value == null || value.isEmpty){
              return "Please enter a valid email";
            }
            else if (!value.contains("@")){
              return "Please enter a valid email";
            }
            return null;
          },
          onSaved: (value) => _emailController.text = value!,
        ),
        TextFormField(
          key: Key('password'),
          decoration: const InputDecoration(labelText: "password"),
          validator: (value) {
            if (value == null || value.isEmpty){
              return "Password must be at least 6 characters";
            }
            if (value.length < 6){
              return "Password must be at least 6 characters";
            }
            return null;
          },
          onSaved: (value) => _passwordController.text = value!,
        ),
        ElevatedButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _submitForm();
          }
        }, child: const Text("Submit")),
        Text(_succes)
      ],
    )
    );
  }
}
