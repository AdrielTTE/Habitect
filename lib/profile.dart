import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // For loading asset images

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String? _imageUrl;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool isEditing = false;
  bool hasChosenPhoto = false;
  bool isPasswordChangeRequested = false;

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
        _phoneController.text = doc['phone'] ?? '';
        _dobController.text = doc['dob'] ?? '';
        _bioController.text = doc['bio'] ?? '';
        _imageUrl = doc['profileImageUrl'] ?? '';
        hasChosenPhoto = _imageUrl != null && _imageUrl!.isNotEmpty;
        _emailController.text = _user!.email ?? '';
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _pickImageFromAssets() async {
    if (hasChosenPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only choose your profile photo once.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Choose Profile Image"),
          children: <Widget>[
            SimpleDialogOption(
              child: Image.asset('assets/images/p1.jpg'),
              onPressed: () {
                setState(() {
                  _imageUrl = 'assets/images/p1.jpg';
                  hasChosenPhoto = true;
                });
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Image.asset('assets/images/p2.jpg'),
              onPressed: () {
                setState(() {
                  _imageUrl = 'assets/images/p2.jpg';
                  hasChosenPhoto = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && _newPasswordController.text.isNotEmpty) {
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password changed successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a valid password")),
        );
      }
    } catch (e) {
      print("Error changing password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to change password")),
      );
    }
  }

  bool _isPhoneNumberValid(String phone) {
    return phone.length >= 11 && phone.length <= 13 && RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  Future<void> _updateProfileData() async {
    if (_user == null) return;

    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _dobController.text.isEmpty || _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_isPhoneNumberValid(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be between 11 and 13 digits')),
      );
      return;
    }

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

  Future<void> _askChangePassword() async {
    bool? changePassword = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Text('Do you want to change your password?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (changePassword == true) {
      setState(() {
        isPasswordChangeRequested = true;
      });
    } else {
      setState(() {
        isPasswordChangeRequested = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null
          ? const Center(child: Text("Please log in."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditing ? _pickImageFromAssets : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageUrl != null && _imageUrl!.isNotEmpty
                    ? AssetImage(_imageUrl!)
                    : AssetImage('assets/images/default_profile.png'),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Name'),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Your email is tied to your account and cannot be modified.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            _buildTextField(_emailController, 'Email', readOnly: true),
            _buildTextField(_phoneController, 'Phone Number', type: TextInputType.phone),
            _buildTextField(_dobController, 'Date of Birth', readOnly: true,
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
              onPressed: _updateProfileData,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.orange),
              ),
              child: const Text("Save Changes"),
            )
                : ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.orange),
              ),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _askChangePassword,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.orange),
              ),
              child: const Text("Change Password"),
            ),
            if (isPasswordChangeRequested)

              Column(
                children: [
                  SizedBox(height:40),
                  TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x4DFFB84D) ,
                      labelText: "New Password",
                    ),
                  ),
                  SizedBox(height:20),
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                    ),
                    child: const Text("Save New Password"),
                  ),
                ],
              ),
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
          filled: true,
          fillColor: Color(0x4DFFB84D) ,
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
