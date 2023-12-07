.EQU HOME,                       0
.EQU COMMAND,                    1
.EQU ADDRESS,                    2
.EQU ESPERA_RESPOSTA,            3
.EQU RESPOSTA,                   4
.EQU CONTINUO_TEMPERATURA,           5
.EQU CONTINUO_UMIDADE,  6

buttonBack:
    CMP R5, #CONTINUO_TEMPERATURA
    BEQ elseIsCommand

    CMP R5, #COMMAND   @ if (tela_atual == tela_comando || continuo)
    BEQ elseIsCommand

    B elifButtonBackAddress

    CMP R6, #1  @ if (comando_atual != 1)
    BEQ elseButtonBackHome

elseIsCommand:
    SUB R6, #1
    B loop

elseButtonBackHome: @ tela != continuo
    CMP R5, #CONTINUO_TEMPERATURA
    BEQ loop
    
    MOV R5, #HOME

    MOV R0, #1
    BL enviarData

    B loop

elifButtonBackAddress:    @ elif (tela_atual == tela_endereço)
    CMP R5, #ADDRESS
    BNE loop

    CMP R7, #0  @ if (endereco_atual != 0)
    BEQ elseButtonBackCommand

    SUB R7, #1

    B loop

elseButtonBackCommand:
    MOV R5, #COMMAND

    MOV R0, #1
    BL enviarData

    B loop
 

@------------------------------------------------------------

buttonOk:
    CMP R5, #HOME   @ if (tela_atual == tela_home)
    BNE elifButtonOkCommand

    MOV R5, #COMMAND   

    MOV R0, #1
    BL enviarData

    B loop

elifButtonOkCommand:   
    CMP R5, #COMMAND    @ elif (tela_atual == tela_comando)
    BNE elifButtonOkAddress

    MOV R5, #ADDRESS

    MOV R0, #1
    BL enviarData

    B loop

elifButtonOkAddress:  
    CMP R5, #ADDRESS   @ elif (tela_atual == tela_endereço)
    BNE elseButtonOkResposta
    MOV R5, #ESPERA_RESPOSTA

    MOV R0, #1
    BL enviarData

    B loop

   
elifButtonOkComandoContinuo:
    CMP R5, #CONTINUO_TEMPERATURA
    BNE elifButtonOkEnderecoContinuo
    MOV R5, #CONTINUO_UMIDADE
    B loop

elifButtonOkEnderecoContinuo:
    CMP R5, #CONTINUO_UMIDADE
    BNE elseButtonOkResposta
    MOV R5, #RESPOSTA
    B loop

elseButtonOkResposta: @ quando está na tela de resposta
@if resposta == 0xdf || resposta == 0x6f:
    @tela_atual = continuo_comando

    MOV R0, #1
    BL enviarData
    
    CMP R4, #0xDF
    BEQ movtelaContinuo

    CMP R4, #0x6F
    BEQ movtelaContinuo

    CMP R5, #CONTINUO_TEMPERATURA
    BEQ loop

    MOV R5, #COMMAND

    MOV R0, #1
    BL enviarData

    MOV R6, #1
    MOV R7, #0

    B loop

movtelaContinuo:
    mov r5, #CONTINUO_TEMPERATURA
    B loop

@------------------------------------------------------------

buttonNext:
    CMP R5, #COMMAND   @ if (tela_atual == tela_comando)
    BNE elifButtonNextAddress

    CMP R6, #7 @ if (comando_atual != 7)
    BEQ loop

    ADD R6, #1

    B loop

elifButtonNextAddress: 
    CMP R5, #ADDRESS
    BNE loop

    CMP R7, #0X1F
    BEQ loop

    ADD R7, #1

    B loop




