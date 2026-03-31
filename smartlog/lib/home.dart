import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progettotps/login.dart';
import 'package:progettotps/model/esecuzione.dart';
import 'package:progettotps/model/allenamento.dart';
import 'package:progettotps/model/user.dart';

import 'api_client.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiClient apiClient = ApiClient();
  List<Allenamento> allenamenti = [];

  @override
  void initState() {
    super.initState();
    _caricaAllenamenti(context);
  }

  Future<void> _caricaAllenamenti(BuildContext context) async {
    try {
      final lista = await apiClient.fetchAllenamenti(widget.user.userID);
      setState(() {
        allenamenti = lista;
      });
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento dell\'allenamento: ${e.toString()}')),
      );
    }
  }

  Future<void> _aggiungiAllenamento(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Header background, selected date
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Calendar background
              onSurface: Colors.black, // Calendar text
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      try {
        final nuovoAllenamento = await apiClient.aggiungiAllenamento(data, widget.user.userID);
        setState(() {
          allenamenti.add(nuovoAllenamento);
        });
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aggiunta dell\'allenamento: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _modificaAllenamento(Allenamento allenamento, BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: allenamento.data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (newDate != null) {
      try {
        await apiClient.modificaAllenamento(allenamento.trainingID, newDate);
        setState(() {
          final index = allenamenti.indexWhere((a) => a.trainingID == allenamento.trainingID);
          if (index != -1) {
            allenamenti[index].data = newDate;
          }
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Center(
                child: Text(
                  'Allenamento modificato con successo!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              elevation: null,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            )
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella modifica dell\'allenamento: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _eliminaAllenamento(Allenamento allenamento, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Elimina Allenamento", style: TextStyle(color: Colors.black)),
          content: const Text("Sei sicuro di voler eliminare questo allenamento e tutte le sue esecuzioni?", style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Elimina"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await apiClient.eliminaAllenamento(allenamento.trainingID);
        setState(() {
          allenamenti.removeWhere((a) => a.trainingID == allenamento.trainingID);
        });
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Center(
                child: Text(
                  'Allenamento eliminato con successo!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              elevation: null,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            )
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'eliminazione dell\'allenamento: ${e.toString()}')),
        );
      }
    }
  }


  Future<void> _aggiungiEsecuzione(Allenamento allenamento, BuildContext context) async {
    final controllerNomeEsercizio = TextEditingController();
    final controllerKg = TextEditingController();
    final controllerRipetizioni = TextEditingController();
    final controllerNote = TextEditingController();

    final textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: Colors.black),
    );

    await showDialog<Esecuzione>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Aggiungi esecuzione",
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controllerNomeEsercizio,
                  decoration: textFieldDecoration.copyWith(labelText: "Esercizio"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerKg,
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration.copyWith(labelText: "Kg"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerRipetizioni,
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration.copyWith(labelText: "Ripetizioni"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerNote,
                  decoration: textFieldDecoration.copyWith(labelText: "Note (facoltative)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Annulla",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () async{
                  final kg = double.tryParse(controllerKg.text);
                  final ripetizioni = int.tryParse(controllerRipetizioni.text);
                  final esercizio = controllerNomeEsercizio.text;

                  if (kg != null && ripetizioni != null && esercizio.isNotEmpty) {
                      try {
                        Esecuzione added=await apiClient.aggiungiEsecuzione(allenamento.trainingID, esercizio, kg, ripetizioni, controllerNote.text.trim());
                        setState(() {
                          final index = allenamenti.indexWhere((a) => a.trainingID == allenamento.trainingID);
                          if (index != -1) {
                            allenamenti[index].esecuzioni ??= [];
                            allenamenti[index].esecuzioni!.add(added);
                          }
                        });
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore nell\'aggiunta dell\'esecuzione: ${e.toString()}')),
                        );
                      }
                      if(!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                  }else{
                    if(!context.mounted) return;
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content:
                          Center(
                            child: Text(
                              'Inserire i campi richiesti',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          elevation: null,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFFC62828),
                        )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Aggiungi"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _modificaEsecuzione(Allenamento allenamento, Esecuzione esecuzione, BuildContext context) async {
    final controllerNomeEsercizio = TextEditingController(text: esecuzione.nomeEsercizio);
    final controllerKg = TextEditingController(text: esecuzione.kg.toString());
    final controllerRipetizioni = TextEditingController(text: esecuzione.ripetizioni.toString());
    final controllerNote = TextEditingController(text: esecuzione.note);

    final textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: Colors.black),
    );

    final updatedExecution = await showDialog<Esecuzione>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Modifica esecuzione",
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controllerNomeEsercizio,
                  decoration: textFieldDecoration.copyWith(labelText: "Esercizio"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerKg,
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration.copyWith(labelText: "Kg"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerRipetizioni,
                  keyboardType: TextInputType.number,
                  decoration: textFieldDecoration.copyWith(labelText: "Ripetizioni"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllerNote,
                  decoration: textFieldDecoration.copyWith(labelText: "Note (facoltative)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Annulla",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final kg = double.tryParse(controllerKg.text);
                  final ripetizioni = int.tryParse(controllerRipetizioni.text);
                  final esercizio = controllerNomeEsercizio.text;

                  if (kg != null && ripetizioni != null && esercizio.isNotEmpty) {
                    final modifiedEsecuzione = Esecuzione(
                      executionID: esecuzione.executionID,
                      nomeEsercizio: esercizio,
                      kg: kg,
                      ripetizioni: ripetizioni,
                      note: controllerNote.text.isEmpty ? null : controllerNote.text,
                      trainingID: esecuzione.trainingID,
                    );
                    Navigator.pop(context, modifiedEsecuzione);
                  }else{
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content:
                          Center(
                            child: Text(
                              'Inserire i campi richiesti',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          elevation: null,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFFC62828),
                        )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Salva"),
              ),
            ],
          ),
        );
      },
    );

    if (updatedExecution != null) {
      try {
        await apiClient.modificaEsecuzione(updatedExecution);
        setState(() {
          final allenamentoIndex = allenamenti.indexWhere((a) => a.trainingID == allenamento.trainingID);
          if (allenamentoIndex != -1) {
            final esecuzioneIndex = allenamenti[allenamentoIndex].esecuzioni!.indexWhere(
                  (e) => e.executionID == updatedExecution.executionID,
            );
            if (esecuzioneIndex != -1) {
              allenamenti[allenamentoIndex].esecuzioni![esecuzioneIndex] = updatedExecution;
            }
          }
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Center(
                child: Text(
                  'Esecuzione modificata con successo!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              elevation: null,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            )
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella modifica dell\'esecuzione: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _eliminaEsecuzione(Allenamento allenamento, Esecuzione esecuzione, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Elimina Esecuzione", style: TextStyle(color: Colors.black)),
          content: const Text("Sei sicuro di voler eliminare questa esecuzione?", style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annulla", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Elimina"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await apiClient.eliminaEsecuzione(esecuzione.executionID);
        setState(() {
          final allenamentoIndex = allenamenti.indexWhere((a) => a.trainingID == allenamento.trainingID);
          if (allenamentoIndex != -1) {
            allenamenti[allenamentoIndex].esecuzioni!.removeWhere(
                  (e) => e.executionID == esecuzione.executionID,
            );
          }
        });
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Center(
                child: Text(
                  'Esecuzione eliminata con successo!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              elevation: null,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black,
            )
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'eliminazione dell\'esecuzione: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final textStyleTitle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
    final textStyleSubtitle = Theme.of(context).textTheme.titleMedium;

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF5F5F5),
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.black),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/logos/logo.svg',
                    width: 150,
                    height: 150,
                    placeholderBuilder: (context) => const Text('Errore SVG'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Benvenuto, ${widget.user.name1}!',
                    style: textStyleTitle,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: ()=>_aggiungiAllenamento(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Aggiungi un allenamento'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'I tuoi allenamenti',
                  style: textStyleSubtitle,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child: allenamenti.isEmpty
                      ? const Center(
                    child: Text(
                      'Nessun allenamento aggiunto',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allenamenti.length,
                    itemBuilder: (context, index) {
                      final allenamento = allenamenti[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[200], // Colore grigiastro per le card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Allenamento del ${allenamento.data.toLocal().toString().split(" ")[0]}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _modificaAllenamento(allenamento, context);
                                          } else if (value == 'delete') {
                                            _eliminaAllenamento(allenamento, context);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Text('Modifica Allenamento'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Elimina Allenamento'),
                                          ),
                                        ],
                                        color: Colors.grey[200],
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            '•••',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, color: Colors.black),
                                        onPressed: () => _aggiungiEsecuzione(allenamento, context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (allenamento.esecuzioni == null || allenamento.esecuzioni!.isEmpty)
                                const Text('Nessuna esecuzione')
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: allenamento.esecuzioni!.map((e) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Baseline(
                                                  baseline: 20,
                                                  baselineType: TextBaseline.alphabetic,
                                                  child: Text('• ${e.nomeEsercizio}: ${e.kg} kg x ${e.ripetizioni} rip.',
                                                      style: const TextStyle(fontSize: 20)),
                                                ),
                                                if (e.note != null && e.note!.isNotEmpty)
                                                  Baseline(
                                                    baseline: 20,
                                                    baselineType: TextBaseline.alphabetic,
                                                    child: Text('Note: ${e.note}',
                                                        style: const TextStyle(fontSize: 16, color: Colors.black)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _modificaEsecuzione(allenamento, e, context);
                                              } else if (value == 'delete') {
                                                _eliminaEsecuzione(allenamento, e, context);
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Text('Modifica Esecuzione'),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Elimina Esecuzione'),
                                              ),
                                            ],
                                            color: Colors.grey[200],
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                '•••',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}