import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:progettotps/model/allenamento.dart';
import 'package:progettotps/model/esecuzione.dart';
import 'package:progettotps/model/user.dart';

class ApiClient {
  final String _baseUrl;

  ApiClient({baseUrl = 'http://localhost/smartlog/endpoint.php'})
      :
      _baseUrl=baseUrl;


  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<void> signUp(String name1, String name2, String surname, String email, String password) async {
    final uri = Uri.parse(_baseUrl);

    final Map<String, dynamic> requestData = {
      'request': 'registrazione',
      'name1': name1,
      'name2': (name2.isEmpty)?null:name2,
      'surname': surname,
      'email': email,
      'password': password,
    };


    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if(response.statusCode==409){
      throw Exception('409');
    }

    Map<String, dynamic> decoded = jsonDecode(response.body);

    if (decoded['status']=='error') {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<User> login(String email, String password) async {
    final uri = Uri.parse(_baseUrl);

    final requestData = {
      'request': 'login',
      'email': email,
      'password': password,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    final decoded = json.decode(response.body);
    if (decoded['status'] == 'success') {
      return User.fromJson({
          ...decoded['data'],
          'allenamenti': [],
      });
    } else {
        throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<List<Allenamento>> fetchAllenamenti(int userID) async {
    final uri = Uri.parse('$_baseUrl?request=fetchAllenamenti&uid=$userID');
    final response = await http.get(uri);

    final decoded = jsonDecode(response.body);

    if (decoded['status'] == 'success') {
      final data = decoded['data'];
      return (data as List).map((json) => Allenamento.fromJson(json)).toList();
    } else {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<Allenamento> aggiungiAllenamento(DateTime data, int userID) async {
    final uri = Uri.parse(_baseUrl);

    final requestData = {
      'request': 'addAllenamento',
      'uid': userID,
      'data': data.toIso8601String(),
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    final decoded = json.decode(response.body);
    if (decoded['status']=='success') {
      return Allenamento.fromJson(decoded['data']);
    } else {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<Esecuzione> aggiungiEsecuzione(int trainingID, String nomeEsercizio, double kg, int ripetizioni, String note) async {
    final uri = Uri.parse(_baseUrl);

    final requestData = {
      'request': 'addEsecuzione',
      'trainingID': trainingID,
      'nomeEsercizio': nomeEsercizio,
      'kg': kg,
      'ripetizioni': ripetizioni,
      'note': note.isNotEmpty?note:null,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    final decoded = jsonDecode(response.body);
    if (decoded['status'] == 'success') {
      return Esecuzione.fromJson(decoded['data']);
    }else{
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<void> modificaAllenamento(int trainingID, DateTime newData) async {
    final uri = Uri.parse(_baseUrl);
    final requestData = {
      'request': 'editAllenamento',
      'trainingID': trainingID,
      'data': newData.toIso8601String(),
    };

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    final decoded = jsonDecode(response.body);
    if (decoded['status'] != 'success') {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<void> eliminaAllenamento(int trainingID) async {
    final uri = Uri.parse('$_baseUrl/allenamenti/$trainingID');


    final response = await http.delete(
      uri,
    );

    final decoded = jsonDecode(response.body);
    if (decoded['status'] != 'success') {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<void> modificaEsecuzione(Esecuzione esecuzione) async {
    final uri = Uri.parse(_baseUrl);
    final requestData = {
      'request': 'editEsecuzione',
      'trainingID': esecuzione.trainingID,
      'executionID': esecuzione.executionID,
      'nomeEsercizio': esecuzione.nomeEsercizio,
      'kg': esecuzione.kg,
      'ripetizioni': esecuzione.ripetizioni,
      'note': esecuzione.note ?? '',
    };

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    final decoded = jsonDecode(response.body);
    if (decoded['status'] != 'success') {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }

  Future<void> eliminaEsecuzione(int executionID) async {
    final uri = Uri.parse('$_baseUrl/esecuzioni/$executionID');

    final response = await http.delete(
      uri,
    );

    final decoded = jsonDecode(response.body);
    if (decoded['status'] != 'success') {
      throw Exception('Errore HTTP ${response.statusCode}: ${decoded['message']}');
    }
  }
}