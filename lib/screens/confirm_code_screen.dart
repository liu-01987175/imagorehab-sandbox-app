import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConfirmCodeScreen extends StatefulWidget {
  const ConfirmCodeScreen({Key? key}) : super(key: key);
  @override
  _ConfirmCodeScreenState createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  late final String email;
  late final String password;
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    email = args['email']!;
    password = args['password']!;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await AuthService().confirmSignUp(email, _codeCtrl.text.trim());
    if (!ok) {
      setState(() {
        _error = 'Confirmation failed';
        _loading = false;
      });
      return;
    }
    await AuthService().signIn(email, password);
    Navigator.pushReplacementNamed(context, '/tasks');
  }

  Future<void> _resend() async {
    await AuthService().resendConfirmationCode(email);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code resent')));
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Confirmation Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _confirm,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('Confirm'),
            ),
            TextButton(onPressed: _resend, child: const Text('Resend code')),
          ],
        ),
      ),
    );
  }
}
