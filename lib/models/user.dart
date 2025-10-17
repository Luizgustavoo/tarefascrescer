import 'package:tarefas_projetocrescer/models/user_type.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;

  final UserType? userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,

    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userTypeData = json['user_type'];

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],

      userType: userTypeData != null && userTypeData is Map<String, dynamic>
          ? UserType.fromJson(userTypeData)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType?.toJson(), // Chama o toJson do UserType
    };
  }
}
