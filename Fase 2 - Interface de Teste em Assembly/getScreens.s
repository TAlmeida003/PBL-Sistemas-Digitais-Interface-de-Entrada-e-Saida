
getTela:
    PUSH {R8, LR}

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

elifComando: @ Atualmente isso é um else

    @colocar aqui para a proxima tela atual
    
    CMP R5, #COMMAND @ elif (tela_atual == COMMAND)
    BNE elifAddress

ifComandoAtual:
    CMP R6, #1
    BNE comandoAtualMenorQue7   @ elif (tela_comando == 1) 

    LDR r1, =command_screen_l1  
    ADD R0, R1, #4        @ R0 = Ponteiro da string 1

    add R8, r6, #0x30   @ R8 = "0" + comando atual      0x30 é "0" em ascii
    STRB R8, [R0, #12]   @ string1[7] = R8 só o primeiro byte do registrador

    mov R8, #0x20       @ R8 = " "
    STRB R8, [R0, #9]       @ string1[0] = R8  só o primeiro byte do registrador

    MOV R8, #0x7E       @ R8 = "->"
    STRB R8, [R0, #14]  @ string1[10] = R8 só o primeiro byte do registrador

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

    add R8, r6, #0x30     @ R8 = "0" + comando atual      0x30 é "0" em ascii
    STRB R8, [R0, #12]     @ string1[7] = R8 só o primeiro byte do registrador

    mov R8, #0x7F        @ R8 = "<-"
    STRB R8, [R0, #9]        @ string1[0] = R8  só o primeiro byte do registrador

    MOV R8, #0x7E       @ R8 = "->"
    STRB R8, [R0, #14]  @ string1[10] = R8 só o primeiro byte do registrador

    LDR r1, [r1]        @ r1 = tamnaho da string1

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela

elseComandoAtual:
    LDR r1, =command_screen_l1
    ADD R0, R1, #4

    add R8, r6, #0x30
    STRB R8, [R0, #12]

    mov R8, #0x7F
    STRB R8, [R0, #9]

    MOV R8, #0x20       @ R8 = " "
    STRB R8, [R0, #14] @ string1[10] = R8 só o primeiro byte do registrador

    LDR r1, [r1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela


@ ---- Endereço

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
    LSR R8, R7, #4      @ R8 = 0000 0010 -> deslocamento à direita

    ADD R8, R8, #0x30   @ R8 = "0" + parte mais significativa
    STRB R8, [R0, #11]   @ string1[7] = R8, o primeiro byte do registrador

    ADD R3, R3, #0x30
    STRB R3, [R0, #12]

    MOV R8, #0x20   @ espaco em branco
    STRB R8, [R0, #9]

    MOV R8, #0x7E   @ seta direita
    STRB R8, [R0, #14]

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
    @LSR R8, R7, #4      @ R8 = 0000 0010 -> deslocamento à direita

    MOV R2, R7
    BL getHexDecString

    STRB R4, [R0, #12]   @ string1[7] = R8, o primeiro byte do registrador

    STRB R3, [R0, #11]

    MOV R8, #0x7F   @ seta para esquerda
    STRB R8, [R0, #9]

    MOV R8, #0x7E   @ seta para a direita
    STRB R8, [R0, #14]

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

    STRB R4, [R0, #12]   @ string1[7] = R8, o primeiro byte do registrador

    STRB R3, [R0, #11]

    MOV R8, #0x7F   @ seta esquerda
    STRB R8, [R0, #9]

    MOV R8, #0x20
    STRB R8, [R0, #14]

    LDR R1, [R1]

    LDR r3, =screen_l2
    ADD R2, R3, #4
    LDR r3, [r3]

    B endGetTela


@ tela de espera por uma resposta
elifProcessando:
    CMP R5, #ESPERA_RESPOSTA
    BNE elseResposta

    LDR R1, =wait_screen_l1
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =wait_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2
    
    B endGetTela

@ ---- Tela de resposta
elseResposta:    

    and R0, R4, #0xff

    CMP R5, #CONTINUO_TEMPERATURA
    BEQ continuoTemperatura 

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

    @ CMP R6, #CONTINUO_UMIDADE
    @ BEQ continuoUmidade

    CMP R4, #0x00
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

    MOV R8, R4 @ guarda o codigo da resposta

    BL getHexDecString

    STRB R4, [R0, #10]
    STRB R3, [R0, #9]

    MOV R4, R8
    LDR R1, [R1]

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4
    LDR R3, [R3]

    B endGetTela

medidaTemperatura:
    LSR R2, R4, #8

    LDR R1, =temperatura_atual
    ADD R0, R1, #4

    MOV R8, #0xDF
    STRB R8, [R0, #14]

    MOV R8, R4

    BL getHexDecString

    STRB R4, [R0, #13]
    STRB R3, [R0, #12]

    MOV R4, R8
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

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

enderecoIncorreto:
    LDR R1, =endereco_incorreto
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela

continuoTemperatura:

    ifComandoAtualContinuo:
    CMP R6, #1
    BNE comandoAtualMenorQue7Continuo   @ elif (tela_comando == 1) 

    LDR r1, =command_screen_l1  
    ADD R0, R1, #4        @ R0 = Ponteiro da string 1

    add R8, r6, #0x30   @ R8 = "0" + comando atual      0x30 é "0" em ascii
    STRB R8, [R0, #12]   @ string1[7] = R8 só o primeiro byte do registrador

    mov R8, #0x20       @ R8 = " "
    STRB R8, [R0, #9]       @ string1[0] = R8  só o primeiro byte do registrador

    MOV R8, #0x7E       @ R8 = "->"
    STRB R8, [R0, #14]  @ string1[10] = R8 só o primeiro byte do registrador

    LDR r1, [r1]        @ r1 = tamnaho da string1

    @ linha 2
    LSR R2, R4, #8

    LDR R3, =temperatura_atual
    ADD R2, R3, #4
    LDR R3, [R3]

    MOV R8, #0xDF
    STRB R8, [R2, #14]

    MOV R8, R4

    BL getHexDecString

    STRB R4, [R2, #13]
    STRB R3, [R2, #12]

    MOV R4, R8
    LDR R1, [R1]

    B endGetTela

comandoAtualMenorQue7Continuo:
    CMP R6, #CONTINUO_TEMPERATURA
    BGE elseComandoAtualContinuo @ elif (tela_comando < 7) 

    LDR r1, =command_screen_l1
    ADD R0, R1, #4        @ R0 = Ponteiro da string 1

    add R8, r6, #0x30     @ R8 = "0" + comando atual      0x30 é "0" em ascii
    STRB R8, [R0, #12]     @ string1[7] = R8 só o primeiro byte do registrador

    mov R8, #0x7F        @ R8 = "<-"
    STRB R8, [R0, #9]        @ string1[0] = R8  só o primeiro byte do registrador

    MOV R8, #0x7E       @ R8 = "->"
    STRB R8, [R0, #14]  @ string1[10] = R8 só o primeiro byte do registrador

    LDR r1, [r1]        @ r1 = tamnaho da string1

    @ linha 2
    LSR R2, R4, #8

    LDR R3, =temperatura_atual
    ADD R2, R3, #4
    LDR R3, [R3]

    MOV R8, #0xDF
    STRB R8, [R2, #14]

    MOV R8, R4

    BL getHexDecString

    STRB R4, [R2, #13]
    STRB R3, [R2, #12]

    MOV R4, R8
    LDR R1, [R1]

    B endGetTela

elseComandoAtualContinuo:
    LDR r1, =command_screen_l1
    ADD R0, R1, #4

    add R8, r6, #0x30
    STRB R8, [R0, #12]

    mov R8, #0x7F
    STRB R8, [R0, #9]

    MOV R8, #0x20       @ R8 = " "
    STRB R8, [R0, #14] @ string1[10] = R8 só o primeiro byte do registrador

    LDR r1, [r1]

    @ linha 2
    LSR R2, R4, #8

    LDR R3, =temperatura_atual
    ADD R2, R3, #4
    LDR R3, [R3]

    MOV R8, #0xDF
    STRB R8, [R2, #14]

    MOV R8, R4

    BL getHexDecString

    STRB R4, [R2, #13]
    STRB R3, [R2, #12]

    MOV R4, R8
    LDR R1, [R1]

    B endGetTela


@continuoUmidade:

desconectado:
    BL RX_UART
    LDR R1, =desconectado_screen
    ADD R0, R1, #4  @ R0 = Ponteiro da string 1
    LDR R1, [R1]    @ R1 = Tamanho da string 1

    LDR R3, =resp_screen_l2
    ADD R2, R3, #4  @ R2 = Ponteiro da string 2
    LDR R3, [R3]    @ R3 = tamanho da string 2

    B endGetTela


endGetTela:
    POP {R8, PC}
    bx LR



