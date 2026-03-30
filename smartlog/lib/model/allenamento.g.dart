// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allenamento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Allenamento _$AllenamentoFromJson(Map<String, dynamic> json) => Allenamento(
  trainingID: (json['trainingID'] as num).toInt(),
  data: DateTime.parse(json['data'] as String),
  esecuzioni:
      (json['esecuzioni'] as List<dynamic>?)
          ?.map((e) => Esecuzione.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$AllenamentoToJson(Allenamento instance) =>
    <String, dynamic>{
      'trainingID': instance.trainingID,
      'data': instance.data.toIso8601String(),
      'esecuzioni': instance.esecuzioni,
    };
