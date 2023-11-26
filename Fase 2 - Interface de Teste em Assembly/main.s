.include "gpio.s"
.include "lcd.s"
.include "button.s"
.include "screens.s"

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

        MOV R10, #1     @ R10 guarda o estado anterior do botão back
        MOV R11, #1     @ R11 guarda o estado anterior do botão ok
        MOV R12, #1     @ R12 guarda o estado anterior do botão next

        MOV R5, #HOME            @ R5 inicia a tela atual
        MOV R6, #1              @ R6 inicia a tela de comando atual (inicia em 1)
        MOV R7, #0              @ R7 inicia a tela de endereço atual (inicia em 0)

loop:     
        CMP R5, #3
        BNE continuarLoop

        nanoSleep time2s

        MOV R5, #4

continuarLoop:

verificaBotaoBack:
        MOV R1, R10             @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_back    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R10, R1             @ R10 recebe o valor antigo do botão
       
        
        CMP R0, #1              @ Compara o retorno da função verificarBotaoPress
        BEQ screenBack          @ Caso seja 1, vai para as configurações da função volta


verificaBotaoOK:
        MOV R1, R11     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_ok    @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R11, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ screenOk


verificarBotaoNext:
        MOV R1, R12     @ R1 guarda o estado anterior do botão para chamar a função
        LDR R0, =button_next   @ R0 guarda o ponteiro do botão
        BL verificarBotaoPress
        MOV R12, R1             @ R10 recebe o valor antigo do botão

        CMP R0, #1
        BEQ screenNext
        
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

test:
        .asciz "silvio eh lindo"

home_screen: 
        .word 0x0C
        .asciz "Bem-vindo(a)"

command_screen_l1: 
        .word 0x0E
        .asciz "    0x00 -> :C"

screen_l2:
        .word 0x10
        .asciz "back   ok   next"

address_screen_l1: 
        .word 0x0E
        .asciz "    0x00 -> :A"


wait_screen_l1:
        .word 0x0B
        .asciz "    loading"

wait_screen_l2:
        .word 0x09
        .asciz "      ..."


resp_screen_l1:
        .word 0x0D
        .asciz "   0x08  0xff"

resp_screen_l2:
        .word 0x09
        .asciz "       ok"

