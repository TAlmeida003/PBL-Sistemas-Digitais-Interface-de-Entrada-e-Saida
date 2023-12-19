@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                          Controlador do LCD 16 x 2
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Este código Assembly é um controlador para um display LCD 16 x 2. Ele utiliza macros e 
@ funções para configurar e controlar as operações básicas do LCD, como inicialização, envio
@ de comandos e dados, e exibição de strings nas linhas do display.

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                                  Constantes                                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.EQU    CMD_INICIO,             0x32
.EQU    CMD_DUAS_LINHAS,        0x28
.EQU    CMD_DESLIGAR_CURSOR,    0x0C
.EQU    CMD_LIMPAR_DISPLAY,     0x01
.EQU    CMD_CURSOR_AUT_DIR,     0x06
.EQU    CMD_LINHA_DOIS,         0xC0
.EQU    CMD_LINHA_UM,           0x80
.EQU    CMD_LIGAR_CURSOR,       0x0E
.EQU    CMD_HOME,               0x02
.EQU    CMD_DESLIGAR_DISPLAY,   0x08

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Inicializar as Saídas do LCD                          ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, iniciarSaidasLCD, é utilizado para inicializar as saídas do LCD.
@ Ele configura os pinos D4, D5, D6, D7, E (Enable), e RS (Register Select) para o modo 
@ de lógica desejado.

@ Sem Parametro
@ Sem Retorno

.macro iniciarSaidasLCD

    LDR     R0,     =pinD4      @ Carrega o endereço do pino D4 em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D4

    LDR     R0,     =pinD5      @ Carrega o endereço do pino D5 em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D5

    LDR     R0,     =pinD6      @ Carrega o endereço do pino D6 em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D6

    LDR     R0,     =pinD7      @ Carrega o endereço do pino D7 em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D7

    LDR     R0,     =E          @ Carrega o endereço do pino Enable (E) em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino Enable (E)

    LDR     R0,     =RS         @ Carrega o endereço do pino Register Select (RS) em R0
    MOV     R1,     #0          @ Configura o estado lógico do pino como baixo
    BL      stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino Register Select (RS)

    nanoSleep time1ms   @ Aguarda 1 milissegundo para garantir que as configurações sejam aplicadas corretamente

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                          Configuração inicial do LCD                             ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, configLCD, é utilizado para configurar inicialmente o LCD.
@ Ele realiza a inicialização das saídas, espera por um curto período de tempo, configura 
@ as funções do LCD e realiza algumas operações iniciais.

@ Sem Parametro
@ Sem Retorno

.macro configLCD

        iniciarSaidasLCD                                @ Inicializa as saídas do LCD

        nanoSleep time100ms                             @ Aguarda 100 milissegundos

        MOV     R2,     #3       
        BL      addValue4dataPin                       @ Envia comando de função Set ao LCD
        nanoSleep       time5ms                         @ Aguarda 5 milissegundos

        MOV     R2,     #3
        BL      addValue4dataPin                        @ Envia novamente o comando de função Set ao LCD
        nanoSleep time150us                             @ Aguarda 150 microssegundos

        MOV     R2,     #3
        BL      addValue4dataPin                        @ Envia mais uma vez o comando de função Set ao LCD
        nanoSleep time150us                             @ Aguarda 150 microssegundos

        MOV     R2,     #2
        BL      addValue4dataPin                        @ Envia o último comando de função Set ao LCD
        nanoSleep time150us                             @ Aguarda 150 microssegundos
        
        MOV     R0,     #CMD_DUAS_LINHAS                @ Envia comando para configurar a função Set do LCD
        BL      enviarData                              @ Chama a função enviarData para enviar o comando ao LCD
        
        MOV     R0,     #CMD_DESLIGAR_DISPLAY           @ Envia comando para controlar a exibição do LCD
        BL      enviarData                              @ Chama a função enviarData para enviar o comando ao LCD
        
        MOV     R0,     #CMD_LIMPAR_DISPLAY             @ Envia comando para limpar o display do LCD
        BL      enviarData                              @ Chama a função enviarData para enviar o comando ao LCD

        MOV     R0,     #CMD_CURSOR_AUT_DIR             @ Envia comando para configurar o modo de entrada do LCD
        BL      enviarData                              @ Chama a função enviarData para enviar o comando ao LCD 
        
        MOV     R0,     #CMD_DESLIGAR_CURSOR            @ Envia comando para posicionar o cursor automaticamente para a direita (0x0C)
        BL      enviarData                              @ Chama a função enviarData para enviar o comando ao LCD
        
.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                 Adicionar O Valor aos pinos de Data do LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este função, addValue4dataPin, é utilizado para enviar um valor de 4 bits para os pinos 
@ de dados do LCD.

@ Parametro: R2 - 4 bits a sem inseridos nos pinos de data do LCD
@ Sem Retorno

addValue4dataPin:

    PUSH    {R0-R2, LR}

    LDR     R0, =pinD4                      @ carrega o endereço do pink d4 em r0
    AND     R1,     R2,     #1              @ máscara para obter o bit menos significativo
    BL      stateLogicPin                   @ chamada da função para definir o estado do pino d4

    LSR     R2,     #1                      @ deslocamento dos bits uma posição à direita

    LDR     R0,     =pinD5 
    AND     R1,     R2,     #1
    BL      stateLogicPin

    LSR     R2,     #1

    LDR     R0,     =pinD6
    AND     R1,     R2,     #1
    BL      stateLogicPin

    LSR     R2,     #1

    LDR     R0,     =pinD7
    AND     R1,     R2,     #1
    BL      stateLogicPin

    BL      pulsoEnable

    POP     {R0-R2, PC}
    BX      LR


@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Sinal de pulso no pino de enable do LCD                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Sem Parametro
@ Sem Retorno

pulsoEnable:

    PUSH    {R0-R4, LR}

    LDR     R0,     =E

    MOV     R1,     #0
    BL      stateLogicPin
    nanoSleep time1ms

    MOV     R1,     #1 
    BL      stateLogicPin
    nanoSleep time1ms

    MOV     R1,     #0 
    BL      stateLogicPin
    nanoSleep time1ms

    POP     {R0-R4, PC}
    BX      LR


@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Enviar 8 bits para o LCD                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R0 - Byte a ser enviado para o LCD
@ Sem Retorno

enviarData:

    PUSH    {R0-R3, LR}

    MOV     R2,     R0
    AND     R3,     R2,     #0xF
    LSR     R2,     #4
    BL      addValue4dataPin

    MOV     R2,     R3
    BL      addValue4dataPin

    POP     {R0-R3, PC}
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                      Envia uma string terminada para o LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R0 - Ponteiro para a string
@            R1 - Tamanho da string (número de caracteres)
@ Sem Retorno

stringLine:
    PUSH    {R0-R8, LR}             @ Preserva registradores e o link register

    MOV     R5,     R0              @ R5: Ponteiro para a string
    MOV     R6,     R1              @ R6: Tamanho da string
    MOV     R7,     #0              @ R7: Contador de loop (i)

    LDR     R0,     =RS             @ Define RS como alto (modo de dados)
    MOV     R1,     #1
    BL      stateLogicPin           @ Chama a função stateLogicPin

    @ Loop para enviar caracteres
    forStringLine:
        CMP     R7,     R6           @ Compara o contador de loop com o tamanho da string
        BGE     exitForStringLine    @ Se R7 >= R6, sai do loop

        ADD     R0,     R7,     R5   @ Calcula o endereço do caractere atual na string
        LDR     R0,     [R0]         @ Carrega o caractere atual da memória para R0
        BL      enviarData           @ Envia o caractere para o LCD usando a função enviarData

        ADD     R7,     #1           @ Incrementa o contador de loop
        B       forStringLine        @ Salta de volta para o início do loop

    exitForStringLine:
        LDR     R0,     =RS          @ Define RS como baixo (modo de instrução)
        MOV     R1,     #0
        BL      stateLogicPin        @ Chama a função stateLogicPin

    POP     {R0-R8, PC}              @ Restaura registradores e retorna da sub-rotina
    BX      LR                       @ Ramo para o endereço de retorno armazenado no Link Register (LR)

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                    Imprimir string´s nas duas linhas do LCD                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R0 - Ponteiro da String da Line 1
@            R1 - Tamanho 1
@            R2 - Ponteiro da String da Line 2
@            R3 - Tamanho 2
@ Sem Retorno

printTwoLine:
    PUSH    {R0-R9, LR}

    MOV     R4,     R2 @ R4 = Ponteiro da string line 2
    MOV     R5,     R3 @ R5 = Tamanho 2

    MOV     R2,     R0 @ R2 = Ponteiro da string line 1
    MOV     R3,     R1 @ R3 = Tamanho 1

    Max1:
        CMP     R3,     R5 
        MOVGE   R0,     R3 @ if Tamanho1 >= Tamanho2: R0 = TAMNAHO 1

        CMP     R3,     R5
        MOVLT   R0,     R5 @ if Tamanho1 < Tamanho2: R0 = TAMNAHO 2
        @ R0 = max(tamString, tamString2)

    ifPrintTwoLine:
        CMP     R0,     #17
        BGE     elsePrintTwoLine @ tamanho Max < 17

        MOV     R0,     #CMD_LINHA_UM
        BL      enviarData @ Colocar na LINHA 1

        MOV     R0,     R2
        MOV     R1,     R3
        BL      stringLine

        MOV     R0,     #CMD_LINHA_DOIS
        BL      enviarData @ Colocar na LINHA 2

        MOV     R0,     R4
        MOV     R1,     R5
        BL      stringLine

        B       ExitWhilePrintTwoLine

    elsePrintTwoLine: 

        MOV     R7,     #0 @ cont1 = 0
        MOV     R9,     #0 @ cont2 = 0
        MOV     R6,     #0 @ int I = 0

    WhilePrintTwoLine:

        max2:
            CMP     R3,     R5 
            MOVGE   R0,     R3 @ if Tamanho1 >= Tamanho2: R0 = TAMNAHO 1

            CMP     R3,     R5
            MOVLT   R0,     R5 @ if Tamanho1 < Tamanho2: R0 = TAMNAHO 2
            @ R0 = max(tamString, tamString2)

        SUB     R0,     #15
        CMP     R6, R0
        BGE     ExitWhilePrintTwoLine        

        MOV     R1,     R10             @ R1 guarda o estado anterior do botão para chamar a função
        LDR     R0,     =button_back    @ R0 guarda o ponteiro do botão
        BL      verificarBotaoPress
        MOV     R10,    R1             @ R10 recebe o valor antigo do botão
       
        CMP     R0,     #0              @ Compara o retorno da função verificarBotaoPress
        BNE     gambiarraEHNaoFuncionar

        MOV     R1,     R11     @ R1 guarda o estado anterior do botão para chamar a função
        LDR     R0,     =button_ok    @ R0 guarda o ponteiro do botão
        BL      verificarBotaoPress
        MOV     R11,    R1             @ R10 recebe o valor antigo do botão

        CMP     R0,     #0
        BNE     gambiarraEHNaoFuncionar

        MOV R1, R12     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_next   @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R12, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #0
        BNE gambiarraEHNaoFuncionar
        @ i < tam - 15 and butoes == 1 

        MOV R0, #CMD_LINHA_UM
        BL enviarData @ Colocar na LINHA 1 lcd.Map(0,0)

        ADD R0, R2, R7 @ R0 = string + cont1

        CMP     R3,     #16 
        MOVGE   R1,     #16  @ if Tamanho1 >= 16: R0 = TAMNAHO 1

        CMP     R3,     #16
        MOVLT   R1,     R3 @ if Tamanho1 < 16: R0 = TAMNAHO 2
        @ R1 = min(tamString, 16)

        BL stringLine
        @ stringLine(string[cont1:], min(16, tamString), line1)

        MOV R0, #CMD_LINHA_DOIS
        BL enviarData           @ Colocar na LINHA 1 lcd.Map(1,0)

        ADD R0, R4, R9 @ R0 = string2 + cont1

        CMP     R5,     #16 
        MOVGE   R1,     #16  @ if Tamanho2 >= 16: R0 = TAMNAHO 1

        CMP     R5,     #16
        MOVLT   R1,     R5 @ if Tamanho2 < 16: R0 = TAMNAHO 2
        @ R1 = min(tamString, 16)

        BL stringLine
        @ stringLine(string2[cont2:], min(16, tamString2), line2)

        SUB R0, R3, #16
        CMP R7, r0
        ADDLT R7, #1 @ if cont1 < (tamString - 16) cont ++

        SUB R0, R5, #16
        CMP R9, r0
        ADDLT R9, #1 @ if cont2 < (tamString2 - 16) cont2 ++

        ADD R6, #1 @ i++
        
        MOV R0, #4000 @ 0.4 s
        BL sleepButao

        B WhilePrintTwoLine

    gambiarraEHNaoFuncionar:
            MOV     R10,     #1
            MOV     R11,     #1
            MOV     R12,     #1

    ExitWhilePrintTwoLine:
        POP {R0-R9, PC} 
        BX LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;               Pegar um valor em HEX e transformar char decimal                   ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R2 - Número à ser convertido
@ Retorno:   R3 - Digito 1
@            R4 - Digito 2 

getHexDecString:

    PUSH {R0-R2}

    mov r1, #10

    SDIV r3, R2, R1
    mul r1, r3, r1
    sub r2, r2, r1

	ADD R4, R2, #0x30 @ Digito 0
	ADD R3, R3, #0x30 @ Digito 1

    POP {r0-r2}
    BX LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                  Pegar um valor em HEX e transformar char                        ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R2 - Número à ser convertido
@ Retorno:   R3 - Digito 1
@            R4 - Digito 2

getHexInString:
    PUSH {R0-R2}

    AND R0, R2, #0x0F @ Digito 2
    LSR R2, #4        @ dIGITO 1
 
    CMP R2, #10 @ (digito1 < 10)
    ADDLT R3, R2, #0x30  @ R1 = ('0' + digito1)

    CMP R2, #10 @ (digito1 >= 10)
    ADDGE R3, R2, #0x37 @ R1 = ('A' + digito1 - 10)

    CMP R0, #10 @ (digito2 < 10)
    ADDLT r4, R0, #0x30 @ R2 = ('0' + digito2)

    CMP R0, #10 @ R2 = (digito2 >= 10)
    ADDGE r4, R0, #0x37  @ R2 = ('A' + digito2 - 10)

    POP {R0-R2}
    BX LR
    
@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-



