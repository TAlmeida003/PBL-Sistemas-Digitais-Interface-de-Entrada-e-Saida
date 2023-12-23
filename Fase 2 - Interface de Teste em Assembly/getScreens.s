@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                            Obtenção da Tela Atual                                -
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

@ Obtém e exibe a tela atual com base nos parâmetros passados.

@ Parametro: R5 - Tela atual
@            R6 - Comando atual
@            R7 - Endereço atual
@            R4 - Resposta atual
@ Sem Retorno

getTela:
    PUSH {R0-R9, LR}
    PUSH {R10}

ifHome:
    CMP R5, #HOME 
    BNE elifComando @ if (tela_atual == HOME):

    LDR r1, =home_screen
    ADD R0, R1, #4   @ R0 = Ponteiro da string 1
    LDR r1, [r1]     @ R1 = Tamanho da string 1

    LDR r3, =line2home 
    ADD R2, R3, #4       @ R2 = Ponteiro da string 2
    LDR r3, [r3]         @ R3 = Tamanho da string 2
    
    B endGetTela

elifComando:
    CMP R5, #COMMAND @ elif (tela_atgetTelaual == COMMAND)
    BNE elifAddress

ifComandoAtual:
    CMP R6, #1
    BNE comandoAtualMenorQue7   @ elif (tela_comando == 1) 

    LDR r1, =command_screen_l1  
    ADD R0, R1, #4        @ R0 = Ponteiro da string 1

    
    add R10, r6, #0x30   @ R10 = "0" + comando atual      0x30 é "0" em ascii
    STRB R10, [R0, #13]   @ string1[7] = R10 só o primeiro byte do registrador

    mov R10, #0x20       @ R10 = " "
    STRB R10, [R0, #10]       @ string1[0] = R10  só o primeiro byte do registrador

    MOV R10, #0x7E       @ R10 = "->"
    STRB R10, [R0, #15]  @ string1[10] = R10 só o primeiro byte do registrado

    LDR r1, [r1]        @ r1 = tamnaho da string1

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela

comandoAtualMenorQue7:
    CMP R6, #7
    BGE elseComandoAtual @ elif (tela_comando < 7) 

    LDR r1, =command_screen_l1
    ADD R0, R1, #4        @ R0 = Ponteiro da string 1

    add R10, r6, #0x30     @ R10 = "0" + comando atual      0x30 é "0" em ascii
    STRB R10, [R0, #13]     @ string1[7] = R10 só o primeiro byte do registrador

    mov R10, #0x7F        @ R10 = "<-"
    STRB R10, [R0, #10]        @ string1[0] = R10  só o primeiro byte do registrador

    MOV R10, #0x7E       @ R10 = "->"
    STRB R10, [R0, #15]  @ string1[10] = R10 só o primeiro byte do registrado

    LDR r1, [r1]        @ r1 = tamnaho da string1

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela

elseComandoAtual:
    LDR r1, =command_screen_l1
    ADD R0, R1, #4

    add R10, r6, #0x30
    STRB R10, [R0, #13]

    mov R10, #0x7F
    STRB R10, [R0, #10]

    MOV R10, #0x20       @ R10 = " "
    STRB R10, [R0, #15] @ string1[10] = R10 só o primeiro byte do registrador

    LDR r1, [r1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela


@ Endereço ------------------------------------------------------------

elifAddress:
    CMP R5, #ADDRESS
    BNE elifProcessando

ifAddressAtual:
    CMP R7, #0
    BNE elifAddressMenor31

    @ Carrega a primeira linha
    LDR R1, =address_screen_l1
    ADD R0, R1, #4  @ ponteiro da string de endereço

    @ Criação de uma máscara para obter os dois campos
    AND R3, R7, #0x0F   @ R3 = 0010 0011 e 0000 1111 -> 0011 
    LSR R10, R7, #4      @ R10 = 0000 0010 -> deslocamento à direita

    ADD R10, R10, #0x30   @ R10 = "0" + parte mais significativa
    STRB R10, [R0, #12]   @ string1[7] = R10, o primeiro byte do registrador

    ADD R3, R3, #0x30
    STRB R3, [R0, #13]

    MOV R10, #0x20   @ espaco em branco
    STRB R10, [R0, #10]

    MOV R10, #0x7E   @ seta direita
    STRB R10, [R0, #15]

    LDR R1, [R1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela

elifAddressMenor31:
    CMP R7, #31
    BGE elseAddress

    @ Carrega a primeira linha
    LDR R1, =address_screen_l1
    ADD R0, R1, #4  @ ponteiro da string de endereço

    @ Criação de uma máscara para obter os dois campos
    @AND R3, R7, #0x0F   @ R3 = 0010 0011 e 0000 1111 -> 0011 
    @LSR R10, R7, #4      @ R10 = 0000 0010 -> deslocamento à direita

    MOV R2, R7
    BL getHexDecString

    STRB R4, [R0, #13]   @ string1[7] = R10, o primeiro byte do registrador

    STRB R3, [R0, #12]
    
    MOV R10, #0x7F   @ seta para esquerda
    STRB R10, [R0, #10]

    MOV R10, #0x7E   @ seta para a direita
    STRB R10, [R0, #15]

    LDR R1, [R1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela


elseAddress:
    @ Carrega a primeira linha
    LDR R1, =address_screen_l1
    ADD R0, R1, #4  @ ponteiro da string de endereço

    @ Criação de uma máscara para obter os dois campos
    MOV R2, R7
    BL getHexDecString

    STRB R4, [R0, #13]   @ string1[7] = R10, o primeiro byte do registrador

    STRB R3, [R0, #12]

    MOV R10, #0x7F   @ seta esquerda
    STRB R10, [R0, #10]

    MOV R10, #0x20
    STRB R10, [R0, #15]

    LDR R1, [R1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela


@ tela de espera por uma resposta
elifProcessando:
    CMP R5, #ESPERA_RESPOSTA
    BEQ oad
    CMP R5, #ESPERAR_RESPOSTA_CONTINUO
    BEQ oad

    B elseResposta

    oad:
    LDR R1, =wait_screen_l1
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =wait_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2
    
    B endGetTela

@ Tela de Resposta ------------------------------------------------------------

elseResposta:    

    and R0, R4, #0xff

    CMP R5, #COMANDO_CONTINUO
    BEQ continuoTemperatura 

    CMP R5, #ENDERECO_CONTINUO
    BEQ continuoEndereco

    CMP R0, #0x1F 
    BEQ sensorProblema

    CMP R0, #0x08
    BEQ sensorNormal

    CMP R0, #0x09
    BEQ medidaUmidade

    CMP R0, #0x0A
    BEQ medidaTemperatura

    CMP R0, #0x0B
    BEQ desativaTemperatura

    CMP R0, #0x0C
    BEQ desativaUmidade

    CMP R0, #0xDF
    BEQ comandoIncorreto

    CMP R0, #0x6F
    BEQ enderecoIncorreto

    CMP R0, #0x00
    B desconectado

    B endGetTela

sensorProblema:
    LDR R1, =sensor_problema
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

sensorNormal:
    LDR R1, =sensor_normal
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

medidaUmidade:
    LSR R2, R4, #8
    
    LDR R1, =umidade_atual
    ADD R0, R1, #4

    MOV R10, R4 @ guarda o codigo da resposta

    BL getHexDecString

    STRB R4, [R0, #12]
    STRB R3, [R0, #11]

    MOV R4, R1

    LDR R1, [R1]

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4
    LDR R3, [R3]

    B endGetTela

medidaTemperatura:
    LSR R2, R4, #8

    LDR R1, =temperatura_atual
    ADD R0, R1, #4

    MOV R10, #0xDF
    STRB R10, [R0, #12] @ grau

    MOV R10, R4

    BL getHexDecString

    STRB R4, [R0, #11]
    STRB R3, [R0, #10]

    MOV R4, R1

    LDR R1, [R1]

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4
    LDR R3, [R3]

    B endGetTela

desativaTemperatura:
    LDR R1, =desativa_temperatura
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

desativaUmidade:
    LDR R1, =desativa_umidade
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

comandoIncorreto:
    LDR R1, =comando_incorreto
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    @ -- retorno do comando válido
    LSR R2, R4, #8
    AND R2, R2, #0xFF
    MOV R10, R4

    BL getHexDecString  @ retorna o R3 e R4

    LDR R9, =comando_valido
    ADD R2, R9, #4

    STRB R4, [R2, #14]
    STRB R3, [R2, #13]

    MOV R4, R10
    LDR R3, [R9]

    B endGetTela

enderecoIncorreto:
    LDR R1, =endereco_incorreto
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    @ -- retorno do endereco válido
    LSR R2, R4, #8
    AND R2, R2, #0xFF
    MOV R10, R4

    BL getHexDecString  @ retorna o R3 e R4

    LDR R9, =endereco_valido
    ADD R2, R9, #4

    STRB R4, [R2, #15]
    STRB R3, [R2, #14]

    MOV R4, R10
    LDR R3, [R9]

    B endGetTela

desconectado:
    LDR R1, =desconectado_screen
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela


@ Sensoriamento Continuo ------------------------------------------------------------

continuoTemperatura: 

    ifComandoAtualContinuo:
        CMP R6, #1
        BNE comandoAtualMenorQue7Continuo

        LDR R1, =command_screen_l1
        ADD R0, R1, #4 

        ADD R10, R6, #0x30
        STRB R10, [R0, #13]

        MOV R10, #0x20
        STRB R10, [R0, #10]

        MOV R10, #0x7E
        STRB R10, [R0, #15]

        LDR R1, [R1]

        B respostaContinuo


    comandoAtualMenorQue7Continuo:
        CMP R6, #7
        BGE elseComandoAtualContinuo @ elif (tela_comando < 7) 

        LDR r1, =command_screen_l1
        ADD R0, R1, #4        @ R0 = Ponteiro da string 1

        add R10, r6, #0x30     @ R10 = "0" + comando atual      0x30 é "0" em ascii
        STRB R10, [R0, #13]     @ string1[7] = R10 só o primeiro byte do registrador

        mov R10, #0x7F        @ R10 = "<-"
        STRB R10, [R0, #10]        @ string1[0] = R10  só o primeiro byte do registrador

        MOV R10, #0x7E       @ R10 = "->"Umidade:
        STRB R10, [R0, #15]  @ string1[10] = R10 só o primeiro byte do registrador

        LDR r1, [r1]        @ r1 = tamnaho da string1

        B respostaContinuo

    elseComandoAtualContinuo:
        LDR r1, =command_screen_l1
        ADD R0, R1, #4

        add R10, r6, #0x30
        STRB R10, [R0, #13]

        mov R10, #0x7F
        STRB R10, [R0, #10]

        MOV R10, #0x20       @ R10 = " "
        STRB R10, [R0, #15] @ string1[10] = R10 só o primeiro byte do registrador

        LDR r1, [r1]

        B respostaContinuo


continuoEndereco:

    ifAddressAtualContinuo:
        CMP R7, #0
        BNE elifAddressMenor31Continuo

        @ Carrega a primeira linha
        LDR R1, =address_screen_l1
        ADD R0, R1, #4  @ ponteiro da string de endereço

        @ Criação de uma máscara para obter os dois campos
        AND R3, R7, #0x0F   @ R3 = 0010 0011 e 0000 1111 -> 0011 
        LSR R10, R7, #4      @ R10 = 0000 0010 -> deslocamento à direita

        ADD R10, R10, #0x30   @ R10 = "0" + parte mais significativa
        STRB R10, [R0, #12]   @ string1[7] = R10, o primeiro byte do registrador

        ADD R3, R3, #0x30
        STRB R3, [R0, #13]

        MOV R10, #0x20   @ espaco em branco
        STRB R10, [R0, #10]

        MOV R10, #0x7E   @ seta direita
        STRB R10, [R0, #15]

        LDR R1, [R1]

        B respostaContinuo

    elifAddressMenor31Continuo:
        CMP R7, #31
        BGE elseAddressContinuo

        @ Carrega a primeira linha
        LDR R1, =address_screen_l1
        ADD R0, R1, #4  @ ponteiro da string de endereço

        @ Criação de uma máscara para obter os dois campos
        @AND R3, R7, #0x0F   @ R3 = 0010 0011 e 0000 1111 -> 0011 
        @LSR R10, R7, #4      @ R10 = 0000 0010 -> deslocamento à direita

        MOV R10, R4

        MOV R2, R7
        BL getHexDecString

        STRB R4, [R0, #13]   @ string1[7] = R10, o primeiro byte do registrador

        MOV R4, R10

        STRB R3, [R0, #12]
        
        MOV R10, #0x7F   @ seta para esquerda
        STRB R10, [R0, #10]

        MOV R10, #0x7E   @ seta para a direita
        STRB R10, [R0, #15]

        LDR R1, [R1]

        B respostaContinuo

    elseAddressContinuo:
        @ Carrega a primeira linha
        LDR R1, =address_screen_l1
        ADD R0, R1, #4  @ ponteiro da string de endereço

        MOV R10, R4

        @ Criação de uma máscara para obter os dois campos
        MOV R2, R7
        BL getHexDecString

        STRB R4, [R0, #13]   @ string1[7] = R10, o primeiro byte do registrador

        MOV R4, R10

        STRB R3, [R0, #12]

        MOV R10, #0x7F   @ seta esquerda
        STRB R10, [R0, #10]

        MOV R10, #0x20
        STRB R10, [R0, #15]

        LDR R1, [R1]

        B respostaContinuo


respostaContinuo:
    AND R10, R4, #0xFF

    CMP R10, #0x1F 
    BEQ sensorProblemaContinuo

    CMP R10, #0x0A
    BEQ medidaTemperaturaContinuo

    CMP R10, #0x09
    BEQ medidaUmidadeContinuo

    CMP R10, #0x00
    B desconectadoContinuo

    B endGetTela

    medidaTemperaturaContinuo:
        LSR R2, R4, #8
        MOV R10, R4

        BL getHexDecString @ retorna R3 e R4

        LDR R9, =temperatura_atual
        
        ADD R2, R9, #4

        STRB R4, [R2, #11]
        STRB R3, [R2, #10]

        MOV R4, R10
        LDR R3, [R9]

        MOV R10, #0xDF
        STRB R10, [R2, #12]

        B endGetTela

    medidaUmidadeContinuo:
        LSR R2, R4, #8
        MOV R10, R4

        BL getHexDecString

        LDR R9, =umidade_atual
        ADD R2, R9, #4

        STRB R4, [R2, #12]
        STRB R3, [R2, #11]

        MOV R4, R10
        LDR R3, [R9]

        B endGetTela

    sensorProblemaContinuo:
        LDR R3, =sensor_problema
        ADD R2, R3, #4  @ R2 = Ponteiro da string 2
        LDR R3, [R3]    @ R3 = tamanho da string 2
        B endGetTela

    desconectadoContinuo:
        LDR R3, =sem_resposta
        ADD R2, R3, #4  @ R2 = Ponteiro da string 2
        LDR R3, [R3]    @ R3 = tamanho da string 2
        B endGetTela

@ ------------------------------------------------------------

endGetTela:
    POP {R10}
    BL printTwoLine
    POP {R0-R9, PC}
    bx LR







