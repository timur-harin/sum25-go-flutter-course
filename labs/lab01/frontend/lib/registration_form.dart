import 'package:flutter/material.dart';


class User{
  String name;
  String email;
  String password;

  User({
    required this.name,
    required this.password,
    required this.email
});
}

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

  User user = User(
      name:"",
      email:"",
      password:"");


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
        const SnackBar(content: Text('Registration successful!')),
      );
    }
    // TODO: Implement form submission
    // if (validate()) {
    //   _formKey.currentState!.save();
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Registration successful!')),
    //   );
    // }
  }

  bool validate(){
    if (user.name.isEmpty || user.name == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return false;
    }
    if (!validEmail(user.email)){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return false;
    }
    if (user.password.length < 6){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return false;
    }
    return true;
  }

  bool validEmail(String email){
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('name'),
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (value) => user.name = value!,
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter your name' : null,
            ),
            TextFormField(
              key: const Key('email'),
              decoration: const InputDecoration(labelText: 'Email'),
              onSaved: (value) => user.email = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid email';
                }
                final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
                if (!regex.hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              key: const Key('password'),
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onSaved: (value) => user.password = value!,
              validator: (value) =>
              value == null || value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
