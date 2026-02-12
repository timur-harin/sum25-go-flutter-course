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
        SnackBar(content: Text('Registration successful!')),
      );

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Registration Form"),
            SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        key: const Key('name'),
                        controller: _nameController,
                        decoration: InputDecoration(
                            label: Text("Name")
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        key: const Key('email'),
                        controller: _emailController,
                        decoration: InputDecoration(
                            label: Text("E-Mail")
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid email';
                          }

                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                          key: const Key('password'),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              label: Text("Password")
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password must be at least 6 characters';
                            }

                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }

                            return null;
                          }
                      ),
                      Center(
                        child: ElevatedButton(onPressed: _submitForm, child: Text("Submit")),
                      )
                    ],
                  ),
                )
            )
          ],
        )
      ),
    );
  }
}
