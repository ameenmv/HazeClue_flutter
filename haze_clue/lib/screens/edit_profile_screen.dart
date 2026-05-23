import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();
      setState(() {
        _nameController.text = profile['fullName'] ?? '';
        _nicknameController.text = profile['nickname'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phoneNumber'] ?? '';
        _countryController.text = profile['country'] ?? '';
        _addressController.text = profile['address'] ?? '';
        
        String genderVal = profile['gender']?.toString() ?? '';
        if (genderVal == '0') {
          _genderController.text = 'Female';
        } else if (genderVal == '1') {
          _genderController.text = 'Male';
        } else {
          _genderController.text = genderVal;
        }
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updateProfile(
        fullName: _nameController.text,
        nickname: _nicknameController.text,
        phoneNumber: _phoneController.text,
        country: _countryController.text,
        address: _addressController.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit profile",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: textColor)) 
              : GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        GlassTextField(
                          label: "Full name",
                          hint: "Enter your full name",
                          controller: _nameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          label: "Nick name",
                          hint: "Enter your nickname",
                          controller: _nicknameController,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          label: "Email",
                          hint: "Enter your email",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          label: "Phone number",
                          hint: "Enter your phone number",
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GlassTextField(
                                label: "Country",
                                hint: "Country",
                                controller: _countryController,
                                icon: Icons.public,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassTextField(
                                label: "Gender",
                                hint: "Gender",
                                controller: _genderController,
                                icon: Icons.wc,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          label: "Address",
                          hint: "Enter your address",
                          controller: _addressController,
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 40),
                        GlassButton(
                          text: "SUBMIT",
                          onPressed: _saveProfile,
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
