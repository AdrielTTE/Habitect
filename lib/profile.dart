import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Get the current user UID and fetch profile data if available
  _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
    if (_user != null) {
      _fetchProfileData();
    }
  }

  // Fetch profile data from Firestore
  _fetchProfileData() async {
    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('profile')
          .doc('profileData')
          .get();

      if (profileDoc.exists) {
        _nameController.text = profileDoc['name'] ?? '';
        _emailController.text = profileDoc['email'] ?? '';
        setState(() {
          _imageUrl = profileDoc['profileImageUrl'];
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  // Pick and upload profile image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = 'profile_${_user!.uid}.jpg';
      try {
        // Upload the image to Firebase Storage
        await FirebaseStorage.instance
            .ref('profile_pictures/$fileName')
            .putFile(imageFile);

        // Get the download URL after uploading
        String downloadUrl = await FirebaseStorage.instance
            .ref('profile_pictures/$fileName')
            .getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl; // Store the image URL
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  // Update profile data in Firestore
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
        'profileImageUrl': _imageUrl ?? '', // If there's no image, store an empty string
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );

      setState(() {
        isEditing = false; // Exit editing mode
      });
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        actions: [
          _user == null
              ? IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
              : IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {
                _user = null;
              });
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: _user == null
            ? const Text('Please log in to view your profile.')
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display Profile Image or placeholder
              _imageUrl == null
                  ? CircleAvatar(
                radius: 50,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
              )
                  : CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imageUrl!),
              ),
              const SizedBox(height: 20),
              // Name and Email TextField (Allow editing)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
              ),
              const SizedBox(height: 20),
              // Edit or Save button
              isEditing
                  ? ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Changes'),
              )
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}