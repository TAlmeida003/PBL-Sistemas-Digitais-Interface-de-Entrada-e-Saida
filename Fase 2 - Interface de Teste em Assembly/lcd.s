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

.macro iniciarSaidasLCD
    LDR R0, =pinD4
    MOV R1, #0
    BL stateLogicPin

    LDR R0, =pinD5
    MOV R1, #0
    BL stateLogicPin

    LDR R0, =pinD6
    MOV R1, #0
    BL stateLogicPin

    LDR R0, =pinD7
    MOV R1, #0
    BL stateLogicPin

    LDR R0, =E
    MOV R1, #0
    BL stateLogicPin

    LDR R0, =RS
    MOV R1, #0
    BL stateLogicPin
    nanoSleep time1ms

.endm

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                          Configuração inicial do LCD                               ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro configLCD

        iniciarSaidasLCD

        nanoSleep time100ms

        MOV     R2,     #3       
        addValue4dataPin        @ Function Set
        nanoSleep       time5ms

        MOV     R2,     #3
        addValue4dataPin        @ Function Set
        nanoSleep time150us

        MOV R0, #0x32 @ Function Set
        enviarData
        
        MOV R0, #0x28 @  Function Set
        enviarData 
        
        MOV R0, #0x08 @ Display on/off Control
        enviarData 
        
        MOV R0, #0x01 @ Clear Display
        enviarData

        MOV R0, #0x06 @ Entry Mode Set
        enviarData 

        MOV R0, #0x0e @ Colocar Curso Automatico para Direita 0x0C
        enviarData 

.endm

@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                 Adicionar O Valor aos pinos de Data do LCD                       ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ R2 - Valor há ser enviado [3:0]
@ Sem retorno

.macro addValue4dataPin

    @ R2 = 1010 
    ldr     R0,     =pinD4
    AND R1, R2, #1      @ 1010 & 0001 = 0000
    BL stateLogicPin

    LSR R2, #1          @ R2 = 0101 R2 >> 1

    LDR R0, =pinD5
    AND R1, R2, #1      @ 0101 & 0001 = 0001
    BL stateLogicPin
    
    LSR R2, #1          @ R2 = 0010 R2 >> 1

    LDR R0, =pinD6
    AND R1, R2, #1      @ 0010 & 0001 = 0000
    BL stateLogicPin
    
    LSR R2, #1 @ R2 = 0001 R2 >> 1
    
    LDR R0, =pinD7
    AND R1, R2, #1       @ 0001 & 0001 = 0001
    BL stateLogicPin

    PulsoEnable
    
.endm

@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Sinal de pulso no pino de enable do LCD                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro PulsoEnable

        LDR R4, =E

        MOV R0, R4
        MOV R1, #0
        BL stateLogicPin
        nanoSleep time1ms

        MOV R0, R4
        MOV R1, #1
        BL stateLogicPin 
        nanoSleep time1ms
        
        MOV R0, R4
        MOV R1, #0
        BL stateLogicPin 
        nanoSleep time1ms

.endm 

@======================================================================================

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Enviar 8 bits para o LCD                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ R0 - 8 bits a serem enviados

.macro enviarData

    MOV R2, R0
    AND R3, R2, #0xF    @ Guarda em R3 os bits lsb do char - 10101010 & 000011111 = 00001010
    LSR R2, #4          @ Guarda em R2 os bits msb do char

    addValue4dataPin @ Envia parte MSB

    MOV R2, R3 
    addValue4dataPin @ Envia parte LSB

.endm

@======================================================================================
