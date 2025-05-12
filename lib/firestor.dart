import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'notes_model.dart';

class Firestore_Datasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new user in Firestore
  Future<bool> CreateUser(String email) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "id": _auth.currentUser!.uid,
        "email": email,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Adds a new note to Firestore
  Future<bool> AddNote(String subtitle, String title, int image) async {
    try {
      String uuid = Uuid().v4();
      DateTime now = DateTime.now();
      String formattedTime = DateFormat('hh:mm a').format(now);

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .set({
        'id': uuid,
        'subtitle': subtitle,
        'isDon': false,
        'image': image,
        'time': formattedTime,
        'title': title,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Converts snapshot data into a list of notes
  List<Note> getNotes(AsyncSnapshot snapshot) {
    try {
      return snapshot.data!.docs.map<Note>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Note(
          data['id'],
          data['subtitle'],
          data['time'],
          data['image'],
          data['title'],
          data['isDon'],
        );
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Streams notes based on their completion status
  Stream<QuerySnapshot> stream(bool isDone) {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('notes')
        .where('isDon', isEqualTo: isDone)
        .snapshots();
  }

  /// Updates the completion status and time of a note
  Future<bool> updateTaskStatusAndTime(
      String uuid, bool isDon, String updatedTime) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({
        'isDon': isDon,
        'time': updatedTime,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Updates the completion status only (if needed separately)
  Future<bool> isdone(String uuid, bool isDon) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({'isDon': isDon});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Updates the note content
  Future<bool> Update_Note(
      String uuid, int image, String title, String subtitle) async {
    try {
      DateTime now = DateTime.now();
      String formattedTime = DateFormat('hh:mm a').format(now);

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({
        'time': formattedTime,
        'subtitle': subtitle,
        'title': title,
        'image': image,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Deletes a note from Firestore
  Future<bool> delet_note(String uuid) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
