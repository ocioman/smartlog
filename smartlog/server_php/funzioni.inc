<?php

/**
 * Stabilisce una connessione al database utilizzando PDO.
 * Oggetto PDO in caso di successo, null altrimenti (anche se esce in caso di errore).
 */
function connetti($h, $u, $p, $db) {
    $dsn = "mysql:host=$h;dbname=$db;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Lancia eccezioni sugli errori
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Imposta la modalità di fetch predefinita
        PDO::ATTR_EMULATE_PREPARES   => false,                  // Usa prepared statement nativi
    ];
    try {
        $pdo = new PDO($dsn, $u, $p, $options);
        return $pdo;
    } catch (PDOException $e) {
        ritornaErroreJSON("Connessione al database fallita: " . $e->getMessage(), 500);
        exit; // Esce dallo script se la connessione fallisce
    }
}

/**
 * Invia una risposta JSON di errore e imposta il codice di stato HTTP.
 */
function ritornaErroreJSON($messaggio, $codice) {
    http_response_code($codice);
    echo json_encode([
        'success' => false,
        'message' => $messaggio
    ]);
}

/**
 * Gestisce il login dell'utente.
 */
function login($email, $password) {
    if (!$email || !$password) {
        ritornaErroreJSON("Email e password sono richiesti", 400);
        return;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        ritornaErroreJSON("Formato email non valido", 400);
        return;
    }

    $conn = connetti("localhost", "root", "", "smartlog");

    try {
        $query = "SELECT * FROM users WHERE email = :email";
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();

        $utente = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$utente) {
            ritornaErroreJSON("Credenziali non valide", 401);
            return;
        }

        // IMPORTANTE: Questa è una comparazione di password in chiaro.
        // Dovresti usare password_verify() e password_hash() per la sicurezza.
        if ($password !== $utente['password']) {
            ritornaErroreJSON("Credenziali non valide", 401);
            return;
        }

        unset($utente['password']); // Non inviare la password (o l'hash) al client

        echo json_encode([
            'success' => true,
            'message' => 'Login effettuato con successo',
            'utente' => $utente
        ]);

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nel database durante il login: " . $e->getMessage(), 500);
    } finally {
        $stmt = null; // Chiudi lo statement
        $conn = null; // Chiudi la connessione
    }
}

/**
 * Gestisce la registrazione di un nuovo utente.
 */
function registrazione($name1, $name2, $surname1, $surname2, $email, $password) {
    if (!$name1 || !$surname1 || !$email || !$password) {
        ritornaErroreJSON("Campi obbligatori mancanti (nome, cognome, email, password)", 400);
        return;
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        ritornaErroreJSON("Formato email non valido", 400);
        return;
    }

    if (strlen($password) < 8) {
        ritornaErroreJSON("La password deve essere lunga almeno 8 caratteri", 400);
        return;
    }

    // IMPORTANTE: La password dovrebbe essere hashata prima di essere salvata.
    // Esempio: $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    // E poi salva $hashedPassword nel database.

    $conn = connetti("localhost", "root", "", "smartlog");

    try {
        // Verifica se email già esiste
        $query_check = "SELECT userID FROM users WHERE email = :email";
        $stmt_check = $conn->prepare($query_check);
        $stmt_check->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt_check->execute();

        if ($stmt_check->fetchColumn()) {
            ritornaErroreJSON("Email già registrata", 409);
            $stmt_check = null;
            $conn = null;
            return;
        }
        $stmt_check = null;

        // Inserimento nuovo utente
        $query_insert = "INSERT INTO users (name1, name2, surname1, surname2, email, password) VALUES (:name1, :name2, :surname1, :surname2, :email, :password)";
        $stmt_insert = $conn->prepare($query_insert);

        $stmt_insert->bindParam(':name1', $name1, PDO::PARAM_STR);
        $stmt_insert->bindParam(':name2', $name2, PDO::PARAM_STR_NULL); // Permetti NULL se $name2 è vuoto
        $stmt_insert->bindParam(':surname1', $surname1, PDO::PARAM_STR);
        $stmt_insert->bindParam(':surname2', $surname2, PDO::PARAM_STR_NULL); // Permetti NULL se $surname2 è vuoto
        $stmt_insert->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt_insert->bindParam(':password', $password, PDO::PARAM_STR); // Salva $hashedPassword qui

        $stmt_insert->execute();
        $nuovo_id = $conn->lastInsertId();
        $stmt_insert = null;

        // Recupera dati utente senza password
        $query_get = "SELECT userID, name1, name2, surname1, surname2, email FROM users WHERE userID = :userID";
        $stmt_get = $conn->prepare($query_get);
        $stmt_get->bindParam(':userID', $nuovo_id, PDO::PARAM_INT);
        $stmt_get->execute();
        $nuovo_utente = $stmt_get->fetch(PDO::FETCH_ASSOC);
        $stmt_get = null;

        echo json_encode([
            'success' => true,
            'message' => 'Registrazione completata con successo',
            'utente' => $nuovo_utente
        ]);

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nel database durante la registrazione: " . $e->getMessage(), 500);
    } finally {
        $conn = null; // Chiudi la connessione
    }
}

/**
 * Aggiunge un nuovo allenamento e la relativa sessione.
 */
function aggiungiAllenamento($userID, $data) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $conn->beginTransaction();

        $stmt = $conn->prepare("INSERT INTO allenamenti (data) VALUES (:data)");
        $stmt->bindParam(':data', $data, PDO::PARAM_STR);
        $stmt->execute();
        $trainingID = $conn->lastInsertId();
        $stmt = null;

        $stmt2 = $conn->prepare("INSERT INTO sessioni (userID, trainingID) VALUES (:userID, :trainingID)");
        $stmt2->bindParam(':userID', $userID, PDO::PARAM_INT);
        $stmt2->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
        $stmt2->execute();
        $stmt2 = null;

        $conn->commit();
        return ['trainingID' => (int)$trainingID, 'data' => $data];

    } catch (PDOException $e) {
        if ($conn->inTransaction()) {
            $conn->rollBack();
        }
        ritornaErroreJSON("Errore durante l'aggiunta dell'allenamento: " . $e->getMessage(), 500);
        return false;
    } finally {
        $conn = null;
    }
}

/**
 * Aggiunge una nuova esecuzione a un allenamento.
 */
function aggiungiEsecuzione($trainingID, $kg, $ripetizioni, $note, $nomeEsercizio) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $stmt = $conn->prepare("INSERT INTO esecuzioni (kg, ripetizioni, note, trainingID, nomeEsercizio) VALUES (:kg, :ripetizioni, :note, :trainingID, :nomeEsercizio)");
        $stmt->bindParam(':kg', $kg, PDO::PARAM_STR); // PDO gestisce float/double come stringhe in bindParam, ma il DB lo converte
        $stmt->bindParam(':ripetizioni', $ripetizioni, PDO::PARAM_INT);
        $stmt->bindParam(':note', $note, PDO::PARAM_STR_NULL);
        $stmt->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
        $stmt->bindParam(':nomeEsercizio', $nomeEsercizio, PDO::PARAM_STR);
        
        $stmt->execute();
        $executionID = $conn->lastInsertId();
        $stmt = null;

        return [
            'executionID' => (int)$executionID, 
            'kg' => $kg, 
            'ripetizioni' => $ripetizioni, 
            'note' => $note, 
            'trainingID' => $trainingID, 
            'nomeEsercizio' => $nomeEsercizio
        ];

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore durante l'aggiunta dell'esecuzione: " . $e->getMessage(), 500);
        return false;
    } finally {
        $conn = null;
    }
}

/**
 * Recupera tutti gli allenamenti di un utente con le relative esecuzioni.
 */
function getAllenamentiUtente($userID) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $query = "
            SELECT a.trainingID, a.data, e.executionID, e.kg, e.ripetizioni, e.note, e.nomeEsercizio
            FROM sessioni s
            JOIN allenamenti a ON s.trainingID = a.trainingID
            LEFT JOIN esecuzioni e ON a.trainingID = e.trainingID
            WHERE s.userID = :userID
            ORDER BY a.data DESC, a.trainingID, e.executionID
        "; // Aggiunto a.trainingID nell'ORDER BY per coerenza raggruppamento
        $stmt = $conn->prepare($query);
        $stmt->bindParam(':userID', $userID, PDO::PARAM_INT);
        $stmt->execute();

        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $allenamenti = [];

        foreach ($results as $row) {
            $tid = $row['trainingID'];
            if (!isset($allenamenti[$tid])) {
                $allenamenti[$tid] = [
                    'trainingID' => (int)$tid,
                    'data' => $row['data'],
                    'esecuzioni' => []
                ];
            }
            if ($row['executionID']) {
                $allenamenti[$tid]['esecuzioni'][] = [
                    'executionID' => (int)$row['executionID'],
                    'kg' => (float)$row['kg'], // Cast a float
                    'ripetizioni' => (int)$row['ripetizioni'],
                    'note' => $row['note'],
                    'nomeEsercizio' => $row['nomeEsercizio']
                ];
            }
        }
        return array_values($allenamenti);

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nel recupero degli allenamenti: " . $e->getMessage(), 500);
        return []; // Restituisce array vuoto in caso di errore
    } finally {
        $stmt = null;
        $conn = null;
    }
}

/**
 * Modifica la data di un allenamento esistente.
 */
function modificaAllenamento($trainingID, $newData) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $stmt = $conn->prepare("UPDATE allenamenti SET data = :newData WHERE trainingID = :trainingID");
        $stmt->bindParam(':newData', $newData, PDO::PARAM_STR);
        $stmt->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
        $stmt->execute();
        
        // rowCount() può essere usato per verificare se qualche riga è stata effettivamente modificata.
        // pero execute() non lancia eccezione se la query è valida ma non modifica righe (es. ID non trovato).
        // Se l'ID non esiste, non ci sarà errore SQL
        // Per ora, se execute() non lancia eccezioni, considero l'operazione "successo logico".
        return true;

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nella modifica dell'allenamento: " . $e->getMessage(), 500);
        return false;
    } finally {
        $stmt = null;
        $conn = null;
    }
}

/**
 * Elimina un allenamento e, grazie a ON DELETE CASCADE, le relative sessioni ed esecuzioni.
 */
function eliminaAllenamento($trainingID) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        // Se le FK hanno ON DELETE CASCADE, basta eliminare da 'allenamenti'.
        // Non è necessario gestire la transazione qui a meno che non ci siano altre operazioni.
        // La transazione era utile in mysqli per raggruppare più delete manuali.
        // Con PDO e ON DELETE CASCADE, una singola query DELETE è atomica di per sé.
        
        $stmt = $conn->prepare("DELETE FROM allenamenti WHERE trainingID = :trainingID");
        $stmt->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
        $stmt->execute();

        // Per verificare se qualcosa è stato effettivamente cancellato:
        // if ($stmt->rowCount() > 0) { return true; } else { return false; // o ritornaErroreJSON("Nessun allenamento trovato con questo ID", 404) }
        return true; // Assume successo se non ci sono eccezioni

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nell'eliminazione dell'allenamento: " . $e->getMessage(), 500);
        return false;
    } finally {
        $stmt = null;
        $conn = null;
    }
}

/**
 * Modifica un'esecuzione esistente.
 */
function modificaEsecuzione($executionID, $kg, $ripetizioni, $note, $nomeEsercizio) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $stmt = $conn->prepare("UPDATE esecuzioni SET kg = :kg, ripetizioni = :ripetizioni, note = :note, nomeEsercizio = :nomeEsercizio WHERE executionID = :executionID");
        $stmt->bindParam(':kg', $kg, PDO::PARAM_STR); // Anche qui, PDO gestisce bene i float
        $stmt->bindParam(':ripetizioni', $ripetizioni, PDO::PARAM_INT);
        $stmt->bindParam(':note', $note, PDO::PARAM_STR_NULL);
        $stmt->bindParam(':nomeEsercizio', $nomeEsercizio, PDO::PARAM_STR);
        $stmt->bindParam(':executionID', $executionID, PDO::PARAM_INT);
        
        $stmt->execute();
        return true;

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nella modifica dell'esecuzione: " . $e->getMessage(), 500);
        return false;
    } finally {
        $stmt = null;
        $conn = null;
    }
}

/**
 * Elimina un'esecuzione.
 */
function eliminaEsecuzione($executionID) {
    $conn = connetti("localhost", "root", "", "smartlog");
    try {
        $stmt = $conn->prepare("DELETE FROM esecuzioni WHERE executionID = :executionID");
        $stmt->bindParam(':executionID', $executionID, PDO::PARAM_INT);
        $stmt->execute();
        return true;

    } catch (PDOException $e) {
        ritornaErroreJSON("Errore nell'eliminazione dell'esecuzione: " . $e->getMessage(), 500);
        return false;
    } finally {
        $stmt = null;
        $conn = null;
    }
}

?>