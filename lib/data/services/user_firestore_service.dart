import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserFirestoreService {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<bool> createUser(Map<String, dynamic> userData, String userId) async {
    try {
      await _usersCollection.doc(userId).set(userData);
      return true;
    } catch (e) {
      debugPrint('Error createUser: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getUser: $e');
      return null;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData, String userId) async {
    try {
      await _usersCollection.doc(userId).update(userData);
      return true;
    } catch (e) {
      debugPrint('Error updateUser: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleteUser: $e');
      return false;
    }
  }

  // get id user by email
}
