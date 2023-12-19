.include "gpio.s"
.include "lcd.s"
.include "button.s"
.include "screens.s"
.include "getScreens.s"
.include "uart.s"

.global _start

_start: 
        MapeamentoDeMemoria
        iniciarPin
        configLCD 

        BL ENABLE_UART
        BL MAP_UART
        BL CONFIG_UART

        MOV R10, #1     @ R10 guarda o estado anterior do botão back
        MOV R11, #1     @ R11 guarda o estado anterior do botão ok
        MOV R12, #1     @ R12 guarda o estado anterior do botão next

        MOV R5, #0            @ R5 inicia a tela atual
        MOV R6, #1              @ R6 inicia a tela de comando atual (inicia em 1)
        MOV R7, #0              @ R7 inicia a tela de endereço atual (inicia em 0)
        MOV R4, #0



loop: 

        BL getTela         @ Buscar paramentros da função "printTwoLine"


        BL CHECK_EMPTY_RX_UART
        CMP R0, #0
        BEQ continuoLogica

        BL RX_UART
        MOV R1, R0

        BL RX_UART
        LSL R0, #8
        orr R1, R0

        AND R0, R1, #0xFF
        CMP R0, #0
        BEQ continuoLogica

        CMP R5, #COMANDO_CONTINUO
        BEQ continuoLogica

        CMP R5, #ENDERECO_CONTINUO
        BEQ continuoLogica

        CMP R5, #ESPERA_RESPOSTA
        BEQ continuoLogica

        CMP R5, #ESPERAR_RESPOSTA_CONTINUO
        BEQ continuoLogica

        AND R0, R4, #0xFF
        CMP R0, #0x6F
        BEQ continuarLoop

        CMP R0, #0xDF
        BEQ continuarLoop


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
        
        B loop

        continuoLogica:
                CMP R5, #COMANDO_CONTINUO
                BEQ c

                CMP R5, #ENDERECO_CONTINUO
                BEQ c
                
                b esperaParaResposta
                c:

                BL receberAsInformacoesDeContinuo

                B loop

        esperaParaResposta:              
                CMP R5, #ESPERA_RESPOSTA
                BEQ or_T @ if tela_atual == espera:

                CMP R5, #ESPERAR_RESPOSTA_CONTINUO
                BEQ or_T @ if tela_atual == espera:
                B continuarLoop

                or_T:

                BL ENABLE_UART
                BL MAP_UART
                BL CONFIG_UART

                MOV R0, R6
                BL TX_UART

                MOV R0, R7
                BL TX_UART

                nanoSleep time2s
                nanoSleep time500ms

                BL RX_UART
                MOV R4, R0

                BL RX_UART
                LSL R0, #8
                orr R4, R0

                CMP R5, #ESPERAR_RESPOSTA_CONTINUO
                BEQ troca_para_resposta
                
                CMP R6, #4
                BEQ troca_para_continuo

                CMP R6, #5
                BEQ troca_para_continuo

                MOV R5, #RESPOSTA

                MOV R0, #1
                BL enviarData

                b continuarLoop

        troca_para_resposta:

                AND R0, R4, #0xFF
                CMP R0, #0x0A
                BEQ troca_para_continuo
                CMP R0, #0x09
                BEQ troca_para_continuo
                CMP R0, #0x1F
                BEQ troca_para_continuo

                MOV R5, #RESPOSTA
                
                MOV R0, #1
                BL enviarData

                b continuarLoop

        troca_para_continuo:
                MOV R5, #COMANDO_CONTINUO

                MOV R6, #1
                MOV R7, #0

                B continuarLoop



continuarLoop:

        BL TrocaDeTela
        B loop      

_end:   mov     R0, #0      
        mov     R7, #1      
        svc     0          


.data

devMem:   .asciz  "/dev/mem"

gpioaddr: .word   0x01C20  @ Endereço de memória dos registradores GPIO (verifique se está correto para sua placa) 0x01C20800

pagelen:  .word   0x1000

time1s:
        .word 1         @ Tempo em segundos
	.word 000000000 @ Tempo em nanossegundos

time2s:
        .word 2 @ Tempo em segundos
	.word 400000000 @ Tempo em nanossegundos
        
time1ms:
	.word 0 @ Tempo em segundos
	.word 1500000 @ Tempo em nanossegundos

time5ms:
	.word 0 @ Tempo em segundos
	.word 5500000 @ Tempo em nanossegundos

time30ms:
        .word 0 
        .word 30050000

time100ms:
	.word 0 @ Tempo em segundos
	.word 100500000 @ Tempo em nanossegundos

time500ms:
	.word 0 @ Tempo em segundos
	.word 500500000 @ Tempo em nanossegundos


time150us: 
        .word 0 @ Tempo em segundos
	.word 150000 @ 150us
time100us: 
        .word 0 @ Tempo em segundos
	.word 100000 @ 150us

ledBlue:        @ PA9       
        .word 0x4       @ offest
        .word 0x4       @ lsb
	.word 0x9       @localização do pino em hex
	.word 0x10      @ DATA REGISTER

ledRed:         @ PA8     
        .word 0x4      
        .word 0x0      
	.word 0x8       
	.word 0x10      

E:              @ PA18
        .word 0x8
        .word 0x08
        .word 0x12
        .word 0x10

pinD4:          @PG8
        .word 0xdc
        .word 0x0
        .word 0x8
        .word 0xE8

pinD5:          @PG9
        .word 0xdc
        .word 0x4
        .word 0x9
        .word 0xE8

pinD6:          @PG6
        .word 0xd8
        .word 0x18
        .word 0x6
        .word 0xE8

pinD7:          @PG7
        .word 0xd8
        .word 0x1c
        .word 0x7
        .word 0xE8

RS:             @PA2
        .word 0x0
        .word 0x8
        .word 0x2
        .word 0x10


button_back:    @pa7
        .word 0x0
        .word 0x1C
        .word 0x7
        .word 0x10

button_ok:      @pa10
        .word 0x4
        .word 0x8
        .word 0XA
        .word 0x10

button_next:    @pa20
        .word 0x8
        .word 0x10
        .word 0x14
        .word 0x10


uartRx:         @PA14
        .word 0x4
        .word 0x18 
        .word 0xe
        .word 0x10

uartTx:         @ PA13
        .word 0x4
        .word 0x14
        .word 0xd
        .word 0x10

home_screen: 
        .word 16
        .asciz "- Bem-vindo(a) -"

line2home: 
        .word 32
        .asciz "Sistema de Temperatura e Umidade"

command_screen_l1: 
        .word 16
        .asciz "Comando : < 01 >"

screen_l2:
        .word 16
        .asciz "Volt.  ok  Prox."

address_screen_l1: 
        .word 16
        .asciz "Endereco: < 01 >"

wait_screen_l1:
        .word 16
        .asciz "   Processando  "

wait_screen_l2:
        .word 10
        .asciz "       ..."

resp_screen_l1:
        .word 0x0D
        .asciz "   0x08  0xff"

resp_screen_l2:
        .word 0x09
        .asciz "       ok"

sensor_problema:
        .word 19
        .asciz "Sensor com Problema"

sensor_normal:
        .word 18
        .asciz "Sensor Funcionando"

temperatura_atual:
        .word 14
        .asciz "  Temp. : 32 C"

umidade_atual:
        .word 14
        .asciz "  Umid. :  32%"

desativa_temperatura:
        .word 27
        .asciz "T: Sensoriamento Desativado"

desativa_umidade:
        .word 27
        .asciz "U: Sensoriamento Desativado"

comando_incorreto:
        .word 17
        .asciz "Comando Incorreto"

endereco_incorreto:
        .word 16
        .asciz "Erro de Endereco"

desconectado_screen:
        .word 24
        .asciz "Dispositivo Desconectado"

comando_valido:
        .word 15
        .asciz "Com. valido: 01"

endereco_valido: 
        .word 16
        .asciz "Ende. valido: 01"

sem_resposta:
        .word 14
        .asciz "  Sem Resposta"

armengoDoBom:
        .word 16
        .asciz " Modo Continuo Ati                                  "

