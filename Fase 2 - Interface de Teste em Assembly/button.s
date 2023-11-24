@ R0 = botao escolhido
@ R1 = estado anterior do botao

verificarBotaoPress: 

    PUSH {LR}
    
    BL statusInput  @ leitura do estado atual do botão

    CMP R0, #0    
    BNE returnFalse

    CMP R1, #1
    BNE returnFalse

    MOV R1, R0
    MOV R0, #0

    B exitVerificarBotaoPress


returnFalse: 

    MOV R1, R0
    MOV R0, #1

    B exitVerificarBotaoPress


exitVerificarBotaoPress:

    POP {PC}
    BX LR

