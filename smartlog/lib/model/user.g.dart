// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userID: (json['userID'] as num).toInt(),
  name1: json['name1'] as String,
  name2: json['name2'] as String?,
  surname: json['surname'] as String,
  email: json['email'] as String,
  allenamenti:
      (json['allenamenti'] as List<dynamic>?)
          ?.map((e) => Allenamento.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userID': instance.userID,
  'name1': instance.name1,
  'name2': instance.name2,
  'surname': instance.surname,
  'email': instance.email,
  'allenamenti': instance.allenamenti,
};
