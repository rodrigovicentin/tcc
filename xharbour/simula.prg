#define QUEBRA_LINHA Chr(13) + Chr(10)
MEMVAR cEmpresa, cFilial

Procedure Main()
    OutStd("=============================================" + QUEBRA_LINHA)
    OutStd(" INICIANDO ROTINAS DE SIMULACAO              " + QUEBRA_LINHA)
    OutStd("=============================================" + QUEBRA_LINHA)

    ExecutarPopular()
    ExecutarRotas()
    ExecutarExportar()
    
    OutStd(QUEBRA_LINHA + " -> PROCESSO FINALIZADO COM SUCESSO!         " + QUEBRA_LINHA)
Return

// =========================================================================
// 1. POPULAR.PRG (CARGA MASSIVA)
// =========================================================================
Procedure ExecutarPopular()
    Local aNomes := {"JOAO", "MARIA", "JOSE", "ANA", "CARLOS", "PAULO", "LUCAS", "MARCOS", "JULIA", "FERNANDA", "RAFAEL", "GABRIEL", "BRUNA", "AMANDA", "FELIPE", "TIAGO", "RODRIGO", "ALINE", "CAMILA", "BRUNO"}
    Local aSobrenomes := {"SILVA", "SANTOS", "OLIVEIRA", "SOUZA", "RODRIGUES", "FERREIRA", "ALVES", "PEREIRA", "LIMA", "GOMES", "COSTA", "RIBEIRO", "MARTINS", "CARVALHO", "ALMEIDA", "LOPES", "SOARES", "FERNANDES", "VIEIRA", "BARBOSA"}
    Local aProds := {"CADERNO", "CANETA", "LAPIS", "BORRACHA", "REGUA", "GRAMPEADOR", "CLIPE", "PASTA", "MOCHILA", "MARCADOR", "ESTOJO", "TESOURA", "FITA", "BLOCO", "CALCULADORA", "ENVELOPE", "AGENDA", "PRANCHETA", "ETIQUETA", "PINCEL"}
    Local aMarcas := {"TOP", "PREMIUM", "MAX", "PRO", "STANDARD", "ECO", "OFFICE", "MASTER", "GOLD", "LITE", "FLEX", "SUPER", "BASIC", "ULTRA", "PLUS"}
    
    Local i, j, k, cNomeEmp, cNomeCli, cEmail, cNomeProd, nPreco
    Local aCliIds, aPrdIds, aItens, nQtdItens, aPrd, nQtd
    Local dStart, nDiff, dRand, cTime, cDthr

    OutStd(" [1/3] Iniciando povoamento massivo...       " + QUEBRA_LINHA)
    ConfigurarAmbienteDeDados("  ", "  ")
    dStart := CToD("01/01/2020")
    nDiff := Date() - dStart

    For i := 1 To 10
        If i == 10
            cEmpresa := "99"; cNomeEmp := "EMPRESA TESTE"
        Else
            cEmpresa := PadL(LTrim(Str(i)), 2, "0"); cNomeEmp := "EMPRESA " + cEmpresa + " COMERCIO LTDA"
        EndIf
        cFilial := "01"

        RegistrarNovaEmpresa(cNomeEmp, cNomeEmp, "12345678000" + PadL(LTrim(Str(i)), 3, "0"), cEmpresa, cFilial)

        For j := 1 To 100
            cNomeCli := aNomes[hb_RandomInt(1, Len(aNomes))] + " " + aSobrenomes[hb_RandomInt(1, Len(aSobrenomes))]
            cEmail := Lower(StrTran(cNomeCli, " ", ".")) + LTrim(Str(j)) + "@exemplo.com"
            RegistrarNovoCliente(cNomeCli, Date() - hb_RandomInt(7000, 15000), cEmail)
        Next

        For j := 1 To 100
            cNomeProd := aProds[hb_RandomInt(1, Len(aProds))] + " " + aMarcas[hb_RandomInt(1, Len(aMarcas))] + " MOD." + LTrim(Str(j))
            nPreco := hb_RandomInt(5, 500) + (hb_RandomInt(0, 99) / 100)
            RegistrarNovoProduto(cNomeProd, nPreco)
        Next

        aCliIds := {}; aPrdIds := {}
        Select CLIENTES; DbGoTop()
        While !Eof(); If EMPRESA == cEmpresa .And. FILIAL == cFilial; AAdd(aCliIds, AllTrim(ID)); EndIf; DbSkip(); EndDo
        
        Select PRODUTOS; DbGoTop()
        While !Eof(); If EMPRESA == cEmpresa .And. FILIAL == cFilial; AAdd(aPrdIds, {AllTrim(ID), PRECO}); EndIf; DbSkip(); EndDo

        For j := 1 To 5000
            cNomeCli := aCliIds[hb_RandomInt(1, Len(aCliIds))]
            nQtdItens := hb_RandomInt(1, 5)
            aItens := {}
            
            For k := 1 To nQtdItens
                aPrd := aPrdIds[hb_RandomInt(1, Len(aPrdIds))]
                nQtd := hb_RandomInt(1, 20)
                AAdd(aItens, {aPrd[1], nQtd, aPrd[2], nQtd * aPrd[2]})
            Next
            
            dRand := dStart + hb_RandomInt(0, nDiff)
            cTime := PadL(LTrim(Str(hb_RandomInt(8, 18))), 2, "0") + ":" + PadL(LTrim(Str(hb_RandomInt(0, 59))), 2, "0")
            cDthr := DToC(dRand) + " " + cTime
            EfetivarNovoPedido(cNomeCli, aItens, cDthr)
        Next
    Next
    FinalizarAmbienteDeDados()
Return

// =========================================================================
// 2. ROTAS.PRG (CARGA DAS METADATAS)
// =========================================================================
Procedure ExecutarRotas()
    Local cReq := "", cRet := "", cQueryParams := ""

    OutStd(" [2/3] Carga de Rotas de Negocio...          " + QUEBRA_LINHA)
    MontarEstruturaRotasDb()

    If Select("ROTAS") == 0
        dbUseArea(.T., Nil, "ROTAS.DBF", "ROTAS", .F., .F.)
        Set Index To ROTAS_ROTA, ROTAS_ID, ROTAS_ROTA_NOME, ROTAS_VERSAO, ROTAS_ACAO
    EndIf

    // -------------------------------------------------------------------------
    // ESCOPO GLOBAL: ListaEmpresas
    // -------------------------------------------------------------------------
    cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dados": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "id": "00001",' + QUEBRA_LINHA + '      "fantasia": "Empresa",' + QUEBRA_LINHA + '      "razaosoc": "Razao",' + QUEBRA_LINHA + '      "cnpj": "00000000000000",' + QUEBRA_LINHA + '      "empresa": "99",' + QUEBRA_LINHA + '      "filial": "01"' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "get", "listaempresas", GerarMacroGetEmpresas(), cReq, cRet, cQueryParams, .F.)


    // -------------------------------------------------------------------------
    // ESCOPO LEGADO: Empresas, Clientes, Produtos, Pedidos
    // -------------------------------------------------------------------------

    // Empresas
    cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dados": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "id": "00001",' + QUEBRA_LINHA + '      "fantasia": "Empresa",' + QUEBRA_LINHA + '      "razaosoc": "Razao",' + QUEBRA_LINHA + '      "cnpj": "00000000000000",' + QUEBRA_LINHA + '      "empresa": "99",' + QUEBRA_LINHA + '      "filial": "01"' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "get", "empresas", GerarMacroGetEmpresas(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "fantasia": "Empresa",' + QUEBRA_LINHA + '  "razaosoc": "Razao",' + QUEBRA_LINHA + '  "cnpj": "00000000000000",' + QUEBRA_LINHA + '  "empresa": "99",' + QUEBRA_LINHA + '  "filial": "01"' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "getid", "empresas", GerarMacroGetIdEmpresas(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := '{' + QUEBRA_LINHA + '  "fantasia": "Empresa",' + QUEBRA_LINHA + '  "razaosoc": "Razao",' + QUEBRA_LINHA + '  "cnpj": "00000000000000",' + QUEBRA_LINHA + '  "empresa": "99",' + QUEBRA_LINHA + '  "filial": "01"' + QUEBRA_LINHA + '}'
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "fantasia": "Empresa",' + QUEBRA_LINHA + '  "razaosoc": "Razao",' + QUEBRA_LINHA + '  "cnpj": "00000000000000",' + QUEBRA_LINHA + '  "empresa": "99",' + QUEBRA_LINHA + '  "filial": "01"' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "post", "empresas", GerarMacroPostEmpresas(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "put", "empresas", GerarMacroPutEmpresas(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "delete", "empresas", GerarMacroDeleteEmpresas(), "", "", cQueryParams, .F.)

    // Clientes
    cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dados": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "id": "00001",' + QUEBRA_LINHA + '      "nome": "Teste",' + QUEBRA_LINHA + '      "dtnasc": "01/01/2000",' + QUEBRA_LINHA + '      "email": "teste@teste.com"' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "get", "clientes", GerarMacroGetClientes(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "nome": "Teste",' + QUEBRA_LINHA + '  "dtnasc": "01/01/2000",' + QUEBRA_LINHA + '  "email": "teste@teste.com"' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "getid", "clientes", GerarMacroGetIdClientes(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := '{' + QUEBRA_LINHA + '  "nome": "Teste",' + QUEBRA_LINHA + '  "dtnasc": "01/01/2000",' + QUEBRA_LINHA + '  "email": "teste@teste.com"' + QUEBRA_LINHA + '}'
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "nome": "Teste",' + QUEBRA_LINHA + '  "dtnasc": "01/01/2000",' + QUEBRA_LINHA + '  "email": "teste@teste.com"' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "post", "clientes", GerarMacroPostClientes(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "put", "clientes", GerarMacroPutClientes(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "delete", "clientes", GerarMacroDeleteClientes(), "", "", cQueryParams, .F.)

    // Produtos
    cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dados": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "id": "00001",' + QUEBRA_LINHA + '      "nome": "Produto",' + QUEBRA_LINHA + '      "preco": 10.0' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "get", "produtos", GerarMacroGetProdutos(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "nome": "Produto",' + QUEBRA_LINHA + '  "preco": 10.0' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "getid", "produtos", GerarMacroGetIdProdutos(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := '{' + QUEBRA_LINHA + '  "nome": "Produto",' + QUEBRA_LINHA + '  "preco": 10.0' + QUEBRA_LINHA + '}'
    cRet := '{' + QUEBRA_LINHA + '  "id": "00001",' + QUEBRA_LINHA + '  "nome": "Produto",' + QUEBRA_LINHA + '  "preco": 10.0' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "post", "produtos", GerarMacroPostProdutos(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "put", "produtos", GerarMacroPutProdutos(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "delete", "produtos", GerarMacroDeleteProdutos(), "", "", cQueryParams, .F.)

    // Pedidos
    cQueryParams := "indice=1&ordem=ASC&inicio=0&limite=10&filtro="
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dados": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "idped": "00001",' + QUEBRA_LINHA + '      "idcli": "00001",' + QUEBRA_LINHA + '      "nome_cliente": "Teste",' + QUEBRA_LINHA + '      "total": 10.0,' + QUEBRA_LINHA + '      "count": 1,' + QUEBRA_LINHA + '      "dthr": "01/01/2000 12:00",' + QUEBRA_LINHA + '      "itens": [' + QUEBRA_LINHA + '        {' + QUEBRA_LINHA + '          "idprod": "00001",' + QUEBRA_LINHA + '          "qtd": 1.0,' + QUEBRA_LINHA + '          "vlrunit": 10.0,' + QUEBRA_LINHA + '          "vlrtot": 10.0' + QUEBRA_LINHA + '        }' + QUEBRA_LINHA + '      ]' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "get", "pedidos", GerarMacroGetPedidos(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := ""
    cRet := '{' + QUEBRA_LINHA + '  "idped": "00001",' + QUEBRA_LINHA + '  "idcli": "00001",' + QUEBRA_LINHA + '  "nome_cliente": "Teste",' + QUEBRA_LINHA + '  "total": 10.0,' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dthr": "01/01/2000 12:00",' + QUEBRA_LINHA + '  "itens": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "idprod": "00001",' + QUEBRA_LINHA + '      "qtd": 1.0,' + QUEBRA_LINHA + '      "vlrunit": 10.0,' + QUEBRA_LINHA + '      "vlrtot": 10.0' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "getid", "pedidos", GerarMacroGetIdPedidos(), cReq, cRet, cQueryParams, .F.)

    cQueryParams := ""
    cReq := '{' + QUEBRA_LINHA + '  "idcli": "00001",' + QUEBRA_LINHA + '  "dthr": "01/01/2000 12:00",' + QUEBRA_LINHA + '  "itens": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "idprod": "00001",' + QUEBRA_LINHA + '      "qtd": 1.0,' + QUEBRA_LINHA + '      "vlrunit": 10.0,' + QUEBRA_LINHA + '      "vlrtot": 10.0' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    cRet := '{' + QUEBRA_LINHA + '  "idped": "00001",' + QUEBRA_LINHA + '  "idcli": "00001",' + QUEBRA_LINHA + '  "nome_cliente": "Teste",' + QUEBRA_LINHA + '  "total": 10.0,' + QUEBRA_LINHA + '  "count": 1,' + QUEBRA_LINHA + '  "dthr": "01/01/2000 12:00",' + QUEBRA_LINHA + '  "itens": [' + QUEBRA_LINHA + '    {' + QUEBRA_LINHA + '      "idprod": "00001",' + QUEBRA_LINHA + '      "qtd": 1.0,' + QUEBRA_LINHA + '      "vlrunit": 10.0,' + QUEBRA_LINHA + '      "vlrtot": 10.0' + QUEBRA_LINHA + '    }' + QUEBRA_LINHA + '  ]' + QUEBRA_LINHA + '}'
    PersistirConfiguracaoRotaDb("", "v1", "post", "pedidos", GerarMacroPostPedidos(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "put", "pedidos", GerarMacroPutPedidos(), cReq, cRet, cQueryParams, .F.)
    PersistirConfiguracaoRotaDb("", "v1", "delete", "pedidos", GerarMacroDeletePedidos(), "", "", cQueryParams, .F.)

    DbCloseArea()
Return

// --------------------------------------------------------------------------
// MACROS EMPRESAS E LISTAEMPRESAS
// --------------------------------------------------------------------------
Function GerarMacroGetEmpresas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterListaEmpresas(' + QUEBRA_LINHA
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
    c += '            AAdd(' + QUEBRA_LINHA
    c += '                _aList,' + QUEBRA_LINHA
    c += '                {' + QUEBRA_LINHA
    c += '                    "id" => a[1],' + QUEBRA_LINHA
    c += '                    "fantasia" => a[2],' + QUEBRA_LINHA
    c += '                    "razaosoc" => a[3],' + QUEBRA_LINHA
    c += '                    "cnpj" => a[4],' + QUEBRA_LINHA
    c += '                    "empresa" => a[5],' + QUEBRA_LINHA
    c += '                    "filial" => a[6]' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            )' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    hRet := {=>},' + QUEBRA_LINHA
    c += '    hRet["count"] := aRes[1],' + QUEBRA_LINHA
    c += '    hRet["dados"] := _aList,' + QUEBRA_LINHA
    c += '    hRet' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroGetIdEmpresas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterEmpresaPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "fantasia" => aRes[2],' + QUEBRA_LINHA
    c += '            "razaosoc" => aRes[3],' + QUEBRA_LINHA
    c += '            "cnpj" => aRes[4],' + QUEBRA_LINHA
    c += '            "empresa" => aRes[5],' + QUEBRA_LINHA
    c += '            "filial" => aRes[6]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPostEmpresas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    cIdAux := RegistrarNovaEmpresa(' + QUEBRA_LINHA
    c += '        _body["fantasia"],' + QUEBRA_LINHA
    c += '        _body["razaosoc"],' + QUEBRA_LINHA
    c += '        _body["cnpj"],' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "empresa"), _body["empresa"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "filial"), _body["filial"], "")' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterEmpresaPorId(cIdAux),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "fantasia" => aRes[2],' + QUEBRA_LINHA
    c += '            "razaosoc" => aRes[3],' + QUEBRA_LINHA
    c += '            "cnpj" => aRes[4],' + QUEBRA_LINHA
    c += '            "empresa" => aRes[5],' + QUEBRA_LINHA
    c += '            "filial" => aRes[6]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPutEmpresas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    lOk := AtualizarDadosEmpresa(' + QUEBRA_LINHA
    c += '        _uri["id"],' + QUEBRA_LINHA
    c += '        _body["fantasia"],' + QUEBRA_LINHA
    c += '        _body["razaosoc"],' + QUEBRA_LINHA
    c += '        _body["cnpj"],' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "empresa"), _body["empresa"], ""),' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "filial"), _body["filial"], "")' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterEmpresaPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        lOk .And. Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "fantasia" => aRes[2],' + QUEBRA_LINHA
    c += '            "razaosoc" => aRes[3],' + QUEBRA_LINHA
    c += '            "cnpj" => aRes[4],' + QUEBRA_LINHA
    c += '            "empresa" => aRes[5],' + QUEBRA_LINHA
    c += '            "filial" => aRes[6]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroDeleteEmpresas()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        RemoverEmpresa(_uri["id"]),' + QUEBRA_LINHA
    c += '        {=>},' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

// --------------------------------------------------------------------------
// MACROS CLIENTES
// --------------------------------------------------------------------------
Function GerarMacroGetClientes()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterListaClientes(' + QUEBRA_LINHA
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
    c += '            AAdd(' + QUEBRA_LINHA
    c += '                _aList,' + QUEBRA_LINHA
    c += '                {' + QUEBRA_LINHA
    c += '                    "id" => a[1],' + QUEBRA_LINHA
    c += '                    "nome" => a[2],' + QUEBRA_LINHA
    c += '                    "dtnasc" => a[3],' + QUEBRA_LINHA
    c += '                    "email" => a[4]' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            )' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    hRet := {=>},' + QUEBRA_LINHA
    c += '    hRet["count"] := aRes[1],' + QUEBRA_LINHA
    c += '    hRet["dados"] := _aList,' + QUEBRA_LINHA
    c += '    hRet' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroGetIdClientes()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterClientePorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "dtnasc" => aRes[3],' + QUEBRA_LINHA
    c += '            "email" => aRes[4]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPostClientes()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    cIdAux := RegistrarNovoCliente(' + QUEBRA_LINHA
    c += '        _body["nome"],' + QUEBRA_LINHA
    c += '        CToD(_body["dtnasc"]),' + QUEBRA_LINHA
    c += '        _body["email"]' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterClientePorId(cIdAux),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "dtnasc" => aRes[3],' + QUEBRA_LINHA
    c += '            "email" => aRes[4]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPutClientes()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    lOk := AtualizarDadosCliente(' + QUEBRA_LINHA
    c += '        _uri["id"],' + QUEBRA_LINHA
    c += '        _body["nome"],' + QUEBRA_LINHA
    c += '        CToD(_body["dtnasc"]),' + QUEBRA_LINHA
    c += '        _body["email"]' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterClientePorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        lOk .And. Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "dtnasc" => aRes[3],' + QUEBRA_LINHA
    c += '            "email" => aRes[4]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroDeleteClientes()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        RemoverCliente(_uri["id"]),' + QUEBRA_LINHA
    c += '        {=>},' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

// --------------------------------------------------------------------------
// MACROS PRODUTOS
// --------------------------------------------------------------------------
Function GerarMacroGetProdutos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterListaProdutos(' + QUEBRA_LINHA
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
    c += '            AAdd(' + QUEBRA_LINHA
    c += '                _aList,' + QUEBRA_LINHA
    c += '                {' + QUEBRA_LINHA
    c += '                    "id" => a[1],' + QUEBRA_LINHA
    c += '                    "nome" => a[2],' + QUEBRA_LINHA
    c += '                    "preco" => a[3]' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            )' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    hRet := {=>},' + QUEBRA_LINHA
    c += '    hRet["count"] := aRes[1],' + QUEBRA_LINHA
    c += '    hRet["dados"] := _aList,' + QUEBRA_LINHA
    c += '    hRet' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroGetIdProdutos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterProdutoPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "preco" => aRes[3]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPostProdutos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    cIdAux := RegistrarNovoProduto(' + QUEBRA_LINHA
    c += '        _body["nome"],' + QUEBRA_LINHA
    c += '        _body["preco"]' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterProdutoPorId(cIdAux),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "preco" => aRes[3]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPutProdutos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    lOk := AtualizarDadosProduto(' + QUEBRA_LINHA
    c += '        _uri["id"],' + QUEBRA_LINHA
    c += '        _body["nome"],' + QUEBRA_LINHA
    c += '        _body["preco"]' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterProdutoPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        lOk .And. Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "id" => aRes[1],' + QUEBRA_LINHA
    c += '            "nome" => aRes[2],' + QUEBRA_LINHA
    c += '            "preco" => aRes[3]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroDeleteProdutos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        RemoverProduto(_uri["id"]),' + QUEBRA_LINHA
    c += '        {=>},' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

// --------------------------------------------------------------------------
// MACROS PEDIDOS
// --------------------------------------------------------------------------
Function GerarMacroGetPedidos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterListaPedidos(' + QUEBRA_LINHA
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
    c += '                a[6],' + QUEBRA_LINHA
    c += '                {|i|' + QUEBRA_LINHA
    c += '                    AAdd(' + QUEBRA_LINHA
    c += '                        _aItens,' + QUEBRA_LINHA
    c += '                        {' + QUEBRA_LINHA
    c += '                            "idprod" => i[1],' + QUEBRA_LINHA
    c += '                            "qtd" => i[2],' + QUEBRA_LINHA
    c += '                            "vlrunit" => i[3],' + QUEBRA_LINHA
    c += '                            "vlrtot" => i[4]' + QUEBRA_LINHA
    c += '                        }' + QUEBRA_LINHA
    c += '                    )' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            ),' + QUEBRA_LINHA
    c += '            AAdd(' + QUEBRA_LINHA
    c += '                _aList,' + QUEBRA_LINHA
    c += '                {' + QUEBRA_LINHA
    c += '                    "idped" => a[1],' + QUEBRA_LINHA
    c += '                    "idcli" => a[2],' + QUEBRA_LINHA
    c += '                    "nome_cliente" => a[3],' + QUEBRA_LINHA
    c += '                    "total" => a[4],' + QUEBRA_LINHA
    c += '                    "count" => a[5],' + QUEBRA_LINHA
    c += '                    "itens" => _aItens,' + QUEBRA_LINHA
    c += '                    "dthr" => a[7]' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            )' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    hRet := {=>},' + QUEBRA_LINHA
    c += '    hRet["count"] := aRes[1],' + QUEBRA_LINHA
    c += '    hRet["dados"] := _aList,' + QUEBRA_LINHA
    c += '    hRet' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroGetIdPedidos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    aRes := ObterPedidoPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    _aItens := {},' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        AEval(' + QUEBRA_LINHA
    c += '            aRes[6],' + QUEBRA_LINHA
    c += '            {|i|' + QUEBRA_LINHA
    c += '                AAdd(' + QUEBRA_LINHA
    c += '                    _aItens,' + QUEBRA_LINHA
    c += '                    {' + QUEBRA_LINHA
    c += '                        "idprod" => i[1],' + QUEBRA_LINHA
    c += '                        "qtd" => i[2],' + QUEBRA_LINHA
    c += '                        "vlrunit" => i[3],' + QUEBRA_LINHA
    c += '                        "vlrtot" => i[4]' + QUEBRA_LINHA
    c += '                    }' + QUEBRA_LINHA
    c += '                )' + QUEBRA_LINHA
    c += '            }' + QUEBRA_LINHA
    c += '        ),' + QUEBRA_LINHA
    c += '        Nil' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "idped" => aRes[1],' + QUEBRA_LINHA
    c += '            "idcli" => aRes[2],' + QUEBRA_LINHA
    c += '            "nome_cliente" => aRes[3],' + QUEBRA_LINHA
    c += '            "total" => aRes[4],' + QUEBRA_LINHA
    c += '            "count" => aRes[5],' + QUEBRA_LINHA
    c += '            "itens" => _aItens,' + QUEBRA_LINHA
    c += '            "dthr" => aRes[7]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPostPedidos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    _aItens := {},' + QUEBRA_LINHA
    c += '    AEval(' + QUEBRA_LINHA
    c += '        _body["itens"],' + QUEBRA_LINHA
    c += '        {|i|' + QUEBRA_LINHA
    c += '            AAdd(' + QUEBRA_LINHA
    c += '                _aItens,' + QUEBRA_LINHA
    c += '                {' + QUEBRA_LINHA
    c += '                    IIf(ValType(i["idprod"]) == "N", PadL(LTrim(Str(i["idprod"])), 5, "0"), i["idprod"]),' + QUEBRA_LINHA
    c += '                    IIf(ValType(i["qtd"]) == "C", Val(i["qtd"]), i["qtd"]),' + QUEBRA_LINHA
    c += '                    IIf(ValType(i["vlrunit"]) == "C", Val(i["vlrunit"]), i["vlrunit"]),' + QUEBRA_LINHA
    c += '                    IIf(ValType(i["vlrtot"]) == "C", Val(i["vlrtot"]), i["vlrtot"])' + QUEBRA_LINHA
    c += '                }' + QUEBRA_LINHA
    c += '            )' + QUEBRA_LINHA
    c += '        }' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    cIdAux := EfetivarNovoPedido(' + QUEBRA_LINHA
    c += '        IIf(ValType(_body["idcli"]) == "N", PadL(LTrim(Str(_body["idcli"])), 5, "0"), _body["idcli"]),' + QUEBRA_LINHA
    c += '        _aItens,' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "dthr"), _body["dthr"], "")' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterPedidoPorId(cIdAux),' + QUEBRA_LINHA
    c += '    _aItensRet := {},' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        AEval(' + QUEBRA_LINHA
    c += '            aRes[6],' + QUEBRA_LINHA
    c += '            {|i|' + QUEBRA_LINHA
    c += '                AAdd(' + QUEBRA_LINHA
    c += '                    _aItensRet,' + QUEBRA_LINHA
    c += '                    {' + QUEBRA_LINHA
    c += '                        "idprod" => i[1],' + QUEBRA_LINHA
    c += '                        "qtd" => i[2],' + QUEBRA_LINHA
    c += '                        "vlrunit" => i[3],' + QUEBRA_LINHA
    c += '                        "vlrtot" => i[4]' + QUEBRA_LINHA
    c += '                    }' + QUEBRA_LINHA
    c += '                )' + QUEBRA_LINHA
    c += '            }' + QUEBRA_LINHA
    c += '        ),' + QUEBRA_LINHA
    c += '        Nil' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "idped" => aRes[1],' + QUEBRA_LINHA
    c += '            "idcli" => aRes[2],' + QUEBRA_LINHA
    c += '            "nome_cliente" => aRes[3],' + QUEBRA_LINHA
    c += '            "total" => aRes[4],' + QUEBRA_LINHA
    c += '            "count" => aRes[5],' + QUEBRA_LINHA
    c += '            "itens" => _aItensRet,' + QUEBRA_LINHA
    c += '            "dthr" => aRes[7]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroPutPedidos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    lOk := AtualizarDadosPedido(' + QUEBRA_LINHA
    c += '        _uri["id"],' + QUEBRA_LINHA
    c += '        IIf(HHasKey(_body, "dthr"), _body["dthr"], "")' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    aRes := ObterPedidoPorId(_uri["id"]),' + QUEBRA_LINHA
    c += '    _aItensRet := {},' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        AEval(' + QUEBRA_LINHA
    c += '            aRes[6],' + QUEBRA_LINHA
    c += '            {|i|' + QUEBRA_LINHA
    c += '                AAdd(' + QUEBRA_LINHA
    c += '                    _aItensRet,' + QUEBRA_LINHA
    c += '                    {' + QUEBRA_LINHA
    c += '                        "idprod" => i[1],' + QUEBRA_LINHA
    c += '                        "qtd" => i[2],' + QUEBRA_LINHA
    c += '                        "vlrunit" => i[3],' + QUEBRA_LINHA
    c += '                        "vlrtot" => i[4]' + QUEBRA_LINHA
    c += '                    }' + QUEBRA_LINHA
    c += '                )' + QUEBRA_LINHA
    c += '            }' + QUEBRA_LINHA
    c += '        ),' + QUEBRA_LINHA
    c += '        Nil' + QUEBRA_LINHA
    c += '    ),' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        lOk .And. Len(aRes) > 0,' + QUEBRA_LINHA
    c += '        {' + QUEBRA_LINHA
    c += '            "idped" => aRes[1],' + QUEBRA_LINHA
    c += '            "idcli" => aRes[2],' + QUEBRA_LINHA
    c += '            "nome_cliente" => aRes[3],' + QUEBRA_LINHA
    c += '            "total" => aRes[4],' + QUEBRA_LINHA
    c += '            "count" => aRes[5],' + QUEBRA_LINHA
    c += '            "itens" => _aItensRet,' + QUEBRA_LINHA
    c += '            "dthr" => aRes[7]' + QUEBRA_LINHA
    c += '        },' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c

Function GerarMacroDeletePedidos()
    Local c := ""
    c += '(' + QUEBRA_LINHA
    c += '    IIf(' + QUEBRA_LINHA
    c += '        RemoverPedido(_uri["id"]),' + QUEBRA_LINHA
    c += '        {=>},' + QUEBRA_LINHA
    c += '        {=>}' + QUEBRA_LINHA
    c += '    )' + QUEBRA_LINHA
    c += ')'
Return c


// =========================================================================
// 3. EXPORTAR.PRG (GERACAO DOS ARQUIVOS SWAGGER)
// =========================================================================
Procedure ExecutarExportar()
    OutStd(" [3/3] Gerando arquivos OpenAPI (Swagger)... " + QUEBRA_LINHA)
    GerarSwagger("legado", "legado.json")
    GerarSwagger("rotas", "rotas.json")
Return

Function JsonToSwaggerProps(cJson)
    Local hHash := {=>}, hProps := {=>}, aKeys := {}, cKey := "", xVal, cType, cStr

    If !Empty(cJson)
        hb_jsonDecode(cJson, @hHash)
        If ValType(hHash) == "H"
            aKeys := HGetKeys(hHash)
            For Each cKey IN aKeys
                xVal := hHash[cKey]
                cType := ValType(xVal)
                
                If cType == "N"
                    cStr := LTrim(Str(xVal))
                    If At(".", cStr) > 0
                        hProps[cKey] := {"type" => "number", "format" => "double"}
                    Else
                        hProps[cKey] := {"type" => "integer", "format" => "int32"}
                    EndIf
                ElseIf cType == "L"
                    hProps[cKey] := {"type" => "boolean"}
                ElseIf cType == "A"
                    If Len(xVal) > 0 .And. ValType(xVal[1]) == "H"
                        hProps[cKey] := {"type" => "array", "items" => {"type" => "object", "properties" => JsonToSwaggerProps(hb_jsonEncode(xVal[1]))}}
                    Else
                        hProps[cKey] := {"type" => "array", "items" => {"type" => "string"}}
                    EndIf
                ElseIf cType == "H"
                    hProps[cKey] := {"type" => "object", "properties" => JsonToSwaggerProps(hb_jsonEncode(xVal))}
                Else
                    hProps[cKey] := {"type" => "string"}
                EndIf
            Next
        EndIf
    EndIf

    If Len(hProps) == 0; hProps["_empty"] := {"type" => "string"}; EndIf
Return hProps

Procedure GerarSwagger(cTipo, cOutFile)
    Local hSwag := {=>}, hInfo := {=>}, hPaths := {=>}, hDefs := {=>}, hResp := {=>}
    Local cRota := "", cAcao := "", cVer := "", cBase := "", cPathId := "", cDefPre := ""
    Local cSchemaName := "", cParamStr := "", aPares := {}, cPar := "", nIgual := 0, cChave := ""
    Local hOpLst, hOpId, aPrmLst, aPrmId, lIsRotas := .F.

    hDefs["Erro"] := {"type" => "object", "properties" => {"type" => {"type" => "string"}, "title" => {"type" => "string"}, "status" => {"type" => "integer", "format" => "int32"}, "detail" => {"type" => "string"}, "instance" => {"type" => "string"}, "request" => {"type" => "string"}, "response" => {"type" => "string"}, "invalidparameters" => {"type" => "array", "items" => {"type" => "string"}}}}

    hInfo["title"] := "Middle - " + Upper(cTipo)
    hInfo["version"] := "1"
    hSwag["swagger"] := "2.0"; hSwag["info"] := hInfo; hSwag["host"] := "localhost:8080"
    hSwag["basePath"] := "/middle/v1"; hSwag["schemes"] := {"http"}

    If Select("ROTAS") == 0; dbUseArea(.T., Nil, "ROTAS.DBF", "ROTAS", .T., .T.); EndIf

    If Select("ROTAS") > 0
        dbSelectArea("ROTAS"); DbGoTop()
        
        // Loop 1 - Models/Definitions
        While !Eof()
            cRota := AllTrim(ROTAS->ROTA)
            lIsRotas := (Lower(cRota) == "rotas")
            If (cTipo == "rotas" .And. !lIsRotas) .Or. (cTipo == "legado" .And. lIsRotas)
                DbSkip(); Loop
            EndIf

            cAcao := Lower(AllTrim(ROTAS->ACAO))
            cDefPre := Upper(Left(cRota, 1)) + Lower(SubStr(cRota, 2))
            
            If cAcao $ "post|put" .And. !Empty(ROTAS->REQUEST)
                cSchemaName := cDefPre + "Body"
                If !HHasKey(hDefs, cSchemaName)
                    hDefs[cSchemaName] := {"type" => "object", "properties" => JsonToSwaggerProps(ROTAS->REQUEST)}
                EndIf
            EndIf
            
            If cAcao == "getid" .And. !Empty(ROTAS->RESPONSE)
                cSchemaName := cDefPre + "GetId"
                If !HHasKey(hDefs, cSchemaName)
                    hDefs[cSchemaName] := {"type" => "object", "properties" => JsonToSwaggerProps(ROTAS->RESPONSE)}
                EndIf
            EndIf
            
            If cAcao == "get" .And. !Empty(ROTAS->RESPONSE)
                cSchemaName := cDefPre + "GetList"
                If !HHasKey(hDefs, cSchemaName)
                    hDefs[cSchemaName] := {"type" => "object", "properties" => JsonToSwaggerProps(ROTAS->RESPONSE)}
                EndIf
            EndIf
            
            DbSkip()
        EndDo

        // Loop 2 - Paths
        DbGoTop()
        While !Eof()
            cRota := AllTrim(ROTAS->ROTA)
            lIsRotas := (Lower(cRota) == "rotas")
            If (cTipo == "rotas" .And. !lIsRotas) .Or. (cTipo == "legado" .And. lIsRotas)
                DbSkip(); Loop
            EndIf

            cAcao := Lower(AllTrim(ROTAS->ACAO)); cVer := Lower(AllTrim(ROTAS->VERSAO))
            cParamStr := AllTrim(ROTAS->QUERYPARAM)
            cDefPre := Upper(Left(cRota, 1)) + Lower(SubStr(cRota, 2))

            If cTipo == "legado"
                If Lower(cRota) == "listaempresas"
                    cBase := "/" + Lower(cRota) + "/" + cVer
                    cPathId := cBase + "/{id}"
                    hOpId := {=>}
                    hOpId["tags"] := {"Middle"}
                    hOpId["parameters"] := {}
                Else
                    cBase := "/empresas/{empresas}/filiais/{filiais}/" + Lower(cRota) + "/" + cVer
                    cPathId := cBase + "/{id}"
                    hOpId := {=>}
                    hOpId["tags"] := {"Middle"}
                    hOpId["parameters"] := {{"name" => "empresas", "in" => "path", "required" => .T., "type" => "string"}, {"name" => "filiais", "in" => "path", "required" => .T., "type" => "string"}}
                EndIf
            Else
                cBase := "/" + Lower(cRota) + "/" + cVer
                cPathId := cBase + "/{id}"
                hOpId := {=>}
                hOpId["tags"] := {"Middle"}
                hOpId["parameters"] := {}
            EndIf

            If !HHasKey(hPaths, cBase); hPaths[cBase] := {=>}; EndIf
            If !HHasKey(hPaths, cPathId); hPaths[cPathId] := {=>}; EndIf
            
            If !Empty(cParamStr)
                aPares := hb_ATokens(cParamStr, "&")
                For Each cPar IN aPares
                    nIgual := At("=", cPar)
                    If nIgual > 0
                        cChave := SubStr(cPar, 1, nIgual - 1)
                    Else
                        cChave := cPar
                    EndIf
                    If !Empty(cChave)
                        AAdd(hOpId["parameters"], {"name" => cChave, "in" => "query", "type" => "string"})
                    EndIf
                Next
            EndIf

            If cAcao == "get"
                hOpId["operationId"] := "Get" + cDefPre + "List"
                If HHasKey(hDefs, cDefPre + "GetList")
                    hOpId["responses"] := {"200" => {"description" => "Ok", "schema" => {"$ref" => "#/definitions/" + cDefPre + "GetList"}}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                Else
                    hOpId["responses"] := {"200" => {"description" => "Ok"}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                EndIf
                hPaths[cBase]["get"] := hOpId
            ElseIf cAcao == "getid"
                hOpId["operationId"] := "Get" + cDefPre + "ById"
                AAdd(hOpId["parameters"], {"name" => "id", "in" => "path", "required" => .T., "type" => "string"})
                If HHasKey(hDefs, cDefPre + "GetId")
                    hOpId["responses"] := {"200" => {"description" => "Ok", "schema" => {"$ref" => "#/definitions/" + cDefPre + "GetId"}}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                Else
                    hOpId["responses"] := {"200" => {"description" => "Ok"}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                EndIf
                hPaths[cPathId]["get"] := hOpId
            ElseIf cAcao == "post"
                hOpId["operationId"] := "Post" + cDefPre
                If HHasKey(hDefs, cDefPre + "Body")
                    AAdd(hOpId["parameters"], {"name" => "Request", "in" => "body", "required" => .T., "schema" => {"$ref" => "#/definitions/" + cDefPre + "Body"}})
                EndIf
                If HHasKey(hDefs, cDefPre + "GetId")
                    hOpId["responses"] := {"201" => {"description" => "Created", "schema" => {"$ref" => "#/definitions/" + cDefPre + "GetId"}}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                Else
                    hOpId["responses"] := {"201" => {"description" => "Created"}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                EndIf
                hPaths[cBase]["post"] := hOpId
            ElseIf cAcao == "put"
                hOpId["operationId"] := "Put" + cDefPre
                AAdd(hOpId["parameters"], {"name" => "id", "in" => "path", "required" => .T., "type" => "string"})
                If HHasKey(hDefs, cDefPre + "Body")
                    AAdd(hOpId["parameters"], {"name" => "Request", "in" => "body", "required" => .T., "schema" => {"$ref" => "#/definitions/" + cDefPre + "Body"}})
                EndIf
                If HHasKey(hDefs, cDefPre + "GetId")
                    hOpId["responses"] := {"200" => {"description" => "Updated", "schema" => {"$ref" => "#/definitions/" + cDefPre + "GetId"}}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                Else
                    hOpId["responses"] := {"200" => {"description" => "Updated"}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                EndIf
                hPaths[cPathId]["put"] := hOpId
            ElseIf cAcao == "delete"
                hOpId["operationId"] := "Delete" + cDefPre
                AAdd(hOpId["parameters"], {"name" => "id", "in" => "path", "required" => .T., "type" => "string"})
                hOpId["responses"] := {"204" => {"description" => "Deleted"}, "400" => {"description" => "Bad Request", "schema" => {"$ref" => "#/definitions/Erro"}}}
                hPaths[cPathId]["delete"] := hOpId
            EndIf
            DbSkip()
        EndDo
    EndIf

    hSwag["definitions"] := hDefs; hSwag["paths"] := hPaths; hSwag["tags"] := {{"name" => "Middle"}}
    If File(cOutFile); FErase(cOutFile); EndIf
    hb_MemoWrit(cOutFile, hb_jsonEncode(hSwag))
    OutStd("   -> " + cOutFile + " gravado com sucesso!" + QUEBRA_LINHA)
Return