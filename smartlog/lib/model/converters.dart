import 'package:json_annotation/json_annotation.dart';

class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0.0; // oppure lancia un errore o restituisci null se usi double?
    if (json is String) return double.tryParse(json) ?? 0.0;
    if (json is num) return json.toDouble();
    throw FormatException('Cannot convert $json to double');
  }

  @override
  dynamic toJson(double value) => value;
}

class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0; // oppure lancia un errore o restituisci null se usi int?
    if (json is String) return int.tryParse(json) ?? 0;
    if (json is num) return json.toInt();
    throw FormatException('Cannot convert $json to int');
  }

  @override
  dynamic toJson(int value) => value;
}