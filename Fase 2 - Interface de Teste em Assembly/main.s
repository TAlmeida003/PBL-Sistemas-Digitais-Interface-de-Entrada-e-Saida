.include "gpio.s"
.include "lcd.s"
.include "button.s"
.include "screens.s"
.include "getScreen.s"
.include "uart.s"

.global _start


.macro print string
        ldr	R1, =\string @ string to print
	mov	R2, #4	    @ length of our string
	mov	R7, #4	    @ linux write system call
	svc	0 	    @ Call linux to output the string
.endm 

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
        BL printTwoLine


        CMP R5, #3
        BNE continuarLoop @ if tela_atual == espera:

        MOV R0, R6
        BL TX_UART

        MOV R0, R7
        BL TX_UART

        nanoSleep time2s
        nanoSleep time1s

        @  if (comando == comando_continuo_T || comando == comando_continuo_H )
                @tela_atual = tela_continuo
        @ else:
        @       tela_atual = tela_respCOMANDO_CONTINUOosta

        
        CMP R6, #4
        BEQ troca_tela

        CMP R6, #5
        BEQ troca_tela

        B troca_para_resposta

troca_tela:
        MOV R5, #CONTINUO_TEMPERATURA

        B continuarLoop

troca_para_resposta:
        BL RX_UART
        MOV R4, R0
        @MOV R4, #0x00

        BL RX_UART
        @MOV R0, #0x00
        LSL R0, #8
        orr R4, R0

        MOV R5, #4

        b continuarLoop


continuarLoop:

verificaBotaoBack:
        MOV R1, R10             @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_back    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R10, R1             @ R10 recebe o valor antigo do botão
       
        
        CMP R0, #1              @ Compara o retorno da função verificarBotaoPress
        BEQ buttonBack          @ Caso seja 1, vai para as configurações da função volta


verificaBotaoOK:
        MOV R1, R11     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_ok    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R11, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ buttonOk


verificarBotaoNext:
        MOV R1, R12     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_next   @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R12, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ buttonNext
        
        B loop

brk1:

        subs    r6, #1      
        bne     loop        

_end:   mov     R0, #0      
        mov     R7, #1      
        svc     0          


.data

devMem:   .asciz  "/dev/mem"

@0x01C20000 / 1000
gpioaddr: .word   0x01C20  @ Endereço de memória dos registradores GPIO (verifique se está correto para sua placa) 0x01C20800

pagelen:  .word   0x1000

time1s:
        .word 1 @ Tempo em segundos
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
        .asciz "Command: < 00 > "

screen_l2:
        .word 0x10
        .asciz "Back   Ok   Next"

address_screen_l1: 
        .word 16
        .asciz "Address: < 00 > "

wait_screen_l1:
        .word 16
        .asciz "    Loading     "

wait_screen_l2:
        .word 0x09
        .asciz "      ..."

resp_screen_l1:
        .word 0x0D
        .asciz "   0x08  0xff"

resp_screen_l2:
        .word 0x09
        .asciz "       Ok"

sensor_problema:
        .word 19
        .asciz "Sensor com Problema"    

sensor_normal:
        .word 20
        .asciz "Sensor Funcionamento"

temperatura_atual:
        .word 16
        .asciz "Temperatura:   C"

umidade_atual:
        .word 13
        .asciz "Umidade:    %"

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
        .word 18
        .asciz "Endereco Incorreto"

desconectado_screen:
        .word 24
        .asciz "Dispositivo Desconectado"

