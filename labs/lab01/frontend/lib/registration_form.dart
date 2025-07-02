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
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }
  }

  Color darkBlue = const Color.fromARGB(105, 127, 159, 192);

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration = InputDecoration(
      hint: const Text("Input name"),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      errorStyle:
          Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 2, color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      errorMaxLines: 2,
      fillColor: darkBlue,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.only(left: 16),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration Form"),
      ),
      body: Column(
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('name'),
                    decoration: inputDecoration,
                    controller: _nameController,
                    validator: (value) {
                      if (value == "") {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    key: const Key('email'),
                    decoration: inputDecoration,
                    controller: _emailController,
                    validator: (value) {
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

                      if (value == null) {
                        return "Please enter a valid email";
                      } else if (!emailRegex.hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    key: const Key('password'),
                    decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                    controller: _passwordController,
                    obscureText: true,
                    
                    validator: (value) {
                      if (value == null) {
                        return "Password must be at least 6 characters";
                      } else if (value.length <= 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ],
              )),
          ElevatedButton(
            onPressed: () => _submitForm(),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue),
                child: const Text("Submit")),
          ),
        ],
      ),
    );
  }
}
