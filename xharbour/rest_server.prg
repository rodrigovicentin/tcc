#define QUEBRA_LINHA Chr(13) + Chr(10)
#define TAM_BUFFER 8192

MEMVAR cEmpresa, cFilial, cErroGlobal, cCapturaErroGlobal
MEMVAR _query, _uri, _body
MEMVAR _aList, _aItens

Procedure Main()
    Local nPorta := 8080
    Local nSock := 0
    Local nCli := 0
    Local cBuffer := ""
    Local cRes := ""

    Private cCapturaErroGlobal := ""

    MontarEstruturaRotasDb()

    OutStd("=============================================" + QUEBRA_LINHA)
    OutStd(" Servidor REST API xHarbour Rodando!         " + QUEBRA_LINHA)
    OutStd("=============================================" + QUEBRA_LINHA)

    INetInit()
    nSock := INetServer(nPorta)

    If nSock == Nil
        OutStd("Erro: Falha de abertura na porta." + QUEBRA_LINHA)
        Return
    EndIf

    While .T.
        nCli := INetAccept(nSock)
        
        If nCli != Nil
            cBuffer := Space(TAM_BUFFER)
            INetRecv(nCli, @cBuffer)

            cRes := ProcessarReq(cBuffer)

            INetSend(nCli, cRes)
            INetClose(nCli)
        EndIf
    EndDo

    INetClose(nSock)
    INetCleanup()
Return

Function ProcessarReq(cBuffer)
    Local hReq := AnalisarRotaUrl(Left(cBuffer, At(QUEBRA_LINHA, cBuffer) - 1))
    Local hQuery := ExtrairParams(hReq["parametros"])
    Local hUri := ExtrairParams(hReq["uriparams"])
    Local hBody := {=>}
    Local cEmp := "", cFil := "", nIdx := 0
    Local cResMacro := "", aMacro := {}, cResFinal := ""
    Local hErro := {=>}, cAcao := Lower(hReq["acao"]), cAcaoRota := cAcao

    hb_jsonDecode(StrTran(SubStr(cBuffer, At(QUEBRA_LINHA + QUEBRA_LINHA, cBuffer) + 4), Chr(0), ""), @hBody)

    Private _query := hQuery
    Private _uri := hUri
    Private _body := hBody
    Private _aList := {}, _aItens := {}

    If cAcaoRota == "get" .And. HHasKey(hUri, "id")
        cAcaoRota := "getid"
    EndIf
    
    hReq["acao_rota"] := cAcaoRota

    For nIdx := 1 To Len(hReq["uriparams"])
        If HHasKey(hReq["uriparams"][nIdx], "empresas")
            cEmp := hReq["uriparams"][nIdx]["empresas"]
        EndIf
        If HHasKey(hReq["uriparams"][nIdx], "filiais")
            cFil := hReq["uriparams"][nIdx]["filiais"]
        EndIf
    Next

    ConfigurarAmbienteDeDados(cEmp, cFil)

    aMacro := PrepararExecucaoMacro(hReq)

    If Empty(cCapturaErroGlobal)
        If aMacro[1]
            cResMacro := ExecutarInstrucao(aMacro[2])
        Else
            cCapturaErroGlobal := aMacro[2]
        EndIf
    EndIf

    If Empty(cCapturaErroGlobal)
        cCapturaErroGlobal := cErroGlobal
    EndIf
    
    FinalizarAmbienteDeDados()

    If Empty(cCapturaErroGlobal)
        If cAcao == "post"
            cResFinal := "HTTP/1.1 201 Created" + QUEBRA_LINHA + ;
                         "Content-Type: application/json; charset=utf-8" + QUEBRA_LINHA + ;
                         "Access-Control-Allow-Origin: *" + QUEBRA_LINHA + ;
                         "Connection: close" + QUEBRA_LINHA + QUEBRA_LINHA + ;
                         cResMacro
        ElseIf cAcao == "put" .Or. cAcao == "get" .Or. cAcao == "getid"
            cResFinal := "HTTP/1.1 200 OK" + QUEBRA_LINHA + ;
                         "Content-Type: application/json; charset=utf-8" + QUEBRA_LINHA + ;
                         "Access-Control-Allow-Origin: *" + QUEBRA_LINHA + ;
                         "Connection: close" + QUEBRA_LINHA + QUEBRA_LINHA + ;
                         cResMacro
        ElseIf cAcao == "delete"
            cResFinal := "HTTP/1.1 204 No Content" + QUEBRA_LINHA + ;
                         "Access-Control-Allow-Origin: *" + QUEBRA_LINHA + ;
                         "Connection: close" + QUEBRA_LINHA + QUEBRA_LINHA
        EndIf
    Else
        hErro := {=>}
        hErro["type"] := "https://suaempresa.com"
        hErro["title"] := "Dados invalidos na requisicao"
        hErro["status"] := 400
        hErro["detail"] := cCapturaErroGlobal
        hErro["instance"] := hReq["rota"]
        hErro["invalidparameters"] := {}

        hErro["request"] := IIf(Len(aMacro) >= 4 .And. !Empty(aMacro[3]), aMacro[3], "")
        hErro["response"] := IIf(Len(aMacro) >= 4 .And. !Empty(aMacro[4]), aMacro[4], "")

        cResFinal := "HTTP/1.1 400 Bad Request" + QUEBRA_LINHA + ;
                     "Content-Type: application/problem+json; charset=utf-8" + QUEBRA_LINHA + ;
                     "Access-Control-Allow-Origin: *" + QUEBRA_LINHA + ;
                     "Connection: close" + QUEBRA_LINHA + QUEBRA_LINHA + ;
                     hb_jsonEncode(hErro)
    EndIf

    cCapturaErroGlobal := ""
Return cResFinal

Function ExecutarInstrucao(cCmd)
    Local bBloco, oErr, xRet

    TRY
        If !Empty(cCmd)
            bBloco := &( "{|| " + cCmd + " }" )
            xRet := Eval(bBloco)
        EndIf
    CATCH oErr
        cCapturaErroGlobal := oErr:Description
    FINALLY
        xRet := ConverterVarParaTexto(xRet)
    END
Return xRet

Function AnalisarRotaUrl(cStrReq)
    Local aPartes := hb_ATokens(cStrReq, " ")
    Local cAcao := "", cUri := "", cProto := "", nPos := 0
    Local cRotaBase := "", cQuery := "", aPares := {}, cPar := ""
    Local nIgual := 0, cChave := "", cValor := ""
    Local aQuery := {}, aUri := {}, hRet := {=>}, hItem := {=>}
    Local aCampos := {}, aLimpas := {}, cCampo := "", nStart := 1, nLoop := 1
    Local cRotaDin := ""

    hRet["rota"] := ""; hRet["acao"] := ""; hRet["versao"] := ""
    hRet["http"] := ""; hRet["parametros"] := {}; hRet["uriparams"] := {}

    If Len(aPartes) < 3; Return {=>}; EndIf

    cAcao := aPartes[1]; cUri := aPartes[2]; cProto := aPartes[3]
    nPos := At("?", cUri)

    If nPos > 0
        cRotaBase := SubStr(cUri, 1, nPos - 1)
        cQuery := SubStr(cUri, nPos + 1)
    Else
        cRotaBase := cUri
        cQuery := ""
    EndIf

    If Left(cRotaBase, 1) == "/"
        cRotaBase := SubStr(cRotaBase, 2)
    EndIf

    If !Empty(cQuery)
        aPares := hb_ATokens(cQuery, "&")
        For Each cPar IN aPares
            nIgual := At("=", cPar)
            If nIgual > 0
                cChave := DecodificarUrl(SubStr(cPar, 1, nIgual - 1))
                cValor := DecodificarUrl(SubStr(cPar, nIgual + 1))
            Else
                cChave := DecodificarUrl(cPar); cValor := ""
            EndIf
            hItem := {=>}; hItem[cChave] := cValor
            AAdd(aQuery, hItem)
        Next
    EndIf

    aCampos := hb_ATokens(cRotaBase, "/")
    For Each cCampo IN aCampos
        If !Empty(cCampo); AAdd(aLimpas, cCampo); EndIf
    Next

    If Len(aLimpas) >= 2 .And. Lower(aLimpas[1]) == "middle"
        hRet["versao"] := aLimpas[2]; nStart := 3
    EndIf

    nLoop := nStart
    While nLoop <= Len(aLimpas)
        cRotaDin := aLimpas[nLoop]
        If nLoop == Len(aLimpas); Exit; EndIf

        If Left(Lower(aLimpas[nLoop+1]), 1) == "v" .And. IsDigit(SubStr(aLimpas[nLoop+1], 2, 1))
            cRotaDin := aLimpas[nLoop]
            hRet["versao"] := Lower(aLimpas[nLoop+1])
            If nLoop + 2 <= Len(aLimpas)
                hItem := {=>}; hItem["id"] := aLimpas[nLoop+2]
                AAdd(aUri, hItem)
            EndIf
            Exit
        Else
            If nLoop == Len(aLimpas) - 1
                hItem := {=>}; hItem["id"] := aLimpas[nLoop+1]
                AAdd(aUri, hItem)
                Exit
            Else
                hItem := {=>}; hItem[aLimpas[nLoop]] := aLimpas[nLoop+1]
                AAdd(aUri, hItem)
                nLoop += 2
            EndIf
        EndIf
    EndDo

    hRet["acao"] := cAcao
    hRet["rota"] := cRotaDin
    hRet["http"] := cProto
    hRet["parametros"] := aQuery
    hRet["uriparams"] := aUri
Return hRet

Function DecodificarUrl(cStr)
    Local cRes := "", nIdx := 1, cChar := "", cHex := ""
    cStr := StrTran(cStr, "+", " ")
    While nIdx <= Len(cStr)
        cChar := SubStr(cStr, nIdx, 1)
        If cChar == "%" .And. nIdx + 2 <= Len(cStr)
            cHex := SubStr(cStr, nIdx + 1, 2)
            cRes += Chr(HexDec(cHex))
            nIdx += 3
        Else
            cRes += cChar; nIdx += 1
        EndIf
    EndDo
Return cRes

Function HexDec(cHex)
    Local nDec := 0, nI := 1, cD := "", nV := 0
    cHex := Upper(cHex)
    For nI := 1 To Len(cHex)
        cD := SubStr(cHex, nI, 1)
        If cD >= "0" .And. cD <= "9"
            nV := Asc(cD) - Asc("0")
        Else
            nV := Asc(cD) - Asc("A") + 10
        EndIf
        nDec := nDec * 16 + nV
    Next
Return nDec

Function ExtrairParams(aVetor)
    Local aChaves := {}, cChave := "", nI := 0, hRet := {=>}
    For nI := 1 To Len(aVetor)
        aChaves := HGetKeys(aVetor[nI])
        If Len(aChaves) > 0
            cChave := aChaves[1]
            hRet[cChave] := aVetor[nI][cChave]
        EndIf
    Next nI
Return hRet

Function ConverterVarParaTexto(xVar)
    Local cTipo := ValType(xVar), cRes := ""
    DO CASE
        CASE cTipo == "C" .OR. cTipo == "M"; cRes := xVar
        CASE cTipo == "N"; cRes := LTrim(Str(xVar))
        CASE cTipo == "D"; cRes := IIf(Empty(xVar), "", DToC(xVar))
        CASE cTipo == "L"; cRes := IIf(xVar, "true", "false")
        CASE cTipo == "U"; cRes := "null"
        CASE cTipo == "A" .OR. cTipo == "H"; cRes := hb_jsonEncode(xVar)
        CASE cTipo == "O"; cRes := "[OBJECT]"
        CASE cTipo == "B"; cRes := "[CODEBLOCK]"
        OTHERWISE; cRes := "[UNKNOWN TYPE]"
    ENDCASE
Return cRes