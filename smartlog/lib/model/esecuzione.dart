import 'package:json_annotation/json_annotation.dart';
import 'converters.dart'; // Assicurati di importare i converter

part 'esecuzione.g.dart';

@JsonSerializable()
class Esecuzione {
  @StringToIntConverter()
  final int executionID;

  @StringToDoubleConverter()
  final double kg;

  @StringToIntConverter()
  final int ripetizioni;

  final String? note;

  @StringToIntConverter()
  final int trainingID;

  final String nomeEsercizio;

  Esecuzione({
    required this.executionID,
    required this.kg,
    required this.ripetizioni,
    this.note,
    required this.trainingID,
    required this.nomeEsercizio,
  });

  factory Esecuzione.fromJson(Map<String, dynamic> json) => _$EsecuzioneFromJson(json);

  Map<String, dynamic> toJson() => _$EsecuzioneToJson(this);
}