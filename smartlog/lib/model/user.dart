import 'package:json_annotation/json_annotation.dart';
import 'package:progettotps/model/allenamento.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final int userID;
  final String name1;
  final String? name2;
  final String surname;
  final String email;

  final List<Allenamento>? allenamenti; // Relazione N:N

  User({
    required this.userID,
    required this.name1,
    this.name2,
    required this.surname,
    required this.email,
    this.allenamenti,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}