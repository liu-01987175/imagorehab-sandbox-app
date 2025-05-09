// lib/screens/confirm_code_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/*
  todo:
  1. collect confirmation code
  2. call Cognito confirmSignUp
  3. sign in and navigate to tasks
*/

class ConfirmCodeScreen extends StatefulWidget {
  final String email;
  final String password;
  const ConfirmCodeScreen({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  _ConfirmCodeScreenState createState() => _ConfirmCodeScreenState();
}

class _ConfirmCodeScreenState extends State<ConfirmCodeScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _resendMessage;

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
    try {
      final ok = await AuthService().confirmSignUp(
        widget.email,
        _codeCtrl.text.trim(),
      );
      if (ok) {
        final signedIn = await AuthService().signIn(
          widget.email,
          widget.password,
        );
        if (signedIn) {
          Navigator.pushReplacementNamed(context, '/tasks');
        } else {
          setState(() => _error = 'Confirmed but sign‑in failed');
        }
      } else {
        setState(() => _error = 'Invalid confirmation code');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    try {
      await AuthService().resendConfirmationCode(widget.email);
      setState(() => _resendMessage = 'Code resent to your email.');
    } catch (e) {
      setState(() => _resendMessage = 'Resend failed: $e');
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Enter Confirmation Code')),
      body: LayoutBuilder(
        builder:
            (ctx, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Confirmation Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _confirm,
                              child:
                                  _loading
                                      ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Confirm & Sign In'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Resend button
                          TextButton(
                            onPressed: _resendCode,
                            child: const Text(
                              'Resend code',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          if (_resendMessage != null) ...[
                            Text(
                              _resendMessage!,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Back to Create Account
                          TextButton(
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  ctx,
                                  '/signup',
                                ),
                            child: const Text(
                              'Back to Create Account',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
