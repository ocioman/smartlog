import 'package:json_annotation/json_annotation.dart';
import 'esecuzione.dart';

part 'allenamento.g.dart';

@JsonSerializable()
class Allenamento {
  final int trainingID;
  DateTime data;

  List<Esecuzione>? esecuzioni; // Relazione 1:N con esecuzioni

  Allenamento({
    required this.trainingID,
    required this.data,
    this.esecuzioni,
  });

  factory Allenamento.fromJson(Map<String, dynamic> json) =>
      _$AllenamentoFromJson(json);

  Map<String, dynamic> toJson() => _$AllenamentoToJson(this);
}