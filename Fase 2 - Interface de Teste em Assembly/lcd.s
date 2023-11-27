@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                          Controlador do LCD 16 x 2
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

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

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Inicializar as Saídas do LCD                          ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, iniciarSaidasLCD, é utilizado para inicializar as saídas do LCD.
@ Ele configura os pinos D4, D5, D6, D7, E (Enable), e RS (Register Select) para o modo de lógica desejado.

.macro iniciarSaidasLCD

    LDR R0, =pinD4      @ Carrega o endereço do pino D4 em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D4

    LDR R0, =pinD5      @ Carrega o endereço do pino D5 em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D5

    LDR R0, =pinD6      @ Carrega o endereço do pino D6 em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D6

    LDR R0, =pinD7      @ Carrega o endereço do pino D7 em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino D7

    LDR R0, =E          @ Carrega o endereço do pino Enable (E) em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino Enable (E)

    LDR R0, =RS         @ Carrega o endereço do pino Register Select (RS) em R0
    MOV R1, #0          @ Configura o estado lógico do pino como baixo
    BL stateLogicPin    @ Chama a função stateLogicPin para definir o estado do pino Register Select (RS)

    nanoSleep time1ms   @ Aguarda 1 milissegundo para garantir que as configurações sejam aplicadas corretamente

.endm

@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                          Configuração inicial do LCD                             ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, configLCD, é utilizado para configurar inicialmente o LCD.
@ Ele realiza a inicialização das saídas, espera por um curto período de tempo, configura as funções do LCD
@ e realiza algumas operações iniciais.

.macro configLCD

        iniciarSaidasLCD        @ Inicializa as saídas do LCD

        nanoSleep time100ms     @ Aguarda 100 milissegundos

        MOV     R2,     #3       
        BL addValue4dataPin        @ Envia comando de função Set ao LCD
        nanoSleep       time5ms  @ Aguarda 5 milissegundos

        MOV     R2,     #3
        BL addValue4dataPin        @ Envia novamente o comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos

        MOV     R2,     #3
        BL addValue4dataPin        @ Envia mais uma vez o comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos

        MOV     R2,     #2
        BL addValue4dataPin        @ Envia o último comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos
        
        MOV R0, #0x28            @ Envia comando para configurar a função Set do LCD
        BL enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
        MOV R0, #0x08            @ Envia comando para controlar a exibição do LCD
        BL enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
        MOV R0, #0x01            @ Envia comando para limpar o display do LCD
        BL enviarData               @ Chama a macro enviarData para enviar o comando ao LCD

        MOV R0, #0x06            @ Envia comando para configurar o modo de entrada do LCD
        BL enviarData               @ Chama a macro enviarData para enviar o comando ao LCD 
        
        MOV R0, #0x0c            @ Envia comando para posicionar o cursor automaticamente para a direita (0x0C)
        BL enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
.endm


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                 Adicionar O Valor aos pinos de Data do LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, addValue4dataPin, é utilizado para enviar um valor de 4 bits para os pinos de dados do LCD.
@ A entrada esperada é o registrador R2, que contém o valor a ser enviado [3:0].

addValue4dataPin:

    @ Parâmetro da função R2 = 1010

    PUSH {R0-R2, LR}

    LDR R0, =pinD4      @ carrega o endereço do pink d4 em r0
    AND R1, R2, #1      @ máscara para obter o bit menos significativo
    BL stateLogicPin    @ chamada da função para definir o estado do pino d4

    LSR R2, #1          @ deslocamento dos bits uma posição à direita
    LDR R0, =pinD5 
    AND R1, R2, #1
    BL stateLogicPin

    LSR R2, #1
    LDR R0, =pinD6
    AND R1, R2, #1
    BL stateLogicPin

    LSR R2, #1
    LDR R0, =pinD7
    AND R1, R2, #1
    BL stateLogicPin

    BL pulsoEnable

    POP {R0-R2, PC}
    BX LR


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Sinal de pulso no pino de enable do LCD                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pulsoEnable:

    PUSH {R0-R4, LR}

    LDR R0, =E

    MOV R1, #0
    BL stateLogicPin
    nanoSleep time1ms

    MOV R1, #1 
    BL stateLogicPin
    nanoSleep time1ms

    MOV R1, #0 
    BL stateLogicPin
    nanoSleep time1ms

    POP {R0-R4, PC}
    BX LR


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Enviar 8 bits para o LCD                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@   - R0: Byte a ser enviado para o LCD

enviarData:

    PUSH {R0-R3, LR}

    MOV R2, R0
    AND R3, R2, #0xF
    LSR R2, #4
    BL addValue4dataPin

    MOV R2, R3
    BL addValue4dataPin

    POP {R0-R3, PC}
    BX LR

@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                      Envia uma string terminada para o LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@   - R0: Ponteiro para a string
@   - R1: Tamanho da string (número de caracteres)
stringLine:
    PUSH {R0-R8, LR} @ Preserva registradores e o link register

    MOV R5, R0 @ R5: Ponteiro para a string
    MOV R6, R1 @ R6: Tamanho da string
    MOV R7, #0 @ R7: Contador de loop (i)

    LDR R0, =RS   @ Define RS como alto (modo de dados)
    MOV R1, #1
    BL stateLogicPin @ Chama a função stateLogicPin

    @ Loop para enviar caracteres
    forStringLine:
        CMP R7, R6 @ Compara o contador de loop com o tamanho da string
        BGE exitForStringLine @ Se R7 >= R6, sai do loop

        @LSL R0, R7, #0         @ Calcula o deslocamento para o caractere atual na string
        ADD R0, R7, R5          @ Calcula o endereço do caractere atual na string
        LDR R0, [R0]            @ Carrega o caractere atual da memória para R0
        BL enviarData           @ Envia o caractere para o LCD usando a função enviarData

        ADD R7, #1 @ Incrementa o contador de loop
        B forStringLine @ Salta de volta para o início do loop

    exitForStringLine:
        LDR R0, =RS  @ Define RS como baixo (modo de instrução)
        MOV R1, #0
        BL stateLogicPin @ Chama a função stateLogicPin

    POP {R0-R8, PC} @ Restaura registradores e retorna da sub-rotina
    BX LR @ Ramo para o endereço de retorno armazenado no Link Register (LR)

@======================================================================================



