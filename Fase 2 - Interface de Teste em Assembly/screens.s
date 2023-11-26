.EQU HOME,            0
.EQU COMMAND,         1
.EQU ADDRESS,         2
.EQU ESPERA_RESPOSTA, 3
.EQU RESPOSTA,        4


buttonBack:
    CMP R5, #COMMAND   @ if (tela_atual == tela_comando)
    BNE elifButtonBackAddress

    CMP R6, #1  @ if (comando_atual != 1)
    BEQ elseButtonBackHome

    MOV R0, #1
    BL enviarData

    @ Voltando para tela de home
    LDR R1, =home_screen
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine

    SUB R6, #1

    B loop

elseButtonBackHome:
    MOV R5, #HOME
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

    @ Voltando para tela de comando
    LDR R1, =command_screen_l1
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine

    B loop
 

@------------------------------------------------------------

buttonOk:
    CMP R5, #HOME   @ if (tela_atual == tela_home)
    BNE elifButtonOkCommand

    MOV R5, #COMMAND   

    @ Limpar a tela
    MOV R0, #1
    BL enviarData

    @ Voltando para tela de comando
    LDR R1, =command_screen_l1
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine 

    B loop

elifButtonOkCommand:   
    CMP R5, #COMMAND    @ elif (tela_atual == tela_comando)
    BNE elifButtonOkAddress:

    MOV R5, #ADDRESS

    MOV R0, #1
    BL enviarData

    @ Voltando para tela de endereço
    LDR R1, =address_screen_l1
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine

    B loop

elifButtonOkAddress:  
    CMP R5, #ADDRESS   @ elif (tela_atual == tela_endereço)
    BNE elseButtonOkResposta

    MOV R5, #ESPERA_RESPOSTA

    MOV R0, #1
    BL enviarData

    @ Voltando para tela de comando
    LDR R1, =wait_screen_l1
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine

    B loop

else: @ quando está na tela de resposta
    MOV R5, #COMMAND

    MOV R0, #1
    BL enviarData

    @ Voltando para tela de comando
    LDR R1, =command_screen_l1
    ADD R0, R1, #4
    LDR R1, [R1]
    BL stringLine

    MOV R6, #1
    MOV R7, #0

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

