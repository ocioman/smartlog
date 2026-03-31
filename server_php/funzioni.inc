<?php

function generateResponse($status, $message, $data): array
{
    return [
        "status"=>$status??null,
        "message"=>$message??null,
        "data"=>$data??null
    ];
}
function connect($host, $user, $pass, $db): PDO
{
    $pdo=new PDO("mysql:host=$host;dbname=$db", $user, $pass); //se causa un'eccezione viene direttamente rilanciata al chiamante originale
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    return $pdo;
}

function handleSignup($dataReq): void
{
    $connection=connect("localhost", "root", "", "smartlog");

    //estraggo i parametri dall'array associativo per eseguire la query
    $name1=$dataReq['name1']??null;
    $name2=$dataReq['name2']??null;
    $surname=$dataReq['surname']??null;
    $email=$dataReq['email']??null;
    $password=$dataReq['password']??null;

    $checkEmailConflictQuery="SELECT COUNT(*) as emailCount FROM users WHERE email=:email";

    $checkEmailConflict=$connection->prepare($checkEmailConflictQuery);

    $checkEmailConflict->execute(
        [
            "email"=>$email,
        ]
    );

    $emailCount=$checkEmailConflict->fetch(PDO::FETCH_ASSOC);

    if($emailCount['emailCount']!=0)
        throw new Exception('Utente già registrato',409); //409=conflict

    if($name1==null || $surname==null || $email==null || $password==null)
        throw new Exception('Campi mancanti', 422); //422=unprocessable entity

    $hashedPass=password_hash($password, PASSWORD_DEFAULT);

    //con : uso i named parameters che verranno sostituiti con l'array associativo passado a execute -> più leggibile
    $insertUserQuery="INSERT INTO users(name1, name2, surname, email, password)
             VALUES (:name1, :name2, :surname, :email, :password)";

    $insert=$connection->prepare($insertUserQuery);

    $insert->execute([
        'name1'=>$name1,
        'name2'=>$name2,
        'surname'=>$surname,
        'email'=>$email,
        'password'=>$hashedPass,
        ]);
}

function handleLogin($dataReq): array
{
    $connection=connect("localhost", "root", "", "smartlog");

    $email=$dataReq['email']??null;
    $password=$dataReq['password']??null;

    //+ validazione lato client

    if($email==null || $password=='null')
        throw new Exception('Campi mancanti', 422);

    $logUserQuery="SELECT userID, name1, name2, surname, email, password FROM USERS 
                    WHERE email=:email";

    /*
     * Eseguire fetch degli allenamenti (+ esecuzioni)
     */

    $logUser=$connection->prepare($logUserQuery);

    $logUser->execute([
        'email'=>$email,
    ]);

    $user=$logUser->fetch(PDO::FETCH_ASSOC);

    if(!password_verify($password, $user['password'])){
        throw new Exception('Credenziali non valide', 401);
    }

    unset($user['password']);

    return $user;
}

function fetchAllenamenti($dataReq): array
{
    $connection=connect("localhost", "root", "", "smartlog");

    $uid=$dataReq['uid']??null;

    if($uid==null) throw new Exception('Campi mancanti', 422);

    $fetchAllenamentiQuery="SELECT a.trainingID AS aTrainingID, a.data, e.executionID, e.trainingID AS eTrainingID,
                            e.nomeEsercizio, e.ripetizioni, e.note, e.kg FROM ALLENAMENTI AS a LEFT JOIN esecuzioni AS e USING(trainingID)
                            WHERE a.userID=:userID ORDER BY a.trainingID, e.executionID";
    $fetchAllenamenti=$connection->prepare($fetchAllenamentiQuery);
    $fetchAllenamenti->bindParam(':userID', $uid, PDO::PARAM_INT); //di default execute usa PDO::PARAM_STRING, quindi dato che ho un int me lo setto io

    $fetchAllenamenti->execute();
    $allenamentiRaw=$fetchAllenamenti->fetchAll(PDO::FETCH_ASSOC);

    if($allenamentiRaw===false)
        throw new Exception('Errore nell\'ottenimento degli allenamenti', 500);

    if(empty($allenamentiRaw))
        return [];

    $allenamentiJSON=array();

    $i=0;
    $allenamentiJSON[0]['trainingID']=$allenamentiRaw[0]['aTrainingID'];
    $allenamentiJSON[0]['data']=$allenamentiRaw[0]['data'];
    $allenamentiJSON[0]['esecuzioni']=array();

    foreach($allenamentiRaw as $allenamento){
        if($allenamentiJSON[$i]['trainingID']!=$allenamento['aTrainingID']){
            $i++;
            $allenamentiJSON[$i]['trainingID']=$allenamento['aTrainingID'];
            $allenamentiJSON[$i]['data']=$allenamento['data'];
            $allenamentiJSON[$i]['esecuzioni']=array();
        }

        if($allenamento['executionID']!=null){
            $allenamentiJSON[$i]['esecuzioni'][]=[
                'executionID'=>$allenamento['executionID'],
                'trainingID'=>$allenamento['eTrainingID'],
                'nomeEsercizio'=>$allenamento['nomeEsercizio'],
                'ripetizioni'=>$allenamento['ripetizioni'],
                'note'=>$allenamento['note'],
                'kg'=>$allenamento['kg'],
            ];
        }
    }

    return $allenamentiJSON;
}

function addAllenamento($dataReq): array{
    $connection=connect("localhost", "root", "", "smartlog");

    $uid=$dataReq['uid']??null;
    $data=$dataReq['data']??null;

    if($uid==null || $data==null) throw new Exception('Campi mancanti', 422);

    $addAllenamentoQuery="INSERT INTO allenamenti(data, userID) 
                            VALUES (:data, :userID)";

    $addAllenamento=$connection->prepare($addAllenamentoQuery);

    $addAllenamento->execute(
        [
            "data"=>$data,
            "userID"=>$uid,
        ]
    );

    $trainingID=$connection->lastInsertId();

    $fetchAllenamentoQuery="SELECT trainingID, data FROM allenamenti WHERE trainingID=:trainingID";

    $fetchAllenamento=$connection->prepare($fetchAllenamentoQuery);

    $fetchAllenamento->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
    $fetchAllenamento->execute();

    $insertedAllenamento=$fetchAllenamento->fetch(PDO::FETCH_ASSOC);

    if($insertedAllenamento===false) throw new Exception('Errore nell\'ottenimento dell\'allenamento inserito',500);

    return $insertedAllenamento;
}

function addEsecuzione($dataReq): array{
    $connection=connect("localhost", "root","", "smartlog");

    $trainingID=$dataReq['trainingID']??null;
    $nomeEsercizio=$dataReq['nomeEsercizio']??null;
    $ripetizioni=$dataReq['ripetizioni']??null;
    $kg=$dataReq['kg']??null;
    $note=$dataReq['note']??null;

    if($trainingID==null || $nomeEsercizio==null || $ripetizioni==null || $kg==null) throw new Exception("Campi mancanti", 422);

    $addEsecuzioneQuery="INSERT INTO esecuzioni(trainingID, nomeEsercizio, ripetizioni, kg, note) 
                            VALUES(:trainingID, :nomeEsercizio, :ripetizioni, :kg, :note)";

    $addEsecuzione=$connection->prepare($addEsecuzioneQuery);
    $addEsecuzione->bindParam(':trainingID', $trainingID, PDO::PARAM_INT);
    $addEsecuzione->bindParam(':nomeEsercizio', $nomeEsercizio, PDO::PARAM_STR);
    $addEsecuzione->bindParam(':ripetizioni', $ripetizioni, PDO::PARAM_INT);
    $addEsecuzione->bindParam(':kg', $kg, PDO::PARAM_STR);
    $addEsecuzione->bindParam(':note', $note, PDO::PARAM_STR);

    $addEsecuzione->execute();

    $executionID=$connection->lastInsertId();

    $fetchEsecuzioneQuery="SELECT * FROM esecuzioni WHERE executionID=:executionID";

    $fetchEsecuzione=$connection->prepare($fetchEsecuzioneQuery);
    $fetchEsecuzione->bindParam(':executionID',$executionID,PDO::PARAM_INT);
    $fetchEsecuzione->execute();

    $insertedEsecuzione=$fetchEsecuzione->fetch();
    if($insertedEsecuzione===false) throw  new Exception('Errore nell\'inserimento dell\'esecuzione', 500);

    return $insertedEsecuzione;
}

function editAllenamento($dataReq): void{
    $connessione=connect("localhost", "root", "", "smartlog");

    $trainingID=$dataReq['trainingID']??null;
    $data=$dataReq['data']??null;

    if($data == null || $trainingID == null) throw new Exception('Campi mancanti', 422);

    $editAllenamentoQuery="UPDATE allenamenti SET data=:data 
                            WHERE trainingID=:trainingID";

    $editAllenamento=$connessione->prepare($editAllenamentoQuery);

    $editAllenamento->execute(
        [
            "data"=>$data,
            "trainingID"=>$trainingID,
        ]
    );
}

function editEsecuzione($dataReq): void{
    $connessione=connect("localhost", "root", "", "smartlog");

    $trainingID=$dataReq['trainingID']??null;
    $executionID=$dataReq['executionID']??null;
    $nomeEsercizio=$dataReq['nomeEsercizio']??null;
    $ripetizioni=$dataReq['ripetizioni']??null;
    $kg=$dataReq['kg']??null;
    $note=$dataReq['note']??null;

    if($trainingID==null || $executionID==null || $nomeEsercizio==null || $ripetizioni==null || $kg==null)
        throw new Exception("Campi mancanti", 422);

    $editEsecuzioneQuery="UPDATE esecuzioni SET nomeEsercizio=:nomeEsercizio, ripetizioni=:ripetizioni, kg=:kg, note=:note
                            WHERE executionID=:executionID";

    $editEsecuzione=$connessione->prepare($editEsecuzioneQuery);
    $editEsecuzione->bindParam(':executionID', $executionID, PDO::PARAM_INT);
    $editEsecuzione->bindParam(':nomeEsercizio', $nomeEsercizio, PDO::PARAM_STR);
    $editEsecuzione->bindParam(':ripetizioni', $ripetizioni, PDO::PARAM_INT);
    $editEsecuzione->bindParam(':kg', $kg, PDO::PARAM_STR);
    $editEsecuzione->bindParam(':note', $note, PDO::PARAM_STR);

    $editEsecuzione->execute();
}

function deleteAllenamento($dataReq): void{
    $connessione=connect("localhost", "root", "", "smartlog");

    $trainingID=$dataReq['deleteID']??null;

    if($trainingID == null) throw new Exception("Campi mancanti", 422);

    $deleteAllenamentoQuery="DELETE FROM allenamenti WHERE trainingID=:trainingID";

    $deleteAllenamento=$connessione->prepare($deleteAllenamentoQuery);

    $deleteAllenamento->execute(
        [
            "trainingID"=>$trainingID,
        ]
    );
}

function deleteEsecuzione($dataReq): void{
    $connessione=connect("localhost", "root", "", "smartlog");

    $executionID=$dataReq['deleteID']??null;

    if($executionID == null) throw new Exception("Campi mancanti", 422);

    $deleteEsecuzioneQuery="DELETE FROM esecuzioni WHERE executionID=:executionID";

    $deleteEsecuzione=$connessione->prepare($deleteEsecuzioneQuery);

    $deleteEsecuzione->execute(
        [
            "executionID"=>$executionID,
        ]
    );
}

function handlePost($dataReq): string{
    //in Flutter ho il campo request nella mappa che indica l'operazione POST che voglio eseguire
    $requestType=$dataReq['request']??null;

    switch ($requestType) {
        case "registrazione":
            handleSignup($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Registrazione avvenuta con successo',  null));
            http_response_code(201); //201=created
            break;
        case "login":
            $user=handleLogin($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Login avvenuto con successo', $user));
            http_response_code(200); //200=ok
            break;
        case "addAllenamento":
            $insertedAllenamento=addAllenamento($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Allenamento inserito con successo', $insertedAllenamento));
            http_response_code(201);
            break;
        case "addEsecuzione":
            $insertedEsecuzione=addEsecuzione($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Esecuzione inserita con successo', $insertedEsecuzione));
            http_response_code(201);
            break;
        default:
            //Richiesta non riconosciutan
            throw new Exception("Richiesta '$requestType' non supportata", 400);
            break;
    }

    return $JSONres;
}

function handleGet($dataReq): string{
    $requestType=$dataReq['request']??null;

    switch ($requestType) {
        case "fetchAllenamenti":
            $uid=$dataReq['uid'];
            $allenamenti=fetchAllenamenti(['uid'=>$uid]);
            $JSONres=json_encode(generateResponse('success', 'Allenamenti ottenuti con successo', $allenamenti));
            http_response_code(200); //200=ok
            break;
        default:
            throw new Exception("Richiesta '$requestType' non supportata", 400);
            break;
    }

    return $JSONres;
}

function handlePut($dataReq): string{
    $requestType=$dataReq['request']??null;

    switch($requestType){
        case "editAllenamento":
            editAllenamento($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Allenamento modificato con successo', null));
            http_response_code(200);
            break;
        case "editEsecuzione":
            editEsecuzione($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Esecuzione modificata con successo', null));
            http_response_code(200);
            break;
        default:
            throw new Exception("Richiesta '$requestType' non supportata", 400);
            break;
    }

    return $JSONres;
}

function handleDelete($dataReq): string{
    $requestType=$dataReq['request']??null;

    switch ($requestType){
        case "allenamenti":
            deleteAllenamento($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Allenamento eliminato con successo', null));
            http_response_code(200);
            break;
        case "esecuzioni":
            deleteEsecuzione($dataReq);
            $JSONres=json_encode(generateResponse('success', 'Esecuzione eliminata con successo', null));
            http_response_code(200);
            break;
        default:
            throw new Exception("Richiesta '$requestType' non supportata", 400);
            breaK;
    }

    return $JSONres;
}