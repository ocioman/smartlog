// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../esecuzione.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Esecuzione _$EsecuzioneFromJson(Map<String, dynamic> json) => Esecuzione(
  executionID: _intFromDynamic(json['executionID']),
  nomeEsercizio: json['nomeEsercizio'] as String,
  kg: _doubleFromDynamic(json['kg']),
  ripetizioni: _intFromDynamic(json['ripetizioni']),
  note: json['note'] as String?,
  trainingID: _intFromDynamic(json['trainingID']),
);

Map<String, dynamic> _$EsecuzioneToJson(Esecuzione instance) => <String, dynamic>{
  'executionID': instance.executionID,
  'nomeEsercizio': instance.nomeEsercizio,
  'kg': instance.kg,
  'ripetizioni': instance.ripetizioni,
  'note': instance.note,
  'trainingID': instance.trainingID,
};

// Helper functions for safe conversion
int _intFromDynamic(dynamic json) {
  if (json == null) return 0;
  if (json is String) return int.tryParse(json) ?? 0;
  if (json is num) return json.toInt();
  throw FormatException('Cannot convert $json to int');
}

double _doubleFromDynamic(dynamic json) {
  if (json == null) return 0.0;
  if (json is String) return double.tryParse(json) ?? 0.0;
  if (json is num) return json.toDouble();
  throw FormatException('Cannot convert $json to double');
}