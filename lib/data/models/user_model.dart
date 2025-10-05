// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String college;
  final String branch;
  final String courseId;
  final String role;
  final String status;
  final String? activeToken;
  final Timestamp? createdAt;
  final Timestamp? lastLogin;
  final String phone;
  final String paymentId;
  final String courseTitle;

  static var currentUser;

  const UserModel( {
    required this.uid,
    required this.name,
    required this.email,
    required this.college,
    required this.branch,
    required this.courseId,
    required this.phone,
    required this.paymentId,
    this.role = 'student',
    this.status = 'pending',
    this.activeToken,
    this.createdAt,
    this.lastLogin,
    required this.courseTitle,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Unknown',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      courseId: (data['courseId'] as String?)?.trim() ?? 'Unknown',
      college: (data['college'] as String?)?.trim() ?? 'Unknown',
      branch: (data['branch'] as String?)?.trim() ?? 'Unknown',
      role: (data['role'] as String?)?.toLowerCase() ?? 'student',
      status: (data['status'] as String?)?.toLowerCase() ?? 'pending',
      activeToken: data['activeToken'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
      phone: data['phone'] as String? ?? '',
      paymentId: data['paymentId'] as String? ?? '',
      courseTitle: data['courseTitle'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'college': college.trim(),
      'branch': branch.trim(),
      'courseId': courseId.trim(),
      'role': role.toLowerCase(),
      'status': status.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'activeToken': activeToken,
      'lastLogin': lastLogin,
      'phone': phone,
      'paymentId': paymentId,
      'courseTitle': courseTitle,
    };
  }

  Map<String, dynamic> toFirestoreUpdate({
    String? name,
    String? email,
    String?college, // CORRECTED
    String?branch, // CORRECTED
    String? courseId,
    String? role,
    String? status,
    String? activeToken,
    String? phone,       // CORRECTED
    String? paymentId,
    String? courseTitle,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name.trim();
    if (email != null) {
      if (!_isValidEmail(email)) throw ArgumentError('Invalid email format: $email');
      updates['email'] = email.trim().toLowerCase();
    }
    if (college != null) updates['college'] = college.trim(); // CORRECTED
    if (branch != null) updates['branch'] = branch.trim(); // CORRECTED
    if (courseId != null) updates['courseId'] = courseId.trim(); // CORRECTED
    if (role != null) updates['role'] = role.toLowerCase();
    if (status != null) updates['status'] = status.toLowerCase();
    if (activeToken != null) updates['activeToken'] = activeToken;
    if (phone != null) updates['phone'] = phone;
    if (paymentId != null) updates['paymentId'] = paymentId;
    if (courseTitle != null) updates['courseTitle'] = courseTitle;
    return updates;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? college, // CORRECTED
    String? branch, // CORRECTED
    String? courseId,
    String? role,
    String? status,
    String? activeToken,
    Timestamp? createdAt,
    Timestamp? lastLogin,
    String? phone,
    String? paymentId,
    String? courseTitle,
  }) {
    return UserModel(
      uid: uid,
      name: name?.trim() ?? this.name,
      email: email?.trim().toLowerCase() ?? this.email,
      college: college?.trim() ?? this.college, // CORRECTED
      branch: branch?.trim() ?? this.branch, // CORRECTED
      courseId: courseId?.trim() ?? this.courseId,
      role: role?.toLowerCase() ?? this.role,
      status: status?.toLowerCase() ?? this.status,
      activeToken: activeToken ?? this.activeToken,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      phone: phone?.toString() ?? this.phone,
      paymentId: paymentId ?? this.paymentId,
      courseTitle: courseTitle ?? this.courseTitle,
    );
  }

  @override
  List<Object?> get props => [
    uid, name, email, college,branch, courseId, role, status,
    activeToken, createdAt, lastLogin, phone, paymentId, courseTitle
  ];
}