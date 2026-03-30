<?php
require 'funzioni.inc';
?>

<?php
//comunico al client che la response sarà in JSON
header("Content-Type: application/json; charset=UTF-8");

//Cross Origin Resource Sharing se la chiamata arriva da un dominio/porta differenti (es. frontend React/Flutter)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

//gestione delle richieste preflight -> verifica da parte del client se un server accetta CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { // "===" true se $_SERVER['REQUEST_METHOD'] e 'OPTIONS' sono uguali e dello stesso tipo (String)
    http_response_code(204);
    exit;
}

//inizializzazione di json response
$JSONres = json_encode(generateResponse('error', 'Errore interno del server', null));

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        /*
        L'array associativo $_POST non funziona perché i dati li ricevo all'interno del body, non della
        query string come in una GET -> funzionerebbe se avessi un classico form
        */
        $JSONreq = file_get_contents('php://input');

        //decodifico il JSON in un'array associativo (secondo parametro a true)
        $dataReq = json_decode($JSONreq, true);

        //verifico se il JSON è valido, altrimenti errore lato client (è lui che me l'ha inviato)
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Payload JSON non valido", 400); //400 Bad Request
        }

        $JSONres = handlePost($dataReq);
    } else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $JSONres = handleGet($_GET);
    }else if($_SERVER['REQUEST_METHOD'] === 'PUT'){

        $JSONreq=file_get_contents('php://input');

        $dataReq=json_decode($JSONreq,true);

        if(json_last_error() !== JSON_ERROR_NONE){
            throw new Exception("Payload JSON non valido", 400); //400 Bad Request
        }

        $JSONres = handlePut($dataReq);
    }else if($_SERVER['REQUEST_METHOD'] === 'DELETE'){
        $path=parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        $path=trim($path, '/');
        $parts=explode('/', $path);

        $deleteType=null;
        $deleteID=null;

        if(count($parts)>=2) {
            $deleteType=$parts[count($parts)-2];
            $deleteID=$parts[count($parts)-1];
        }

        $dataReq=array(
            'request'=>$deleteType,
            'deleteID'=>$deleteID
        );

        $JSONres=handleDelete($dataReq);
    }
} catch (PDOException $p) {
    http_response_code(500);
    $JSONres = json_encode(generateResponse('error', $p->getMessage(), null));
} catch (Exception $e) {
    $statusCode = $e->getCode() ? $e->getCode() : 500;
    if ($statusCode < 100 || $statusCode > 599) $statusCode = 500;

    http_response_code($statusCode);
    $JSONres = json_encode(generateResponse('error', $e->getMessage(), null));
} finally {
    echo $JSONres;
    exit;
}

//output finale serializzato
