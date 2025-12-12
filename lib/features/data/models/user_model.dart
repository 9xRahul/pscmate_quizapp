import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';



class UserModel extends AuthUser {
  const UserModel({
    required String uid,
    String? email,
    String? name,
    String? phoneNumber,
    int? age,
    String? qualification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
         uid: uid,
         email: email,
         name: name,
         phoneNumber: phoneNumber,
         age: age,
         qualification: qualification,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      name: map['name'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      age: map['age'] is int
          ? map['age'] as int
          : (map['age'] != null ? int.tryParse(map['age'].toString()) : null),
      qualification: map['qualification'] as String?,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : (map['createdAt'] != null
                ? DateTime.tryParse(map['createdAt'].toString())
                : null),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : (map['updatedAt'] != null
                ? DateTime.tryParse(map['updatedAt'].toString())
                : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'qualification': qualification,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
