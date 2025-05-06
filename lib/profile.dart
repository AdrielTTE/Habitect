import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String? _imageUrl;
  File? _localImageFile;

  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await _fetchProfileData();
    }
    setState(() {});
  }

  Future<void> _fetchProfileData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('profileData')
          .get();

      if (doc.exists) {
        _nameController.text = doc['name'] ?? '';
        _emailController.text = doc['email'] ?? '';
        _phoneController.text = doc['phone'] ?? '';
        _dobController.text = doc['dob'] ?? '';
        _bioController.text = doc['bio'] ?? '';
        _imageUrl = doc['profileImageUrl'] ?? '';
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    setState(() {
      _localImageFile = imageFile;
    });

    String fileName = 'profile_${_user!.uid}.jpg';

    try {
      // Upload image to Firebase Storage
      await FirebaseStorage.instance
          .ref('profile_pictures/$fileName')
          .putFile(imageFile);

      // Get download URL
      final downloadUrl = await FirebaseStorage.instance
          .ref('profile_pictures/$fileName')
          .getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });

      // Save URL to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('profileData')
          .set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('profileData')
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'bio': _bioController.text,
        'profileImageUrl': _imageUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated')),
      );

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      print("Firestore error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {
                _user = null;
              });
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: _user == null
          ? const Center(child: Text("Please log in."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _localImageFile != null
                    ? FileImage(_localImageFile!)
                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                    ? NetworkImage(_imageUrl!)
                    : null,
                child: (_imageUrl == null || _imageUrl!.isEmpty) &&
                    _localImageFile == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_phoneController, 'Phone Number',
                type: TextInputType.phone),
            _buildTextField(_dobController, 'Date of Birth',
                readOnly: true,
                onTap: isEditing
                    ? () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _dobController.text =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                }
                    : null),
            _buildTextField(_bioController, 'Bio', maxLines: 3),
            const SizedBox(height: 20),
            isEditing
                ? ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Save Changes"))
                : ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                child: const Text("Edit Profile")),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false,
        void Function()? onTap,
        int maxLines = 1,
        TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: isEditing,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: type,
      ),
    );
  }
}
