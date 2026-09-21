Request HB_GT_WIN_DEFAULT
#define TECLA_ESC 27

MEMVAR cEmpresa, cFilial, cErroGlobal, cCapturaErroGlobal, GetList
FIELD NOME, DTNASC, EMAIL, PRECO, FANTASIA, RAZAOSOC, CNPJ

Procedure Main()
    Local nOpcao := 0
    Local cEmpLogin := Space(2)
    Local cFilLogin := Space(2)

    Cls
    @ 2, 10 Say "ACESSO AO SISTEMA"
    @ 4, 10 Say "Empresa (2):" Get cEmpLogin Pict "@!"
    @ 5, 10 Say "Filial (2): " Get cFilLogin Pict "@!"
    Read

    ConfigurarAmbienteDeDados(AllTrim(cEmpLogin), AllTrim(cFilLogin))

    While .T.
        Cls
        @ 2, 10 Say "SISTEMA INTEGRADO DE GESTAO"
        @ 5, 10 Say "1. Modulo de Clientes"
        @ 6, 10 Say "2. Modulo de Produtos"
        @ 7, 10 Say "3. Modulo de Empresas"
        @ 8, 10 Say "4. Modulo de Pedidos"
        @ 9, 10 Say "5. Sair"
        @ 11, 10 Say "Opcao:" Get nOpcao Pict "9" Valid nOpcao >= 1 .And. nOpcao <= 5
        Read

        If nOpcao == 1; MenuClientes(); ElseIf nOpcao == 2; MenuProdutos(); ElseIf nOpcao == 3; MenuEmpresas(); ElseIf nOpcao == 4; MenuPedidos(); ElseIf nOpcao == 5; Exit; EndIf
    EndDo

    FinalizarAmbienteDeDados()
Return

Procedure MenuClientes()
    Local nOpcaoSub := 0
    While .T.
        Cls
        @ 2, 10 Say "MODULO DE CLIENTES"
        @ 5, 10 Say "1. Incluir Novo Cliente"
        @ 6, 10 Say "2. Alterar Cliente"
        @ 7, 10 Say "3. Listar Clientes"
        @ 8, 10 Say "4. Voltar"
        @ 10, 10 Say "Opcao:" Get nOpcaoSub Pict "9" Valid nOpcaoSub >= 1 .And. nOpcaoSub <= 4
        Read
        If nOpcaoSub == 1; CadastroCliente(); ElseIf nOpcaoSub == 2; EdicaoCliente(); ElseIf nOpcaoSub == 3; ListaClientes(); ElseIf nOpcaoSub == 4; Exit; EndIf
    EndDo
Return

Procedure CadastroCliente()
    Local cNome := Space(50), dDt := CToD(""), cEmail := Space(50)
    Cls
    @ 4, 10 Say "INCLUSAO DE CLIENTE (ID AUTO)"
    @ 5, 10 Say "Nome:       " Get cNome Pict "@!"
    @ 6, 10 Say "Nasc:       " Get dDt
    @ 7, 10 Say "Email:      " Get cEmail
    Read
    If LastKey() != TECLA_ESC
        If Empty(RegistrarNovoCliente(AllTrim(cNome), dDt, AllTrim(cEmail))); @ 9, 10 Say "-> " + cErroGlobal
        Else; @ 9, 10 Say "-> Cliente Gravado com Sucesso!"; EndIf
        Inkey(2)
    EndIf
Return

Procedure EdicaoCliente()
    Local cIdBusca := Space(5), cNome := Space(50), dDt := CToD(""), cEmail := Space(50), aItem := {}
    Cls
    @ 4, 10 Say "ID Busca:   " Get cIdBusca Pict "@!"
    Read
    If LastKey() != TECLA_ESC
        aItem := ObterClientePorId(AllTrim(cIdBusca))
        If Len(aItem) > 0
            cNome := PadR(aItem[2], 50)
            dDt := CToD(aItem[3])
            cEmail := PadR(aItem[4], 50)
            
            @ 6, 10 Say "Novo Nome:  " Get cNome Pict "@!"
            @ 7, 10 Say "Nova Data:  " Get dDt
            @ 8, 10 Say "Novo Email: " Get cEmail
            Read
            
            If LastKey() != TECLA_ESC
                If !AtualizarDadosCliente(AllTrim(cIdBusca), AllTrim(cNome), dDt, AllTrim(cEmail))
                    @ 10, 10 Say "-> " + cErroGlobal; Inkey(2)
                EndIf
            EndIf
        Else
            @ 6, 10 Say "-> Cliente nao encontrado!"; Inkey(2)
        EndIf
    EndIf
Return

Procedure ListaClientes()
    Local nOrd := 1, cDir := Space(4), nStart := 0, nLim := 10, cFiltro := Space(20)
    Local aBusca := {}, aList := {}, nTotal := 0, nLinha := 10, i := 1
    Cls
    @ 2, 2 Say "Indice (1=ID, 2=Nome):" Get nOrd Pict "9"
    @ 3, 2 Say "Ordem (ASC/DESC):     " Get cDir Pict "@!"
    @ 4, 2 Say "Início Pular (Offset):" Get nStart Pict "9999"
    @ 5, 2 Say "Maximo Registros:     " Get nLim Pict "9999"
    @ 6, 2 Say "Filtro Nome:          " Get cFiltro Pict "@!"
    Read
    If LastKey() == TECLA_ESC; Return; EndIf
    
    aBusca := ObterListaClientes(nOrd, AllTrim(cDir), nStart, nLim, AllTrim(cFiltro))
    nTotal := aBusca[1]; aList := aBusca[2]
    
    @ 7, 2 Say "Total Filtrado: " + LTrim(Str(nTotal))
    @ 8, 2 Say "ID    NOME                                               DATA"
    
    If Empty(aList); @ 10, 2 Say "Vazio."; Else
        For i := 1 To Len(aList)
            @ nLinha, 2 Say aList[i][1] + " " + Left(aList[i][2], 50) + " " + aList[i][3]
            nLinha++
        Next
    EndIf
    Inkey(0)
Return

Procedure MenuProdutos()
    Local nOpcaoSub := 0
    While .T.
        Cls
        @ 2, 10 Say "MODULO DE PRODUTOS"
        @ 5, 10 Say "1. Incluir Novo Produto"
        @ 6, 10 Say "2. Alterar Produto"
        @ 7, 10 Say "3. Listar Produtos"
        @ 8, 10 Say "4. Voltar"
        @ 10, 10 Say "Opcao:" Get nOpcaoSub Pict "9" Valid nOpcaoSub >= 1 .And. nOpcaoSub <= 4
        Read
        If nOpcaoSub == 1; CadastroProduto(); ElseIf nOpcaoSub == 2; EdicaoProduto(); ElseIf nOpcaoSub == 3; ListaProdutos(); ElseIf nOpcaoSub == 4; Exit; EndIf
    EndDo
Return

Procedure CadastroProduto()
    Local cNome := Space(50), nPreco := 0
    Cls
    @ 4, 10 Say "INCLUSAO DE PRODUTO (ID AUTO)"
    @ 5, 10 Say "Nome:       " Get cNome Pict "@!"
    @ 6, 10 Say "Preco:      " Get nPreco Pict "9999.99"
    Read
    If LastKey() != TECLA_ESC
        If Empty(RegistrarNovoProduto(AllTrim(cNome), nPreco)); @ 8, 10 Say "-> " + cErroGlobal
        Else; @ 8, 10 Say "-> Gravado com Sucesso!"; EndIf
        Inkey(2)
    EndIf
Return

Procedure EdicaoProduto()
    Local cIdBusca := Space(5), cNome := Space(50), nPreco := 0, aItem := {}
    Cls
    @ 4, 10 Say "ID Busca:   " Get cIdBusca Pict "@!"
    Read
    If LastKey() != TECLA_ESC
        aItem := ObterProdutoPorId(AllTrim(cIdBusca))
        If Len(aItem) > 0
            cNome := PadR(aItem[2], 50)
            nPreco := aItem[3]
            
            @ 6, 10 Say "Novo Nome:  " Get cNome Pict "@!"
            @ 7, 10 Say "Novo Preco: " Get nPreco Pict "9999.99"
            Read
            
            If LastKey() != TECLA_ESC
                If !AtualizarDadosProduto(AllTrim(cIdBusca), AllTrim(cNome), nPreco)
                    @ 9, 10 Say "-> " + cErroGlobal; Inkey(2)
                EndIf
            EndIf
        Else
            @ 6, 10 Say "-> Produto nao encontrado!"; Inkey(2)
        EndIf
    EndIf
Return

Procedure ListaProdutos()
    Local nOrd := 1, cDir := Space(4), nStart := 0, nLim := 10, cFiltro := Space(20)
    Local aBusca := {}, aList := {}, nTotal := 0, nLinha := 10, i := 1
    Cls
    @ 2, 2 Say "Indice (1=ID, 2=Nome):" Get nOrd Pict "9"
    @ 3, 2 Say "Ordem (ASC/DESC):     " Get cDir Pict "@!"
    @ 4, 2 Say "Início Pular (Offset):" Get nStart Pict "9999"
    @ 5, 2 Say "Maximo Registros:     " Get nLim Pict "9999"
    @ 6, 2 Say "Filtro Nome:          " Get cFiltro Pict "@!"
    Read
    If LastKey() == TECLA_ESC; Return; EndIf
    
    aBusca := ObterListaProdutos(nOrd, AllTrim(cDir), nStart, nLim, AllTrim(cFiltro))
    nTotal := aBusca[1]; aList := aBusca[2]
    
    @ 7, 2 Say "Total Filtrado: " + LTrim(Str(nTotal))
    @ 8, 2 Say "ID    NOME                                               PRECO"
    
    If Empty(aList); @ 10, 2 Say "Vazio."; Else
        For i := 1 To Len(aList)
            @ nLinha, 2 Say aList[i][1] + " " + Left(aList[i][2], 50) + " " + Transform(aList[i][3], "9999.99")
            nLinha++
        Next
    EndIf
    Inkey(0)
Return

Procedure MenuEmpresas()
    Local nOpcaoSub := 0
    While .T.
        Cls
        @ 2, 10 Say "MODULO DE EMPRESAS"
        @ 5, 10 Say "1. Incluir Nova Empresa"
        @ 6, 10 Say "2. Alterar Empresa"
        @ 7, 10 Say "3. Listar Empresas"
        @ 8, 10 Say "4. Voltar"
        @ 10, 10 Say "Opcao:" Get nOpcaoSub Pict "9" Valid nOpcaoSub >= 1 .And. nOpcaoSub <= 4
        Read
        If nOpcaoSub == 1; CadastroEmpresa(); ElseIf nOpcaoSub == 2; EdicaoEmpresa(); ElseIf nOpcaoSub == 3; ListaEmpresas(); ElseIf nOpcaoSub == 4; Exit; EndIf
    EndDo
Return

Procedure CadastroEmpresa()
    Local cFan := Space(100), cRaz := Space(100), cCnpj := Space(14)
    Cls
    @ 4, 10 Say "INCLUSAO DE EMPRESA (ID AUTO)"
    @ 5, 10 Say "Fantasia:   " Get cFan Pict "@!"
    @ 6, 10 Say "Razao Soc:  " Get cRaz Pict "@!"
    @ 7, 10 Say "CNPJ:       " Get cCnpj Pict "@!"
    Read
    If LastKey() != TECLA_ESC
        If Empty(RegistrarNovaEmpresa(AllTrim(cFan), AllTrim(cRaz), AllTrim(cCnpj)))
            @ 9, 10 Say "-> " + cErroGlobal
        Else; @ 9, 10 Say "-> Gravado com Sucesso!"; EndIf
        Inkey(2)
    EndIf
Return

Procedure EdicaoEmpresa()
    Local cIdBusca := Space(5), cFan := Space(100), cRaz := Space(100), cCnpj := Space(14), aItem := {}
    Cls
    @ 4, 10 Say "ID Busca:   " Get cIdBusca Pict "@!"
    Read
    If LastKey() != TECLA_ESC
        aItem := ObterEmpresaPorId(AllTrim(cIdBusca))
        If Len(aItem) > 0
            cFan := PadR(aItem[2], 100)
            cRaz := PadR(aItem[3], 100)
            cCnpj := PadR(aItem[4], 14)
            
            @ 6, 10 Say "Fantasia:   " Get cFan Pict "@!"
            @ 7, 10 Say "Razao Soc:  " Get cRaz Pict "@!"
            @ 8, 10 Say "CNPJ:       " Get cCnpj Pict "@!"
            Read
            
            If LastKey() != TECLA_ESC
                If !AtualizarDadosEmpresa(AllTrim(cIdBusca), AllTrim(cFan), AllTrim(cRaz), AllTrim(cCnpj))
                    @ 10, 10 Say "-> " + cErroGlobal; Inkey(2)
                EndIf
            EndIf
        Else
            @ 6, 10 Say "-> Empresa nao encontrada!"; Inkey(2)
        EndIf
    EndIf
Return

Procedure ListaEmpresas()
    Local nOrd := 1, cDir := Space(4), nStart := 0, nLim := 10, cFiltro := Space(20)
    Local aBusca := {}, aList := {}, nTotal := 0, nLinha := 10, i := 1
    Cls
    @ 2, 2 Say "Indice (1=ID, 2=Nome):" Get nOrd Pict "9"
    @ 3, 2 Say "Ordem (ASC/DESC):     " Get cDir Pict "@!"
    @ 4, 2 Say "Início Pular (Offset):" Get nStart Pict "9999"
    @ 5, 2 Say "Maximo Registros:     " Get nLim Pict "9999"
    @ 6, 2 Say "Filtro Nome:          " Get cFiltro Pict "@!"
    Read
    If LastKey() == TECLA_ESC; Return; EndIf
    
    aBusca := ObterListaEmpresas(nOrd, AllTrim(cDir), nStart, nLim, AllTrim(cFiltro))
    nTotal := aBusca[1]; aList := aBusca[2]
    
    @ 7, 2 Say "Total Filtrado: " + LTrim(Str(nTotal))
    @ 8, 2 Say "ID    FANTASIA                                 CNPJ"
    
    If Empty(aList); @ 10, 2 Say "Vazio."; Else
        For i := 1 To Len(aList)
            @ nLinha, 2 Say aList[i][1] + "  " + Left(aList[i][2], 40) + " " + aList[i][4]
            nLinha++
        Next
    EndIf
    Inkey(0)
Return

Procedure MenuPedidos()
    Local nOpcaoSub := 0
    While .T.
        Cls
        @ 2, 10 Say "MODULO DE PEDIDOS"
        @ 4, 10 Say "1. Incluir Novo Pedido"
        @ 5, 10 Say "2. Listar Pedidos"
        @ 6, 10 Say "3. Editar Data/Hora do Pedido"
        @ 7, 10 Say "4. Voltar"
        @ 9, 10 Say "Opcao:" Get nOpcaoSub Pict "9" Valid nOpcaoSub >= 1 .And. nOpcaoSub <= 4
        Read
        If nOpcaoSub == 1; CadastroPedido(); ElseIf nOpcaoSub == 2; ListaPedidos(); ElseIf nOpcaoSub == 3; EdicaoPedido(); ElseIf nOpcaoSub == 4; Exit; EndIf
    EndDo
Return

Procedure CadastroPedido()
    Local cIdCli := Space(5), aItens := {}, aBusca := {}, cTermo := "", nQtd := 0, nVal := 0
    Cls
    @ 2, 10 Say "NOVO PEDIDO (ID AUTO / DTHR AUTO)"
    @ 4, 10 Say "ID Cliente: " Get cIdCli Pict "@!"
    Read
    If LastKey() == TECLA_ESC; Return; EndIf
    
    While .T.
        cTermo := Space(50)
        @ 6, 10 Say "Buscar Prod:" Get cTermo Pict "@!"
        Read
        If Empty(cTermo) .Or. LastKey() == TECLA_ESC; Exit; EndIf
        
        aBusca := RealizarBuscaProdutoNome(cTermo)
        If Empty(aBusca[1])
            @ 7, 10 Say "Erro! Produto nao encontrado."
            Inkey(1); @ 6, 0 Clear To 7, 79
            Loop
        EndIf
        
        nQtd := 0; nVal := aBusca[2]
        @ 7, 10 Say "Encontrado: " + aBusca[3]
        @ 8, 10 Say "Qtd:" Get nQtd Pict "999.99"
        @ 9, 10 Say "Vlr:" Get nVal Pict "9999.99"
        Read
        
        AAdd(aItens, {aBusca[1], nQtd, nVal, nQtd * nVal})
        
        @ 11, 10 Say "Adicionado!"
        Inkey(1); @ 6, 0 Clear To 11, 79
    EndDo
    
    If Len(aItens) > 0
        If Empty(EfetivarNovoPedido(AllTrim(cIdCli), aItens))
            @ 13, 10 Say "-> " + cErroGlobal
        Else
            @ 13, 10 Say "-> Gravado com Sucesso!"
        EndIf
        Inkey(2)
    EndIf
Return

Procedure EdicaoPedido()
    Local cIdBusca := Space(5), cDthr := Space(16), aItem := {}
    Cls
    @ 4, 10 Say "ID Busca:   " Get cIdBusca Pict "@!"
    Read
    If LastKey() != TECLA_ESC
        aItem := ObterPedidoPorId(AllTrim(cIdBusca))
        If Len(aItem) > 0
            cDthr := PadR(aItem[7], 16)
            @ 6, 10 Say "Data/Hora:  " Get cDthr Pict "99/99/9999 99:99"
            Read
            
            If LastKey() != TECLA_ESC
                If !AtualizarDadosPedido(AllTrim(cIdBusca), cDthr)
                    @ 8, 10 Say "-> " + cErroGlobal; Inkey(2)
                Else
                    @ 8, 10 Say "-> Atualizado com Sucesso!"; Inkey(2)
                EndIf
            EndIf
        Else
            @ 6, 10 Say "-> Pedido nao encontrado!"; Inkey(2)
        EndIf
    EndIf
Return

Procedure ListaPedidos()
    Local nOrd := 1, cDir := Space(4), nStart := 0, nLim := 10, cFiltro := Space(16)
    Local aBusca := {}, aList := {}, nTotal := 0, nLinha := 10, i := 1, j := 1, aItensAux := {}
    Cls
    @ 2, 2 Say "Indice (1=ID, 2=DTHR):" Get nOrd Pict "9"
    @ 3, 2 Say "Ordem (ASC/DESC):     " Get cDir Pict "@!"
    @ 4, 2 Say "Início Pular (Offset):" Get nStart Pict "9999"
    @ 5, 2 Say "Maximo Registros:     " Get nLim Pict "9999"
    @ 6, 2 Say "Filtro Data/Hora:     " Get cFiltro Pict "@!"
    Read
    If LastKey() == TECLA_ESC; Return; EndIf
    
    aBusca := ObterListaPedidos(nOrd, AllTrim(cDir), nStart, nLim, AllTrim(cFiltro))
    nTotal := aBusca[1]; aList := aBusca[2]
    
    Cls
    @ 2, 10 Say "LISTAGEM DE PEDIDOS - Total: " + LTrim(Str(nTotal))
    nLinha := 4
    
    For i := 1 To Len(aList)
        @ nLinha, 2 Say "PED: " + aList[i][1] + " | DTHR: " + aList[i][7] + " | CLI: " + aList[i][2] + " - " + aList[i][3] + " | TOTAL: " + Str(aList[i][4])
        nLinha++
        aItensAux := aList[i][6]
        For j := 1 To Len(aItensAux)
            @ nLinha, 5 Say "-> Prod: " + aItensAux[j][1] + " | Qtd: " + Str(aItensAux[j][2])
            nLinha++
        Next
        nLinha++
    Next
    Inkey(0)
Return