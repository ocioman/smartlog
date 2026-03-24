<?php
require('funzioni.inc');

// Imposta header JSON
header('Content-Type: application/json');
// CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gestione preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Funzione di utilità per rispondere con dati JSON
function ritornaDatiJSON($dati) {
    echo json_encode([
        'success' => true,
        'data' => $dati
    ]);
}

// Funzione per ottenere i dati dal corpo della richiesta POST
function getPostData() {
    $input = file_get_contents('php://input');
    return json_decode($input, true);
}

// Gestione richiesta
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Solo ottieniAllenamenti rimane GET
    if (isset($_GET['request']) && $_GET['request'] === 'ottieniAllenamenti') {
        if (!isset($_GET['userID'])) {
            ritornaErroreJSON("UserID necessario", 400);
            return;
        }
        $allenamenti = getAllenamentiUtente($_GET['userID']);
        ritornaDatiJSON($allenamenti);
    } else {
        ritornaErroreJSON("Request GET non valida", 400);
    }
} elseif ($method === 'POST') {
    $postData = getPostData();
    
    if (!$postData || !isset($postData['request'])) {
        ritornaErroreJSON("Dati POST mancanti o request non specificata", 400);
        return;
    }
    
    switch ($postData['request']) {
        case 'login':
            login(
                $postData['email'] ?? null,
                $postData['password'] ?? null
            );
            break;
        case 'registrazione':
            registrazione(
                $postData['name1'] ?? null,
                $postData['name2'] ?? null,
                $postData['surname1'] ?? null,
                $postData['surname2'] ?? null,
                $postData['email'] ?? null,
                $postData['password'] ?? null
            );
            break;
        case 'creaAllenamento':
            if (!isset($postData['userID'])) {
                ritornaErroreJSON("UserID necessario", 400);
                return;
            }
            $data = $postData['data'] ?? null;
            $allenamento = aggiungiAllenamento($postData['userID'], $data);
            if ($allenamento) {
                ritornaDatiJSON($allenamento);
            } else {
                ritornaErroreJSON("Errore nella creazione dell'allenamento", 500);
            }
            break;
        case 'aggiungiEsecuzione':
            if (!isset($postData['trainingID']) || !isset($postData['kg']) || 
                !isset($postData['ripetizioni']) || !isset($postData['nomeEsercizio'])) {
                ritornaErroreJSON("TrainingID, kg, ripetizioni e nomeEsercizio sono necessari", 400);
                return;
            }
            $note = $postData['note'] ?? null;
            $esecuzione = aggiungiEsecuzione(
                $postData['trainingID'], 
                $postData['kg'], 
                $postData['ripetizioni'], 
                $note, 
                $postData['nomeEsercizio']
            );
            if ($esecuzione) {
                ritornaDatiJSON($esecuzione);
            } else {
                ritornaErroreJSON("Errore nell'aggiunta dell'esecuzione", 500);
            }
            break;
        case 'modificaAllenamento':
            if (!isset($postData['trainingID']) || !isset($postData['data'])) {
                ritornaErroreJSON("TrainingID e data sono necessari per la modifica dell'allenamento", 400);
                return;
            }
            if (modificaAllenamento($postData['trainingID'], $postData['data'])) {
                ritornaDatiJSON(['message' => 'Allenamento modificato con successo']);
            } else {
                ritornaErroreJSON("Errore nella modifica dell'allenamento", 500);
            }
            break;
        case 'eliminaAllenamento':
            if (!isset($postData['trainingID'])) {
                ritornaErroreJSON("TrainingID necessario per l'eliminazione dell'allenamento", 400);
                return;
            }
            if (eliminaAllenamento($postData['trainingID'])) {
                ritornaDatiJSON(['message' => 'Allenamento eliminato con successo']);
            } else {
                ritornaErroreJSON("Errore nell'eliminazione dell'allenamento", 500);
            }
            break;
        case 'modificaEsecuzione':
            if (!isset($postData['executionID']) || !isset($postData['kg']) ||
                !isset($postData['ripetizioni']) || !isset($postData['nomeEsercizio'])) {
                ritornaErroreJSON("ExecutionID, kg, ripetizioni e nomeEsercizio sono necessari per la modifica dell'esecuzione", 400);
                return;
            }
            $note = $postData['note'] ?? null;
            if (modificaEsecuzione(
                $postData['executionID'],
                $postData['kg'],
                $postData['ripetizioni'],
                $note,
                $postData['nomeEsercizio']
            )) {
                ritornaDatiJSON(['message' => 'Esecuzione modificata con successo']);
            } else {
                ritornaErroreJSON("Errore nella modifica dell'esecuzione", 500);
            }
            break;
        case 'eliminaEsecuzione':
            if (!isset($postData['executionID'])) {
                ritornaErroreJSON("ExecutionID necessario per l'eliminazione dell'esecuzione", 400);
                return;
            }
            if (eliminaEsecuzione($postData['executionID'])) {
                ritornaDatiJSON(['message' => 'Esecuzione eliminata con successo']);
            } else {
                ritornaErroreJSON("Errore nell'eliminazione dell'esecuzione", 500);
            }
            break;
        default:
            ritornaErroreJSON("Request POST non valida", 400);
    }
} else {
    ritornaErroreJSON("Metodo HTTP non supportato", 405);
}
?>