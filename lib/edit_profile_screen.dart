import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextrade/widgets.dart';
import 'package:nextrade/profilr_model.dart';
import 'hive_service.dart';
import 'app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? imagePath;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // 🔥 LOAD EXISTING DATA FROM HIVE
    final profile = HiveService.getProfile();

    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      imagePath = profile.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // 🔥 IMAGE PICKER
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        imagePath = picked.path;
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 SAVE PROFILE
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => isSaving = true);

    await HiveService.saveProfile(
      ProfileModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        imagePath: imagePath,
      ),
    );

    setState(() => isSaving = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔥 PROFILE IMAGE
            GestureDetector(
              onTap: _showImageOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: NexTradeColors.primary,
                    backgroundImage:
                    imagePath != null ? FileImage(File(imagePath!)) : null,
                    child: imagePath == null
                        ? Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          .substring(0, 2)
                          .toUpperCase()
                          : "NA",
                      style: const TextStyle(
                        color: NexTradeColors.background,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NexTradeColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: NexTradeColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: NexTradeColors.background),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _buildField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 16),

            _buildField("Email", _emailController, Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            _buildField("Phone", _phoneController, Icons.phone_outlined,
                keyboardType: TextInputType.phone),

            const SizedBox(height: 32),

            NexButton(
              text: 'Save Changes',
              isLoading: isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: NexTradeColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: NexTradeColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon:
            Icon(icon, color: NexTradeColors.textMuted, size: 20),
          ),
        ),
      ],
    );
  }
}