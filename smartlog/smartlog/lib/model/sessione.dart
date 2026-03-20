import 'package:json_annotation/json_annotation.dart';
import 'package:progettotps/model/user.dart';

import 'allenamento.dart';

part 'generated/sessione.g.dart';

@JsonSerializable()
class Sessione {
  final int userID;
  final int trainingID;

  final User? user;               // opzionale, evita cicli
  final Allenamento? allenamento; // opzionale, evita cicli

  Sessione({
    required this.userID,
    required this.trainingID,
    this.user,
    this.allenamento,
  });

  factory Sessione.fromJson(Map<String, dynamic> json) => _$SessioneFromJson(json);
  Map<String, dynamic> toJson() => _$SessioneToJson(this);
}