// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esecuzione.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Esecuzione _$EsecuzioneFromJson(Map<String, dynamic> json) => Esecuzione(
  executionID: const StringToIntConverter().fromJson(json['executionID']),
  kg: const StringToDoubleConverter().fromJson(json['kg']),
  ripetizioni: const StringToIntConverter().fromJson(json['ripetizioni']),
  note: json['note'] as String?,
  trainingID: const StringToIntConverter().fromJson(json['trainingID']),
  nomeEsercizio: json['nomeEsercizio'] as String,
);

Map<String, dynamic> _$EsecuzioneToJson(Esecuzione instance) =>
    <String, dynamic>{
      'executionID': const StringToIntConverter().toJson(instance.executionID),
      'kg': const StringToDoubleConverter().toJson(instance.kg),
      'ripetizioni': const StringToIntConverter().toJson(instance.ripetizioni),
      'note': instance.note,
      'trainingID': const StringToIntConverter().toJson(instance.trainingID),
      'nomeEsercizio': instance.nomeEsercizio,
    };
