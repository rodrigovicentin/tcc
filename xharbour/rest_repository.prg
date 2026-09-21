#define QUEBRA_LINHA Chr(13) + Chr(10)

MEMVAR cEmpresa, cFilial, cCapturaErroGlobal
MEMVAR _query, _uri, _body
MEMVAR _aList, _aItens
FIELD ID, ROTA, ACAO, VERSAO, REQUEST, MACRO, RESPONSE, QUERYPARAM

Function PrepararExecucaoMacro(hReq)
    Local cAcao := Lower(AllTrim(hReq["acao_rota"]))
    Local cRota := Lower(AllTrim(hReq["rota"]))
    Local cVersao := Lower(AllTrim(hReq["versao"]))
    Local cMacro := "", cReqBody := "", cResponse := ""

    If ObterRotaConfiguradaDb(cAcao, cRota, cVersao)
        cMacro := ROTAS->MACRO
        cReqBody := ROTAS->REQUEST
        cResponse := ROTAS->RESPONSE
        cMacro := StrTran(cMacro, Chr(13) + Chr(10), "")
        cMacro := StrTran(cMacro, Chr(10), "")
        cMacro := StrTran(cMacro, Chr(13), "")
    Else
        cCapturaErroGlobal := "Rota nao localizada."
        Return {.F., cCapturaErroGlobal, "", ""}
    EndIf
Return {.T., cMacro, cReqBody, cResponse}

Procedure MontarEstruturaRotasDb()
    Local aDB := {}, cReq := "", cRet := "", cQueryParams := ""

    Set Date British
    Set Century On
    Set Deleted On

    If !File("ROTAS.DBF")
        aDB := {}
        AAdd(aDB, {"ID", "C", 5, 0})
        AAdd(aDB, {"ROTA", "C", 50, 0}); AAdd(aDB, {"ACAO", "C", 10, 0}); AAdd(aDB, {"VERSAO", "C", 5, 0})
        AAdd(aDB, {"REQUEST", "M", 10, 0}); AAdd(aDB, {"MACRO", "M", 10, 0}); AAdd(aDB, {"RESPONSE", "M", 10, 0})
        AAdd(aDB, {"QUERYPARAM", "M", 10, 0})
        DbCreate("ROTAS.DBF", aDB)

        USE ROTAS EXCLUSIVE NEW ALIAS ROTAS
        INDEX ON Upper(ID) TO ROTAS_ID
        INDEX ON Upper(ACAO) + Upper(ROTA) + Upper(VERSAO) TO ROTAS_ROTA
        INDEX ON Upper(ROTA) TO ROTAS_ROTA_NOME
        INDEX ON Upper(VERSAO) TO ROTAS_VERSAO
        INDEX ON Upper(ACAO) TO ROTAS_ACAO
        CLOSE ROTAS

        Use ROTAS Shared Alias ROTAS New
        dbSetIndex("ROTAS_ID"); dbSetIndex("ROTAS_ROTA"); dbSetIndex("ROTAS_ROTA_NOME"); dbSetIndex("ROTAS_VERSAO"); dbSetIndex("ROTAS_ACAO")

        cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
        cReq := ""
        cRet := '{' + QUEBRA_LINHA + ;
                '  "count": 1,' + QUEBRA_LINHA + ;
                '  "dados": [' + QUEBRA_LINHA + ;
                '    {' + QUEBRA_LINHA + ;
                '      "versao": "v1",' + QUEBRA_LINHA + ;
                '      "rota": "clientes",' + QUEBRA_LINHA + ;
                '      "count": 1,' + QUEBRA_LINHA + ;
                '      "acoes": [' + QUEBRA_LINHA + ;
                '        {' + QUEBRA_LINHA + ;
                '          "id": "1",' + QUEBRA_LINHA + ;
                '          "acao": "get",' + QUEBRA_LINHA + ;
                '          "fonte": "Listar...",' + QUEBRA_LINHA + ;
                '          "request": "",' + QUEBRA_LINHA + ;
                '          "response": "",' + QUEBRA_LINHA + ;
                '          "queryparams": ""' + QUEBRA_LINHA + ;
                '        }' + QUEBRA_LINHA + ;
                '      ]' + QUEBRA_LINHA + ;
                '    }' + QUEBRA_LINHA + ;
                '  ]' + QUEBRA_LINHA + ;
                '}'
        PersistirConfiguracaoRotaDb("", "v1", "get", "rotas", GerarMacroGetRotas(), cReq, cRet, cQueryParams, .T.)

        cQueryParams := ""
        cReq := ""
        cRet := '{' + QUEBRA_LINHA + ;
                '  "id": "00001",' + QUEBRA_LINHA + ;
                '  "acao": "get",' + QUEBRA_LINHA + ;
                '  "rota": "clientes",' + QUEBRA_LINHA + ;
                '  "fonte": "...",' + QUEBRA_LINHA + ;
                '  "versao": "v1",' + QUEBRA_LINHA + ;
                '  "request": "",' + QUEBRA_LINHA + ;
                '  "response": "",' + QUEBRA_LINHA + ;
                '  "queryparams": ""' + QUEBRA_LINHA + ;
                '}'
        PersistirConfiguracaoRotaDb("", "v1", "getid", "rotas", GerarMacroGetIdRotas(), cReq, cRet, cQueryParams, .T.)

        cQueryParams := ""
        cReq := '{' + QUEBRA_LINHA + ;
                '  "versao": "v1",' + QUEBRA_LINHA + ;
                '  "acao": "get",' + QUEBRA_LINHA + ;
                '  "rota": "exemplo",' + QUEBRA_LINHA + ;
                '  "fonte": "...",' + QUEBRA_LINHA + ;
                '  "request": "",' + QUEBRA_LINHA + ;
                '  "response": "",' + QUEBRA_LINHA + ;
                '  "queryparams": ""' + QUEBRA_LINHA + ;
                '}'
        cRet := '{' + QUEBRA_LINHA + ;
                '  "id": "00001",' + QUEBRA_LINHA + ;
                '  "versao": "v1",' + QUEBRA_LINHA + ;
                '  "acao": "get",' + QUEBRA_LINHA + ;
                '  "rota": "exemplo",' + QUEBRA_LINHA + ;
                '  "fonte": "...",' + QUEBRA_LINHA + ;
                '  "request": "",' + QUEBRA_LINHA + ;
                '  "response": "",' + QUEBRA_LINHA + ;
                '  "queryparams": ""' + QUEBRA_LINHA + ;
                '}'
        PersistirConfiguracaoRotaDb("", "v1", "post", "rotas", GerarMacroPostRota(), cReq, cRet, cQueryParams, .T.)
        PersistirConfiguracaoRotaDb("", "v1", "put", "rotas", GerarMacroPutRota(), cReq, cRet, cQueryParams, .T.)
        PersistirConfiguracaoRotaDb("", "v1", "delete", "rotas", GerarMacroDeleteRota(), "", "", cQueryParams, .T.)
    EndIf

    dbCloseAll()
    dbUseArea(.T., Nil, "ROTAS.DBF", "ROTAS", .T., .F.)
    SET INDEX TO ROTAS_ROTA, ROTAS_ID, ROTAS_ROTA_NOME, ROTAS_VERSAO, ROTAS_ACAO
Return

Function PersistirConfiguracaoRotaDb(cIdRota, cVersao, cAcao, cRota, cMacro, cReq, cResponse, cQueryParams, lCarga)
    If ValType(lCarga) == "U"; lCarga := .F.; EndIf
    If ValType(cReq) == "U"; cReq := ""; EndIf
    If ValType(cResponse) == "U"; cResponse := ""; EndIf
    If ValType(cQueryParams) == "U"; cQueryParams := ""; EndIf

    If Empty(cAcao) .Or. Empty(cMacro)
        cCapturaErroGlobal := "Campos acao e fonte (macro) sao obrigatorios."
        Return ""
    EndIf

    dbSelectArea("ROTAS")
    If ValType(cIdRota) == "U" .Or. Empty(cIdRota)
        cIdRota := ObterProximoIdRotaDb()
        Append Blank
    Else
        If !VerificarExistenciaIdDb(cIdRota)
            cCapturaErroGlobal := "Rota nao localizada."
            Return ""
        Else
            RLock()
        EndIf
    EndIf

    Replace ID With cIdRota, VERSAO With cVersao, ACAO With cAcao, ROTA With cRota, ;
            MACRO With cMacro, REQUEST With cReq, RESPONSE With cResponse, QUERYPARAM With cQueryParams
    dbUnlock()
Return cIdRota

Function ObterRotaConfiguradaDb(cAcao, cRota, cVersao)
    Local cChave := Upper(PadR(cAcao, 10)) + Upper(PadR(cRota, 50)) + Upper(PadR(cVersao, 5))

    dbSelectArea("ROTAS")
    OrdSetFocus("ROTAS_ROTA")
    If DbSeek(cChave); Return .T.; EndIf
Return .F.

Function VerificarExistenciaIdDb(cIdBusca)
    cIdBusca := Upper(PadR(cIdBusca, 5))
    dbSelectArea("ROTAS")
    OrdSetFocus("ROTAS_ID")
    dbGoTop()
Return DbSeek(cIdBusca)

Function ObterProximoIdRotaDb()
    Local nMax := 0, cArea := Select()
    dbSelectArea("ROTAS")
    DbGoTop()
    While !Eof()
        If Val(ID) > nMax; nMax := Val(ID); EndIf
        DbSkip()
    EndDo
    Select (cArea)
Return PadL(LTrim(Str(nMax + 1)), 5, "0")

Function RemoverConfiguracaoRotaDb(cIdExclusao)
    If !VerificarExistenciaIdDb(cIdExclusao)
        cCapturaErroGlobal := "Rota nao localizada."
        Return .F.
    EndIf
    RLock(); dbDelete(); dbUnlock(); dbCommit()
Return .T.

Function ObterRotaPorIdDb(cId)
    Local aItem := {}
    cId := Upper(PadR(cId, 5))
    dbSelectArea("ROTAS")
    OrdSetFocus("ROTAS_ID")
    
    If DbSeek(cId)
        aItem := {AllTrim(ID), AllTrim(ACAO), AllTrim(ROTA), ;
                  AllTrim(MACRO), AllTrim(VERSAO), AllTrim(REQUEST), AllTrim(RESPONSE), AllTrim(QUERYPARAM)}
    Else
        cCapturaErroGlobal := "Rota nao encontrada."
    EndIf
Return aItem

Function ListarTodasRotasDb(nOrdem, cSentido, nStart, nLimite, cFiltro)
    Local aRes := {}, hGrupos := {=>}, aChaves := {}
    Local nSkipped := 0, nAdded := 0, nI := 0, cChave := ""
    Local hMeta := {=>}

    If ValType(nOrdem) == "U"; nOrdem := 1; EndIf
    If ValType(cSentido) == "U"; cSentido := "ASC"; EndIf
    If ValType(nStart) == "U"; nStart := 0; EndIf
    If ValType(nLimite) == "U"; nLimite := 10; EndIf
    If ValType(cFiltro) == "U"; cFiltro := ""; EndIf

    dbSelectArea("ROTAS")
    OrdSetFocus(IIf(nOrdem == 1, "ROTAS_ID", "ROTAS_ROTA_NOME"))

    If cSentido == "DESC"; DbGoBottom(); Else; DbGoTop(); EndIf

    While IIf(cSentido == "DESC", !Bof(), !Eof())
        If Empty(cFiltro) .Or. AllTrim(Upper(cFiltro)) $ Upper(ROTA)
            cChave := AllTrim(ROTA)
            If !HHasKey(hGrupos, cChave)
                hGrupos[cChave] := {}
                hMeta[cChave] := { "versao" => AllTrim(VERSAO) }
                AAdd(aChaves, cChave)
            EndIf
            AAdd(hGrupos[cChave], {AllTrim(ID), AllTrim(ACAO), AllTrim(MACRO), AllTrim(REQUEST), AllTrim(RESPONSE), AllTrim(QUERYPARAM)})
        EndIf

        If cSentido == "DESC"; DbSkip(-1); Else; DbSkip(); EndIf
    EndDo

    For nI := 1 To Len(aChaves)
        If nSkipped < nStart; nSkipped++; Loop; EndIf
        If nAdded >= nLimite; Exit; EndIf

        cChave := aChaves[nI]
        AAdd(aRes, { hMeta[cChave]["versao"], cChave, Len(hGrupos[cChave]), hGrupos[cChave] })
        nAdded++
    Next
Return { Len(aChaves), aRes }

Function GerarMacroGetRotas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ListarTodasRotasDb(' + QUEBRA_LINHA
    c += '        IIf(Type("_query") == "H" .And. HHasKey(_query, "indice"), Val(_query["indice"]), 1),' + QUEBRA_LINHA
    c += '        IIf(Type("_query") == "H" .And. HHasKey(_query, "ordem"), _query["ordem"], "ASC"),' + QUEBRA_LINHA
    c += '        IIf(Type("_query") == "H" .And. HHasKey(_query, "inicio"), Val(_query["inicio"]), 0),' + QUEBRA_LINHA
    c += '        IIf(Type("_query") == "H" .And. HHasKey(_query, "limite"), Val(_query["limite"]), 10),' + QUEBRA_LINHA
    c += '        IIf(Type("_query") == "H" .And. HHasKey(_query, "filtro"), _query["filtro"], "")' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    _aList := {},' + QUEBRA_LINHA
    c += '    AEval(' + QUEBRA_LINHA
    c += '        aRes[2],' + QUEBRA_LINHA
    c += '        {|a|' + QUEBRA_LINHA
    c += '            _aItens := {},' + QUEBRA_LINHA
    c += '            AEval(' + QUEBRA_LINHA
    c += '                a[4],' + QUEBRA_LINHA
    c += '                {|i|' + QUEBRA_LINHA
    c += '                    hObj := {=>},' + QUEBRA_LINHA
    c += '                    hObj["id"] := i[1],' + QUEBRA_LINHA
    c += '                    hObj["acao"] := i[2],' + QUEBRA_LINHA
    c += '                    hObj["fonte"] := i[3],' + QUEBRA_LINHA
    c += '                    hObj["request"] := i[4],' + QUEBRA_LINHA
    c += '                    hObj["response"] := i[5],' + QUEBRA_LINHA
    c += '                    hObj["queryparams"] := i[6],' + QUEBRA_LINHA
    c += '                    AAdd(_aItens, hObj)' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            ),' + QUEBRA_LINHA
    c += '            hObj := {=>},' + QUEBRA_LINHA
    c += '            hObj["versao"] := a[1],' + QUEBRA_LINHA
    c += '            hObj["rota"] := a[2],' + QUEBRA_LINHA
    c += '            hObj["count"] := a[3],' + QUEBRA_LINHA
    c += '            hObj["acoes"] := _aItens,' + QUEBRA_LINHA
    c += '            AAdd(_aList, hObj)' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    hRet := {=>},' + QUEBRA_LINHA
    c += '    hRet["count"] := aRes[1],' + QUEBRA_LINHA
    c += '    hRet["dados"] := _aList,' + QUEBRA_LINHA
    c += '    hRet' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroGetIdRotas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterRotaPorIdDb(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "acao" => aRes[2],' + QUEBRA_LINHA
    c += '            "rota" => aRes[3],' + QUEBRA_LINHA
    c += '            "fonte" => aRes[4],' + QUEBRA_LINHA
    c += '            "versao" => aRes[5],' + QUEBRA_LINHA
    c += '            "request" => aRes[6],' + QUEBRA_LINHA
    c += '            "response" => aRes[7],' + QUEBRA_LINHA
    c += '            "queryparams" => aRes[8]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPostRota()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    cIdAux := PersistirConfiguracaoRotaDb(' + QUEBRA_LINHA
    c += '        "",' + QUEBRA_LINHA
    c += '        _body["versao"],' + QUEBRA_LINHA
    c += '        _body["acao"],' + QUEBRA_LINHA
    c += '        _body["rota"],' + QUEBRA_LINHA
    c += '        _body["fonte"],' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "request"), _body["request"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "response"), _body["response"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "queryparams"), _body["queryparams"], ""),' + QUEBRA_LINHA
    c += '        .F.' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterRotaPorIdDb(cIdAux),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "acao" => aRes[2],' + QUEBRA_LINHA
    c += '            "rota" => aRes[3],' + QUEBRA_LINHA
    c += '            "fonte" => aRes[4],' + QUEBRA_LINHA
    c += '            "versao" => aRes[5],' + QUEBRA_LINHA
    c += '            "request" => aRes[6],' + QUEBRA_LINHA
    c += '            "response" => aRes[7],' + QUEBRA_LINHA
    c += '            "queryparams" => aRes[8]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPutRota()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    cIdAux := PersistirConfiguracaoRotaDb(' + QUEBRA_LINHA
    c += '        _uri["id"],' + QUEBRA_LINHA
    c += '        _body["versao"],' + QUEBRA_LINHA
    c += '        _body["acao"],' + QUEBRA_LINHA
    c += '        _body["rota"],' + QUEBRA_LINHA
    c += '        _body["fonte"],' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "request"), _body["request"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "response"), _body["response"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "queryparams"), _body["queryparams"], ""),' + QUEBRA_LINHA
    c += '        .F.' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterRotaPorIdDb(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "acao" => aRes[2],' + QUEBRA_LINHA
    c += '            "rota" => aRes[3],' + QUEBRA_LINHA
    c += '            "fonte" => aRes[4],' + QUEBRA_LINHA
    c += '            "versao" => aRes[5],' + QUEBRA_LINHA
    c += '            "request" => aRes[6],' + QUEBRA_LINHA
    c += '            "response" => aRes[7],' + QUEBRA_LINHA
    c += '            "queryparams" => aRes[8]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroDeleteRota()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        RemoverConfiguracaoRotaDb(_uri["id"]),' + QUEBRA_LINHA
    c += '        {=>},' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c