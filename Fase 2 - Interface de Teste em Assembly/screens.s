@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                               Controle de Tela                                   -
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Este código implementa a lógica de controle de tela para um sistema embarcado.
@ Ele utiliza diversas constantes simbólicas definidas por diretivas EQU para
@ identificar diferentes telas e estados, bem como funções para interação com botões
@ e comunicação UART.

.EQU HOME,                       0
.EQU COMMAND,                    1
.EQU ADDRESS,                    2
.EQU ESPERA_RESPOSTA,            3
.EQU RESPOSTA,                   4
.EQU COMANDO_CONTINUO,           5
.EQU ENDERECO_CONTINUO,          6
.EQU ESPERAR_RESPOSTA_CONTINUO,  7

@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                             Função Verificar Botão Press                         -
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Esta função recebe um botão escolhido (R0) e o estado anterior do botão (R1).
@ A função verifica se o botão foi pressionado desde a última verificação.
@ Se o botão foi pressionado, o estado anterior do botão é atualizado e retorna 1.
@ Caso contrário, retorna 0.

@ Parametro: R5 - Tela Atual
@            R6 - Tela de Comando
@            R7 - Tela de Endereço
@            R10 - Botão de voltar
@            R11 - Botâo de Ok
@            R12 - Botão de Proximo

TrocaDeTela:
    PUSH {lr}

    verificaBotaoBack:
        MOV R1, R10             @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_back    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R10, R1             @ R10 recebe o valor antigo do botão
        
        CMP R0, #1              @ Compara o retorno da função verificarBotaoPress
        BEQ buttonBack          @ Caso seja 1, vai para as configurações da função volta


    verificaBotaoOK:
        MOV R1, R11     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_ok    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R11, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ buttonOk


    verificarBotaoNext:
        MOV R1, R12     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_next   @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R12, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ buttonNext
        
    endTrocaDeTela:
        POP {PC}
        BX LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@ ---------------------------------------------
buttonBack:

    ifSUBComandoAtual:
        CMP R5, #COMANDO_CONTINUO
        BEQ ifIsCommand

        CMP R5, #COMMAND
        BEQ ifIsCommand
        @if (tela_atual == tela_comando or tela_atual == comandoContinuo):

        B elifButtonBackAddress

        ifIsCommand:
            CMP R6, #1
            BEQ elifButtonBackHome
            @ if (comando_atual != 1)

            SUB R6, #1 @ comando_atual -= 1
            B endTrocaDeTela

        elifButtonBackHome:
            CMP R5, #COMANDO_CONTINUO
            BEQ endTrocaDeTela
            @ tela != continuo
    
            MOV R5, #HOME @ tela_atual = tela_home
        
            MOV R0, #1
            BL enviarData

            B endTrocaDeTela

    elifButtonBackAddress:
        CMP R5, #ADDRESS
        BEQ ifIsAddress

        CMP R5, #ENDERECO_CONTINUO
        BEQ ifIsAddress
        @     elif (tela_atual == tela_endereco or tela_atual == enderecoContinuo):

        B endTrocaDeTela

        ifIsAddress:
            CMP R7, #0 
            BEQ elifButtonBackCommand
            @ if (endereco_atual != 0)

            SUB R7, #1  @ endereco_atual -= 1
            B endTrocaDeTela

        elifButtonBackCommand:
            CMP R5, #ADDRESS
            BNE elifButtonBackAddressTemperatura
            @ elif (tela_atual == tela_endereco):

            MOV R5, #COMMAND

            MOV R0, #1
            BL enviarData

            B endTrocaDeTela
    
        elifButtonBackAddressTemperatura:
            CMP R5, #ENDERECO_CONTINUO
            BNE endTrocaDeTela
            @elif (tela_atual == enderecoContinuo)

            MOV R5, #COMANDO_CONTINUO

            MOV R0, #1
            BL enviarData

            B endTrocaDeTela

@------------------------------------------------------------

buttonOk:

    ifButtonOKHome:
        CMP R5, #HOME
        BNE elifButtonOkCommand
        @ if (tela_atual == tela_home):

        MOV R5, #COMMAND   

        MOV R0, #1
        BL enviarData

        B endTrocaDeTela

    elifButtonOkCommand:   
        CMP R5, #COMMAND
        BNE elifButtonOkAddress
        @ elif (tela_atual == tela_comando):

        MOV R5, #ADDRESS
        
        MOV R0, #1
        BL enviarData
        
        B endTrocaDeTela

    elifButtonOkAddress:  
        CMP R5, #ADDRESS   @ elif (tela_atual == tela_endereço)
        BNE elifButtonOkResposta

        MOV R5, #ESPERA_RESPOSTA

        MOV R0, #1
        BL enviarData

        B endTrocaDeTela

    elifButtonOkResposta: 
        CMP R5, #RESPOSTA
        BNE elifButtonOkContinuo

        MOV R6, #1
        MOV R7, #0

        MOV R0, #1
        BL enviarData

        ifRespostaUART:
            AND R0, R4, #0xFF
            CMP R0, #0xDF
            BEQ trocarParaComandoContinuo
            CMP R0, #0x6F
            BEQ trocarParaComandoContinuo

            MOV R5, #COMMAND
            B endTrocaDeTela

            trocarParaComandoContinuo:
                        
                BL ENABLE_UART
                BL MAP_UART
                BL CONFIG_UART

                MOV R0, #1
                BL enviarData

                LDR R1, =wait_screen_l1
                ADD R0, R1, #4  @ R0 = Ponteiro da string 1
                LDR R1, [R1]    @ R1 = Tamanho da string 1

                LDR R3, =wait_screen_l2
                ADD R2, R3, #4  @ R2 = Ponteiro da string 2
                LDR R3, [R3]    @ R3 = tamanho da string 2

                BL printTwoLine

                nanoSleep time2s
                nanoSleep time100ms

                BL RX_UART
                MOV R4, R0

                BL RX_UART
                LSL R0, #8
                orr R4, R0

                mov r5, #COMANDO_CONTINUO
                MOV R6, #1
                MOV R7, #0
        
                B endTrocaDeTela

    elifButtonOkContinuo:
        CMP R5, #COMANDO_CONTINUO
        BNE elifButtonOkEnderecoTemperatura

        MOV R5, #ENDERECO_CONTINUO

        MOV R0, #1
        BL enviarData

        B endTrocaDeTela

    elifButtonOkEnderecoTemperatura:
        CMP R5, #ENDERECO_CONTINUO
        BNE endTrocaDeTela

        MOV R5, #ESPERAR_RESPOSTA_CONTINUO

        MOV R0, #1
        BL enviarData

        B endTrocaDeTela


@------------------------------------------------------------

buttonNext:

    ifComandoAtualButtonNext:
        CMP R5, #COMMAND 
        BEQ ehProximoComando

        CMP R5, #COMANDO_CONTINUO
        BEQ ehProximoComando 
        @ if (tela_atual == tela_comando or tela_atual == tela_COMANDO_CONTINUO

        B elifButtonNextAddress

        ehProximoComando:
            CMP R6, #7 @ if (comando_atual != 7)
            BEQ endTrocaDeTela
            ADD R6, #1

            B endTrocaDeTela

    elifButtonNextAddress: 
        CMP R5, #ADDRESS
        BEQ somaEndereco

        CMP R5, #ENDERECO_CONTINUO
        BEQ somaEndereco

        @ elif (tela_atual == tela_endereco or tela_atual == tela_temperatura_enderco

        B endTrocaDeTela

        somaEndereco:
            CMP R7, #0x1F
            BEQ endTrocaDeTela
            
            ADD R7, #1

            B endTrocaDeTela

@ ----------------------------------------------------------------------------

receberAsInformacoesDeContinuo: 
    PUSH {R2-R3, LR}

    MOV R2, #0                             
    MOV R3, #25    @ R3 = 25 * 0.1 = 2.5 s
                                        
    forReceberAsInformacoesDeContinuo:
        CMP R2, R3
        BGE endReceberAsInformacoesDeContinuo   @ (INT R2 = 0; R2 < 2500; R2 ++)

        CMP R5, #ESPERAR_RESPOSTA_CONTINUO
        BEQ exitReceberAsInformacoesDeContinuo

        BL CHECK_EMPTY_RX_UART
        CMP R0, #0
        BNE endReceberAsInformacoesDeContinuo

        MOV R1, R10             @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_back    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R10, R1             @ R10 recebe o valor antigo do botão
        
        CMP R0, #0              @ Compara o retorno da função verificarBotaoPress
        BNE imprimirComOBotao

        MOV R1, R11     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_ok    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R11, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #0
        BNE imprimirComOBotao

        MOV R1, R12     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_next   @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R12, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #0
        BNE imprimirComOBotao

        continucaoFor:
            ADD R2, #1                      
            nanoSleep time100ms
            B forReceberAsInformacoesDeContinuo

    imprimirComOBotao:
        MOV     R10,     #1
        MOV     R11,     #1
        MOV     R12,     #1

        BL TrocaDeTela
        BL getTela 
        B continucaoFor

    endReceberAsInformacoesDeContinuo:
        
        BL RX_UART
        MOV R4, R0

        BL RX_UART
        LSL R0, #8
        orr R4, R0

        BL ENABLE_UART
        BL MAP_UART
        BL CONFIG_UART

        MOV R0, #1
        BL enviarData

        exitReceberAsInformacoesDeContinuo:
        POP {R2-R3, pc}
        BX LR



