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
        addValue4dataPin        @ Envia comando de função Set ao LCD
        nanoSleep       time5ms  @ Aguarda 5 milissegundos

        MOV     R2,     #3
        addValue4dataPin        @ Envia novamente o comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos

        MOV     R2,     #3
        addValue4dataPin        @ Envia mais uma vez o comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos

        MOV     R2,     #2
        addValue4dataPin        @ Envia o último comando de função Set ao LCD
        nanoSleep time150us      @ Aguarda 150 microssegundos
        
        .ltorg                    @ Organiza os literais em locais de memória

        MOV R0, #0x28            @ Envia comando para configurar a função Set do LCD
        enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
        MOV R0, #0x08            @ Envia comando para controlar a exibição do LCD
        enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
        MOV R0, #0x01            @ Envia comando para limpar o display do LCD
        enviarData               @ Chama a macro enviarData para enviar o comando ao LCD

        MOV R0, #0x06            @ Envia comando para configurar o modo de entrada do LCD
        enviarData               @ Chama a macro enviarData para enviar o comando ao LCD 
        
        .ltorg                    @ Organiza os literais em locais de memória

        MOV R0, #0x0e            @ Envia comando para posicionar o cursor automaticamente para a direita (0x0C)
        enviarData               @ Chama a macro enviarData para enviar o comando ao LCD
        
.endm


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                 Adicionar O Valor aos pinos de Data do LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Este macro, addValue4dataPin, é utilizado para enviar um valor de 4 bits para os pinos de dados do LCD.
@ A entrada esperada é o registrador R2, que contém o valor a ser enviado [3:0].

.macro addValue4dataPin

    @ R2 = 1010 
    LDR     R0,     =pinD4    @ Carrega o endereço do pino D4 em R0
    AND R1, R2, #1              @ Aplica uma máscara para obter o bit menos significativo (LSB) de R2
    BL stateLogicPin            @ Chama a função stateLogicPin para definir o estado do pino D4

    LSR R2, #1                  @ Desloca os bits de R2 uma posição à direita
    LDR R0, =pinD5              @ Carrega o endereço do pino D5 em R0
    AND R1, R2, #1              @ Aplica uma máscara para obter o próximo bit de R2
    BL stateLogicPin            @ Chama a função stateLogicPin para definir o estado do pino D5
    
    LSR R2, #1                  @ Desloca os bits de R2 uma posição à direita
    LDR R0, =pinD6              @ Carrega o endereço do pino D6 em R0
    AND R1, R2, #1              @ Aplica uma máscara para obter o próximo bit de R2
    BL stateLogicPin            @ Chama a função stateLogicPin para definir o estado do pino D6
    
    LSR R2, #1                  @ Desloca os bits de R2 uma posição à direita
    LDR R0, =pinD7              @ Carrega o endereço do pino D7 em R0
    AND R1, R2, #1              @ Aplica uma máscara para obter o último bit de R2
    BL stateLogicPin            @ Chama a função stateLogicPin para definir o estado do pino D7

    PulsoEnable                 @ Gera um pulso no pino de habilitação (Enable)
    
.endm


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Sinal de pulso no pino de enable do LCD                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro PulsoEnable

        LDR R4, =E              @ Carrega o endereço do pino de Enable em R4

        MOV R0, R4              @ Move o endereço do pino de Enable para R0
        MOV R1, #0              @ Configura o pino de Enable como baixo (0)
        BL stateLogicPin        @ Chama a função stateLogicPin para definir o estado do pino
        nanoSleep time1ms       @ Aguarda um curto período de tempo (1 ms)

        MOV R0, R4              @ Move novamente o endereço do pino de Enable para R0
        MOV R1, #1              @ Configura o pino de Enable como alto (1)
        BL stateLogicPin        @ Chama a função stateLogicPin para definir o estado do pino
        nanoSleep time1ms       @ Aguarda um curto período de tempo (1 ms)

        MOV R0, R4              @ Move novamente o endereço do pino de Enable para R0
        MOV R1, #0              @ Configura o pino de Enable como baixo (0)
        BL stateLogicPin        @ Chama a função stateLogicPin para definir o estado do pino
        nanoSleep time1ms       @ Aguarda um curto período de tempo (1 ms)

.endm


@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Enviar 8 bits para o LCD                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@   - R0: Byte a ser enviado para o LCD

.macro enviarData

    MOV R2, R0              @ Move o byte para R2
    AND R3, R2, #0xF        @ Máscara para obter os bits menos significativos (LSB) do caractere
    LSR R2, #4              @ Desloca os bits mais significativos (MSB) para a posição correta

    addValue4dataPin        @ Envia a parte MSB do byte para o LCD

    MOV R2, R3              @ Move os bits LSB para R2
    addValue4dataPin        @ Envia a parte LSB do byte para o LCD

.endm

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

        LSL R0, R7, #3 @ Calcula o deslocamento para o caractere atual na string
        ADD R0, R5     @ Calcula o endereço do caractere atual na string
        LDR R0, [R0]   @ Carrega o caractere atual da memória para R0
        enviarData     @ Envia o caractere para o LCD usando a função enviarData

        ADD R7, #1 @ Incrementa o contador de loop
        B forStringLine @ Salta de volta para o início do loop

    exitForStringLine:
    LDR R0, =RS  @ Define RS como baixo (modo de instrução)
    MOV R1, #0
    BL stateLogicPin @ Chama a função stateLogicPin

    POP {R0-R8, PC} @ Restaura registradores e retorna da sub-rotina
    BX LR @ Ramo para o endereço de retorno armazenado no Link Register (LR)

@======================================================================================
