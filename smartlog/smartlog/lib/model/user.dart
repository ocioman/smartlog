import 'package:json_annotation/json_annotation.dart';
import 'package:progettotps/model/sessione.dart';

part 'generated/user.g.dart';

@JsonSerializable()
class User {
  final int userID;
  final String name1;
  final String? name2;
  final String surname1;
  final String? surname2;
  final String email;
  final String password;

  final List<Sessione>? sessioni; // Relazione N:N

  User({
    required this.userID,
    required this.name1,
    this.name2,
    required this.surname1,
    this.surname2,
    required this.email,
    required this.password,
    this.sessioni,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}