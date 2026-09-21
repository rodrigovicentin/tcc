#define MODO_EXCLUSIVO .F.
#define MODO_COMPARTILHADO .T.

MEMVAR cEmpresa, cFilial, cErroGlobal, cCapturaErroGlobal
FIELD EMPRESA, FILIAL, ID, FANTASIA, RAZAOSOC, CNPJ, NOME, PRECO, DTNASC, EMAIL, IDPED, IDCLI, TOTAL, IDPROD, QTD, VLRUNIT, VLRTOT, DTHR

Procedure ConfigurarAmbienteDeDados(cEmp, cFil)
    Local aDB := {}
    Public cEmpresa := cEmp, cFilial := cFil, cErroGlobal := ""
    
    If Type("cCapturaErroGlobal") == "U"; Public cCapturaErroGlobal := ""; EndIf

    Set Date British
    Set Century On
    Set Deleted On

    If !File("EMPRESAS.DBF")
        aDB := {}
        AAdd(aDB, {"EMPRESA", "C", 2, 0}); AAdd(aDB, {"FILIAL", "C", 2, 0}); AAdd(aDB, {"ID", "C", 5, 0})
        AAdd(aDB, {"FANTASIA", "C", 100, 0}); AAdd(aDB, {"RAZAOSOC", "C", 100, 0}); AAdd(aDB, {"CNPJ", "C", 14, 0})
        DbCreate("EMPRESAS.DBF", aDB)
    EndIf
    
    If !File("EMPRESAS_ID.NTX") .Or. !File("EMPRESAS_NOME.NTX")
        dbUseArea(.T., Nil, "EMPRESAS.DBF", "EMPRESAS", .F., .F.)
        Index On ID To EMPRESAS_ID; Index On FANTASIA To EMPRESAS_NOME; DbCloseArea()
    EndIf

    If !File("PRODUTOS.DBF")
        aDB := {}
        AAdd(aDB, {"EMPRESA", "C", 2, 0}); AAdd(aDB, {"FILIAL", "C", 2, 0}); AAdd(aDB, {"ID", "C", 5, 0})
        AAdd(aDB, {"NOME", "C", 50, 0}); AAdd(aDB, {"PRECO", "N", 10, 2})
        DbCreate("PRODUTOS.DBF", aDB)
    EndIf
    
    If !File("PRODUTOS_ID.NTX") .Or. !File("PRODUTOS_NOME.NTX")
        dbUseArea(.T., Nil, "PRODUTOS.DBF", "PRODUTOS", .F., .F.)
        Index On ID To PRODUTOS_ID; Index On NOME To PRODUTOS_NOME; DbCloseArea()
    EndIf

    If !File("CLIENTES.DBF")
        aDB := {}
        AAdd(aDB, {"EMPRESA", "C", 2, 0}); AAdd(aDB, {"FILIAL", "C", 2, 0}); AAdd(aDB, {"ID", "C", 5, 0})
        AAdd(aDB, {"NOME", "C", 50, 0}); AAdd(aDB, {"DTNASC", "D", 8, 0}); AAdd(aDB, {"EMAIL", "C", 50, 0})
        DbCreate("CLIENTES.DBF", aDB)
    EndIf
    
    If !File("CLIENTES_ID.NTX") .Or. !File("CLIENTES_NOME.NTX")
        dbUseArea(.T., Nil, "CLIENTES.DBF", "CLIENTES", .F., .F.)
        Index On ID To CLIENTES_ID; Index On NOME To CLIENTES_NOME; DbCloseArea()
    EndIf

    If !File("PEDIDOS.DBF")
        aDB := {}
        AAdd(aDB, {"EMPRESA", "C", 2, 0}); AAdd(aDB, {"FILIAL", "C", 2, 0}); AAdd(aDB, {"IDPED", "C", 5, 0})
        AAdd(aDB, {"IDCLI", "C", 5, 0}); AAdd(aDB, {"TOTAL", "N", 12, 2}); AAdd(aDB, {"DTHR", "C", 16, 0})
        DbCreate("PEDIDOS.DBF", aDB)
    EndIf
    
    If !File("PEDIDOS_ID.NTX") .Or. !File("PEDIDOS_DTHR.NTX")
        dbUseArea(.T., Nil, "PEDIDOS.DBF", "PEDIDOS", .F., .F.)
        Index On IDPED To PEDIDOS_ID; Index On DTHR To PEDIDOS_DTHR; DbCloseArea()
    EndIf

    If !File("ITENS.DBF")
        aDB := {}
        AAdd(aDB, {"EMPRESA", "C", 2, 0}); AAdd(aDB, {"FILIAL", "C", 2, 0}); AAdd(aDB, {"IDPED", "C", 5, 0})
        AAdd(aDB, {"IDPROD", "C", 5, 0}); AAdd(aDB, {"QTD", "N", 10, 2}); AAdd(aDB, {"VLRUNIT", "N", 10, 2})
        AAdd(aDB, {"VLRTOT", "N", 12, 2})
        DbCreate("ITENS.DBF", aDB)
    EndIf
    
    If !File("ITENS_PEDIDO.NTX")
        dbUseArea(.T., Nil, "ITENS.DBF", "ITENS", .F., .F.)
        Index On IDPED To ITENS_PEDIDO; DbCloseArea()
    EndIf

    If Select("EMPRESAS") == 0; dbUseArea(.T., Nil, "EMPRESAS.DBF", "EMPRESAS", .T., .F.); Set Index To EMPRESAS_ID, EMPRESAS_NOME; EndIf
    If Select("PRODUTOS") == 0; dbUseArea(.T., Nil, "PRODUTOS.DBF", "PRODUTOS", .T., .F.); Set Index To PRODUTOS_ID, PRODUTOS_NOME; EndIf
    If Select("CLIENTES") == 0; dbUseArea(.T., Nil, "CLIENTES.DBF", "CLIENTES", .T., .F.); Set Index To CLIENTES_ID, CLIENTES_NOME; EndIf
    If Select("PEDIDOS") == 0; dbUseArea(.T., Nil, "PEDIDOS.DBF", "PEDIDOS", .T., .F.); Set Index To PEDIDOS_ID, PEDIDOS_DTHR; EndIf
    If Select("ITENS") == 0; dbUseArea(.T., Nil, "ITENS.DBF", "ITENS", .T., .F.); Set Index To ITENS_PEDIDO; EndIf
Return

Procedure FinalizarAmbienteDeDados()
    If Type("cEmpresa") != "U"; cEmpresa := Nil; EndIf
    If Type("cFilial") != "U"; cFilial := Nil; EndIf
    If Select("EMPRESAS") != 0; EMPRESAS->(DbCloseArea()); EndIf
    If Select("PRODUTOS") != 0; PRODUTOS->(DbCloseArea()); EndIf
    If Select("CLIENTES") != 0; CLIENTES->(DbCloseArea()); EndIf
    If Select("PEDIDOS") != 0; PEDIDOS->(DbCloseArea()); EndIf
    If Select("ITENS") != 0; ITENS->(DbCloseArea()); EndIf
Return

Function ObterProxId(cAlias, cCampo)
    Local nMax := 0, cArea := Select(), nOrdAtu
    If ValType(cCampo) == "U"; cCampo := "ID"; EndIf
    Select (cAlias)
    
    nOrdAtu := IndexOrd()
    DbSetOrder(1)
    
    DbGoBottom()
    If !Eof()
        nMax := Val(&(cCampo))
    EndIf
    
    DbSetOrder(nOrdAtu)
    Select (cArea)
Return PadL(LTrim(Str(nMax + 1)), 5, "0")

Function RegistrarNovoCliente(cNome, dNasc, cEmail)
    Local cId := ""
    If Empty(cNome)
        cCapturaErroGlobal := "Nome do cliente obrigatorio."
        cErroGlobal := cCapturaErroGlobal
        Return ""
    EndIf
    cId := ObterProxId("CLIENTES")
    Select CLIENTES
    Append Blank
    Replace EMPRESA With PadR(cEmpresa, 2), FILIAL With PadR(cFilial, 2), ;
            ID With cId, NOME With cNome, DTNASC With dNasc, EMAIL With cEmail
Return cId

Function AtualizarDadosCliente(cId, cNome, dNasc, cEmail)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If Empty(cId) .Or. Empty(cNome)
        cCapturaErroGlobal := "ID e Nome obrigatorios."
        cErroGlobal := cCapturaErroGlobal
        Return .F.
    EndIf
    Select CLIENTES
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); cErroGlobal := "Cliente nao encontrado."; Return .F.; EndIf
    
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); cErroGlobal := "Cliente fora do contexto."; Return .F.; EndIf
    
    RLock()
    Replace NOME With cNome, DTNASC With dNasc, EMAIL With cEmail
    DbUnlock()
Return .T.

Function RemoverCliente(cId)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")
    
    Select CLIENTES
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    RLock(); DbDelete(); DbUnlock()
Return .T.

Function ObterClientePorId(cId)
    Local aItem := {}, cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")
    
    Select CLIENTES
    DbSetOrder(1)
    If DbSeek(PadR(cId, 5))
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            aItem := {AllTrim(ID), AllTrim(NOME), DToC(DTNASC), AllTrim(EMAIL)}
        Else
            cCapturaErroGlobal := "Registro sem permissao de acesso neste contexto (Empresa/Filial)."
        EndIf
    Else
        cCapturaErroGlobal := "Registro nao encontrado."
    EndIf
Return aItem

Function ObterListaClientes(nOrd, cDir, nStart, nLim, cFiltro)
    Local aList := {}, nTotal := 0, nSkip := 0, nAdd := 0
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If ValType(nOrd) == "U"; nOrd := 1; EndIf
    If ValType(cDir) == "U"; cDir := "ASC"; EndIf
    If ValType(nStart) == "U"; nStart := 0; EndIf
    If ValType(nLim) == "U"; nLim := 10; EndIf
    If ValType(cFiltro) == "U"; cFiltro := ""; EndIf

    Select CLIENTES
    DbSetOrder(nOrd)
    If cDir == "DESC"; DbGoBottom(); Else; DbGoTop(); EndIf
    
    While IIf(cDir == "DESC", !Bof(), !Eof())
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            If Empty(cFiltro) .Or. AllTrim(Upper(cFiltro)) $ Upper(NOME)
                nTotal++
                If nSkip < nStart; nSkip++
                ElseIf nAdd < nLim
                    AAdd(aList, {AllTrim(ID), AllTrim(NOME), DToC(DTNASC), AllTrim(EMAIL)})
                    nAdd++
                EndIf
            EndIf
        EndIf
        If cDir == "DESC"; DbSkip(-1); Else; DbSkip(); EndIf
    EndDo
Return { nTotal, aList }

Function RegistrarNovaEmpresa(cFan, cRaz, cCnpj, cEmpIn, cFilIn)
    Local cId := ""
    Local cEmpGravar := IIf(ValType(cEmpIn) == "C" .And. !Empty(cEmpIn), PadR(cEmpIn, 2), IIf(Type("cEmpresa")=="C", PadR(cEmpresa,2), "  "))
    Local cFilGravar := IIf(ValType(cFilIn) == "C" .And. !Empty(cFilIn), PadR(cFilIn, 2), IIf(Type("cFilial")=="C", PadR(cFilial,2), "  "))
    
    If Empty(cFan); cErroGlobal := "Fantasia obrigatoria."; Return ""; EndIf
    cId := ObterProxId("EMPRESAS")
    Select EMPRESAS
    Append Blank
    Replace EMPRESA With cEmpGravar, FILIAL With cFilGravar, ;
            ID With cId, FANTASIA With cFan, RAZAOSOC With cRaz, CNPJ With cCnpj
Return cId

Function AtualizarDadosEmpresa(cId, cFan, cRaz, cCnpj, cEmpIn, cFilIn)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If Empty(cId) .Or. Empty(cFan); Return .F.; EndIf
    Select EMPRESAS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    
    RLock()
    Replace FANTASIA With cFan, RAZAOSOC With cRaz, CNPJ With cCnpj
    If ValType(cEmpIn) == "C" .And. !Empty(cEmpIn); Replace EMPRESA With PadR(cEmpIn, 2); EndIf
    If ValType(cFilIn) == "C" .And. !Empty(cFilIn); Replace FILIAL With PadR(cFilIn, 2); EndIf
    DbUnlock()
Return .T.

Function RemoverEmpresa(cId)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")
    
    Select EMPRESAS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    
    RLock(); DbDelete(); DbUnlock()
Return .T.

Function ObterEmpresaPorId(cId)
    Local aItem := {}, cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select EMPRESAS
    DbSetOrder(1)
    If DbSeek(PadR(cId, 5))
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            aItem := {AllTrim(ID), AllTrim(FANTASIA), AllTrim(RAZAOSOC), AllTrim(CNPJ), AllTrim(EMPRESA), AllTrim(FILIAL)}
        Else
            cCapturaErroGlobal := "Registro sem permissao de acesso neste contexto (Empresa/Filial)."
        EndIf
    Else
        cCapturaErroGlobal := "Registro nao encontrado."
    EndIf
Return aItem

Function ObterListaEmpresas(nOrd, cDir, nStart, nLim, cFiltro)
    Local aList := {}, nTotal := 0, nSkip := 0, nAdd := 0
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If ValType(nOrd) == "U"; nOrd := 1; EndIf
    If ValType(cDir) == "U"; cDir := "ASC"; EndIf
    If ValType(nStart) == "U"; nStart := 0; EndIf
    If ValType(nLim) == "U"; nLim := 10; EndIf
    If ValType(cFiltro) == "U"; cFiltro := ""; EndIf
    
    Select EMPRESAS
    DbSetOrder(nOrd)
    If cDir == "DESC"; DbGoBottom(); Else; DbGoTop(); EndIf
    
    While IIf(cDir == "DESC", !Bof(), !Eof())
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            If Empty(cFiltro) .Or. AllTrim(Upper(cFiltro)) $ Upper(FANTASIA)
                nTotal++
                If nSkip < nStart; nSkip++
                ElseIf nAdd < nLim
                    AAdd(aList, {AllTrim(ID), AllTrim(FANTASIA), AllTrim(RAZAOSOC), AllTrim(CNPJ), AllTrim(EMPRESA), AllTrim(FILIAL)})
                    nAdd++
                EndIf
            EndIf
        EndIf
        If cDir == "DESC"; DbSkip(-1); Else; DbSkip(); EndIf
    EndDo
Return { nTotal, aList }

Function RegistrarNovoProduto(cNome, nPreco)
    Local cId := ""
    If Empty(cNome); cErroGlobal := "Nome obrigatorio."; Return ""; EndIf
    cId := ObterProxId("PRODUTOS")
    Select PRODUTOS
    Append Blank
    Replace EMPRESA With PadR(cEmpresa,2), FILIAL With PadR(cFilial,2), ;
            ID With cId, NOME With cNome, PRECO With nPreco
Return cId

Function AtualizarDadosProduto(cId, cNome, nPreco)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If Empty(cId) .Or. Empty(cNome); Return .F.; EndIf
    Select PRODUTOS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    RLock()
    Replace NOME With cNome, PRECO With nPreco
    DbUnlock()
Return .T.

Function RemoverProduto(cId)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select PRODUTOS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    RLock(); DbDelete(); DbUnlock()
Return .T.

Function ObterProdutoPorId(cId)
    Local aItem := {}, cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select PRODUTOS
    DbSetOrder(1)
    If DbSeek(PadR(cId, 5))
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            aItem := {AllTrim(ID), AllTrim(NOME), PRECO}
        Else
            cCapturaErroGlobal := "Registro sem permissao de acesso neste contexto (Empresa/Filial)."
        EndIf
    Else
        cCapturaErroGlobal := "Registro nao encontrado."
    EndIf
Return aItem

Function ObterListaProdutos(nOrd, cDir, nStart, nLim, cFiltro)
    Local aList := {}, nTotal := 0, nSkip := 0, nAdd := 0
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If ValType(nOrd) == "U"; nOrd := 1; EndIf
    If ValType(cDir) == "U"; cDir := "ASC"; EndIf
    If ValType(nStart) == "U"; nStart := 0; EndIf
    If ValType(nLim) == "U"; nLim := 10; EndIf
    If ValType(cFiltro) == "U"; cFiltro := ""; EndIf
    
    Select PRODUTOS
    DbSetOrder(nOrd)
    If cDir == "DESC"; DbGoBottom(); Else; DbGoTop(); EndIf
    
    While IIf(cDir == "DESC", !Bof(), !Eof())
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            If Empty(cFiltro) .Or. AllTrim(Upper(cFiltro)) $ Upper(NOME)
                nTotal++
                If nSkip < nStart; nSkip++
                ElseIf nAdd < nLim
                    AAdd(aList, {AllTrim(ID), AllTrim(NOME), PRECO})
                    nAdd++
                EndIf
            EndIf
        EndIf
        If cDir == "DESC"; DbSkip(-1); Else; DbSkip(); EndIf
    EndDo
Return { nTotal, aList }

Function RealizarBuscaProdutoNome(cTermo)
    Local aRes := {"", 0, ""}, cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select PRODUTOS
    DbSetOrder(2)
    DbGoTop()
    While !Eof()
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            If AllTrim(Upper(cTermo)) $ Upper(NOME)
                aRes := {ID, PRECO, NOME}
                Exit
            EndIf
        EndIf
        DbSkip()
    EndDo
Return aRes

Function EfetivarNovoPedido(cIdCli, aItens, cDthr)
    Local nTot := 0, i := 1, cId := ""
    
    If Empty(cIdCli) .Or. Len(aItens) == 0; Return ""; EndIf
    If ValType(cDthr) == "U" .Or. Empty(cDthr)
        cDthr := DToC(Date()) + " " + Left(Time(), 5)
    EndIf

    For i := 1 To Len(aItens); nTot += aItens[i][4]; Next
    
    cId := ObterProxId("PEDIDOS", "IDPED")
    
    Select PEDIDOS
    Append Blank
    Replace EMPRESA With PadR(cEmpresa,2), FILIAL With PadR(cFilial,2), ;
            IDPED With cId, IDCLI With cIdCli, TOTAL With nTot, DTHR With cDthr
            
    Select ITENS
    For i := 1 To Len(aItens)
        Append Blank
        Replace EMPRESA With PadR(cEmpresa,2), FILIAL With PadR(cFilial,2), ;
                IDPED With cId, IDPROD With aItens[i][1], QTD With aItens[i][2], ;
                VLRUNIT With aItens[i][3], VLRTOT With aItens[i][4]
    Next
Return cId

Function AtualizarDadosPedido(cId, cDthr)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If Empty(cId); Return .F.; EndIf
    Select PEDIDOS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); cErroGlobal := "Pedido nao encontrado."; Return .F.; EndIf
    
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); cErroGlobal := "Pedido fora do contexto."; Return .F.; EndIf
    
    RLock()
    Replace DTHR With cDthr
    DbUnlock()
Return .T.

Function RemoverPedido(cId)
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select PEDIDOS
    DbSetOrder(1)
    If !DbSeek(PadR(cId, 5)); Return .F.; EndIf
    If !lGlobal .And. (EMPRESA != cEmp .Or. FILIAL != cFil); Return .F.; EndIf
    
    RLock(); DbDelete(); DbUnlock()
    
    Select ITENS
    DbSetOrder(1)
    If DbSeek(PadR(cId, 5))
        While !Eof() .And. IDPED == PadR(cId, 5)
            If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
                RLock(); DbDelete(); DbUnlock()
            EndIf
            DbSkip()
        EndDo
    EndIf
Return .T.

Function ObterPedidoPorId(cId)
    Local aItem := {}, aItens := {}
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local cIdCli := "", cNomeCli := "", nArea := 0
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    Select PEDIDOS
    DbSetOrder(1)
    If DbSeek(PadR(cId, 5))
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            cIdCli := AllTrim(IDCLI)
            nArea := Select()
            Select CLIENTES
            DbSetOrder(1)
            If DbSeek(PadR(cIdCli, 5))
                cNomeCli := AllTrim(NOME)
            EndIf
            Select (nArea)

            Select ITENS
            DbSetOrder(1)
            If DbSeek(PadR(cId, 5))
                While !Eof() .And. IDPED == PadR(cId, 5)
                    If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
                        AAdd(aItens, {AllTrim(IDPROD), QTD, VLRUNIT, VLRTOT})
                    EndIf
                    DbSkip()
                EndDo
            EndIf
            Select PEDIDOS
            aItem := {AllTrim(IDPED), cIdCli, cNomeCli, TOTAL, Len(aItens), aItens, AllTrim(DTHR)}
        Else
            cCapturaErroGlobal := "Registro sem permissao de acesso neste contexto (Empresa/Filial)."
        EndIf
    Else
        cCapturaErroGlobal := "Registro nao encontrado."
    EndIf
Return aItem

Function ObterListaPedidos(nOrd, cDir, nStart, nLim, cFiltro)
    Local aList := {}, nTotal := 0, nSkip := 0, nAdd := 0
    Local cIdAtu := "", cIdCli := "", cNomeCli := "", aItensAtu := {}, nArea := 0
    Local cEmp := IIf(Type("cEmpresa") == "C", PadR(cEmpresa, 2), "  ")
    Local cFil := IIf(Type("cFilial") == "C", PadR(cFilial, 2), "  ")
    Local lGlobal := (Empty(cEmp) .Or. cEmp == "00") .And. (Empty(cFil) .Or. cFil == "00")

    If ValType(nOrd) == "U"; nOrd := 1; EndIf
    If ValType(cDir) == "U"; cDir := "ASC"; EndIf
    If ValType(nStart) == "U"; nStart := 0; EndIf
    If ValType(nLim) == "U"; nLim := 10; EndIf
    If ValType(cFiltro) == "U"; cFiltro := ""; EndIf
    
    Select PEDIDOS
    DbSetOrder(nOrd)
    If cDir == "DESC"; DbGoBottom(); Else; DbGoTop(); EndIf
    
    While IIf(cDir == "DESC", !Bof(), !Eof())
        If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
            If Empty(cFiltro) .Or. AllTrim(cFiltro) $ DTHR
                nTotal++
                If nSkip < nStart; nSkip++
                ElseIf nAdd < nLim
                    cIdAtu := IDPED
                    cIdCli := AllTrim(IDCLI)
                    cNomeCli := ""
                    aItensAtu := {}
                    
                    nArea := Select()
                    Select CLIENTES
                    DbSetOrder(1)
                    If DbSeek(PadR(cIdCli, 5))
                        cNomeCli := AllTrim(NOME)
                    EndIf
                    Select (nArea)

                    Select ITENS
                    DbSetOrder(1)
                    If DbSeek(PadR(cIdAtu, 5))
                        While !Eof() .And. IDPED == cIdAtu
                            If lGlobal .Or. (EMPRESA == cEmp .And. FILIAL == cFil)
                                AAdd(aItensAtu, {AllTrim(IDPROD), QTD, VLRUNIT, VLRTOT})
                            EndIf
                            DbSkip()
                        EndDo
                    EndIf
                    
                    Select PEDIDOS
                    AAdd(aList, {AllTrim(IDPED), cIdCli, cNomeCli, TOTAL, Len(aItensAtu), aItensAtu, AllTrim(DTHR)})
                    nAdd++
                EndIf
            EndIf
        EndIf
        If cDir == "DESC"; DbSkip(-1); Else; DbSkip(); EndIf
    EndDo
Return { nTotal, aList }