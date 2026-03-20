import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:progettotps/model/allenamento.dart';
import 'package:progettotps/model/esecuzione.dart';
import 'package:progettotps/model/user.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'http://localhost/progettotps/index_php.php'});

  // Headers comuni per le richieste POST
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<void> signUp(String name1, String name2, String surname1, String surname2, String email, String password) async {
    final uri = Uri.parse(baseUrl);

    // Prepara i dati, includendo solo i campi non vuoti
    final Map<String, dynamic> requestData = {
      'request': 'registrazione',
      'name1': name1,
      'surname1': surname1,
      'email': email,
      'password': password,
    };

    // Aggiungi i campi opzionali solo se non sono vuoti
    if (name2.isNotEmpty) {
      requestData['name2'] = name2;
    }
    if (surname2.isNotEmpty) {
      requestData['surname2'] = surname2;
    }

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message']}');
    }

    // Verifica se la registrazione è avvenuta con successo
    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore durante la registrazione');
    }
  }

  Future<User> login(String email, String password) async {
    final uri = Uri.parse(baseUrl);

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

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return User.fromJson({
          ...decoded['utente'],
          'password': password,
          'sessioni': [],
        });
      } else {
        throw Exception(decoded['message']);
      }
    } else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message']}');
    }
  }

  // Questa rimane GET perché è una operazione di lettura
  Future<List<Allenamento>> fetchAllenamenti(int userID) async {
    final uri = Uri.parse('$baseUrl?request=ottieniAllenamenti&userID=$userID');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true && decoded['data'] != null) {
        final data = decoded['data'];
        return (data as List).map((json) => Allenamento.fromJson(json)).toList();
      } else {
        throw Exception('Errore nella risposta del server: ${decoded['message'] ?? 'Dati nulli'}');
      }
    } else {
      throw Exception('Errore HTTP ${response.statusCode}');
    }
  }

  Future<Allenamento> aggiungiAllenamento(DateTime data, int userID) async {
    final uri = Uri.parse(baseUrl);

    final requestData = {
      'request': 'creaAllenamento',
      'userID': userID,
      'data': data.toIso8601String(),
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return Allenamento.fromJson(decoded['data']);
      } else {
        throw Exception(decoded['message'] ?? 'Errore nella creazione dell\'allenamento');
      }
    } else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nell\'aggiunta dell\'allenamento'}');
    }
  }

  Future<void> aggiungiEsecuzione(Esecuzione esecuzione) async {
    final uri = Uri.parse(baseUrl);

    final requestData = {
      'request': 'aggiungiEsecuzione',
      'trainingID': esecuzione.trainingID,
      'nomeEsercizio': esecuzione.nomeEsercizio,
      'kg': esecuzione.kg,
      'ripetizioni': esecuzione.ripetizioni,
      'note': esecuzione.note ?? '',
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nell\'aggiunta dell\'esecuzione'}');
    }

    // Verifica se l'operazione è avvenuta con successo
    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore nell\'aggiunta dell\'esecuzione');
    }
  }

  // Nuovi metodi per la modifica e eliminazione

  Future<void> modificaAllenamento(int trainingID, DateTime newData) async {
    final uri = Uri.parse(baseUrl);
    final requestData = {
      'request': 'modificaAllenamento',
      'trainingID': trainingID,
      'data': newData.toIso8601String(),
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nella modifica dell\'allenamento'}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore nella modifica dell\'allenamento');
    }
  }

  Future<void> eliminaAllenamento(int trainingID) async {
    final uri = Uri.parse(baseUrl);
    final requestData = {
      'request': 'eliminaAllenamento',
      'trainingID': trainingID,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nell\'eliminazione dell\'allenamento'}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore nell\'eliminazione dell\'allenamento');
    }
  }

  Future<void> modificaEsecuzione(Esecuzione esecuzione) async {
    final uri = Uri.parse(baseUrl);
    final requestData = {
      'request': 'modificaEsecuzione',
      'executionID': esecuzione.executionID,
      'nomeEsercizio': esecuzione.nomeEsercizio,
      'kg': esecuzione.kg,
      'ripetizioni': esecuzione.ripetizioni,
      'note': esecuzione.note ?? '',
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nella modifica dell\'esecuzione'}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore nella modifica dell\'esecuzione');
    }
  }

  Future<void> eliminaEsecuzione(int executionID) async {
    final uri = Uri.parse(baseUrl);
    final requestData = {
      'request': 'eliminaEsecuzione',
      'executionID': executionID,
    };

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception('Errore HTTP ${response.statusCode}: ${errorResponse['message'] ?? 'Errore nell\'eliminazione dell\'esecuzione'}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Errore nell\'eliminazione dell\'esecuzione');
    }
  }
}