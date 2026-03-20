// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../sessione.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sessione _$SessioneFromJson(Map<String, dynamic> json) => Sessione(
  userID: (json['userID'] as num).toInt(),
  trainingID: (json['trainingID'] as num).toInt(),
);

Map<String, dynamic> _$SessioneToJson(Sessione instance) => <String, dynamic>{
  'userID': instance.userID,
  'trainingID': instance.trainingID,
};
