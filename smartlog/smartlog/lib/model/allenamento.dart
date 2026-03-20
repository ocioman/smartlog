import 'package:json_annotation/json_annotation.dart';
import 'package:progettotps/model/sessione.dart';

import 'esecuzione.dart';

part 'generated/allenamento.g.dart';

@JsonSerializable()
class Allenamento {
  final int trainingID;
  DateTime data;

  List<Esecuzione>? esecuzioni; // Relazione 1:N con esecuzioni
  final List<Sessione>? sessioni;     // Relazione N:N con utenti

  Allenamento({
    required this.trainingID,
    required this.data,
    this.esecuzioni,
    this.sessioni,
  });

  factory Allenamento.fromJson(Map<String, dynamic> json) =>
      _$AllenamentoFromJson(json);

  Map<String, dynamic> toJson() => _$AllenamentoToJson(this);
}