import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/glass_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      showGlassToast(context, "Please fill all fields");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      showGlassToast(context, "Password changed successfully", isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassTextField(
                      label: "Current Password",
                      hint: "Enter current password",
                      controller: _currentPasswordController,
                      isPassword: true,
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 24),
                    GlassTextField(
                      label: "New Password",
                      hint: "Enter new password",
                      controller: _newPasswordController,
                      isPassword: true,
                      icon: Icons.lock_reset,
                    ),
                    const SizedBox(height: 48),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : GlassButton(
                            text: "CHANGE PASSWORD",
                            onPressed: _submit,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
