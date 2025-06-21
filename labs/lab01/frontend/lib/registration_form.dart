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
  bool successful = false;

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
        successful = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement registration form UI
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              key: const Key('name'),
              controller: _nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              validator: (name) {
                if (name==null || name.length == 0) {
                  return "Please enter your name";
                }
                return null;
                },
            ),

            TextFormField(
              key: const Key('email'),
              controller: _emailController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              validator: (email) {
                if (email==null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                  return "Please enter a valid email";
                }
                return null;
                },
            ),

            TextFormField(
              key: const Key('password'),
              controller: _passwordController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              validator: (password) {
                if (password==null || password.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
                },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    key: const Key('submitButton'),
                    onPressed: () {
                      _submitForm();
                      },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(250, 70),
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                    child: Text('Submit', style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),)
                ),
                if (successful)
                  Text('Registration successful!'),
              ],
            )
          ],
        ),
        ),
      ),
    );
  }
}
