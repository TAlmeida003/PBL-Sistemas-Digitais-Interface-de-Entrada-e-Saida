.include "gpio.s"
.include "lcd.s"

.global _start


.macro print string
        ldr	R1, =\string @ string to print
	mov	R2, #13	    @ length of our string
	mov	R7, #4	    @ linux write system call
	svc	0 	    @ Call linux to output the string
.endm 

_start: 


        MapeamentoDeMemoria
        
        iniciarPin

        configLCD

        LDR r1, =resp_screen_l1
        ADD R0, R1, #4
        LDR r1, [r1]

        BL stringLine

        MOV r0, #0xc0
        enviarData

        LDR r1, =resp_screen_l2
        ADD R0, R1, #4
        LDR r1, [r1]

        BL stringLine

loop:   
        LDR R0, =ledBlue
        MOV R1, #1
        BL stateLogicPin

        @nanoSleep time1s

        LDR R0, =button_back
        BL statusInput @R0 = logica do button

        MOV R1, R0
        LDR R0, =ledRed
        BL stateLogicPin

brk1:
        LDR R0, =ledBlue
        MOV R1, #0
        BL stateLogicPin

        @nanoSleep time1s
        
        subs    r6, #1      
        bne     loop        

_end:   mov     R0, #0      
        mov     R7, #1      
        svc     0          

.data

devMen:   .asciz  "/dev/mem"

@0x01C20000 / 1000
gpioaddr: .word   0x01C20  @ Endereço de memória dos registradores GPIO (verifique se está correto para sua placa) 0x01C20800

pagelen:  .word   0x1000

time1s:
        .word 1 @ Tempo em segundos
	.word 000000000 @ Tempo em nanossegundos
        
time1ms:
	.word 0 @ Tempo em segundos
	.word 1500000 @ Tempo em nanossegundos

time5ms:
	.word 0 @ Tempo em segundos
	.word 5500000 @ Tempo em nanossegundos

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


command_screen_l1: 
        .word 0x0e
        .asciz "    0x00 -> :C"

screen_l2:
        .word 0x10
        .asciz "back   ok   next"


address_screen_l1: 
        .word 0x0e
        .asciz "    0x00 -> :A"


wait_screen_l1:
        .word 0x0b
        .asciz "    loading"

wait_screen_l2:
        .word 0x09
        .asciz "      ..."


resp_screen_l1:
        .word 0x0d
        .asciz "   0x08  0xff"

resp_screen_l2:
        .word 0x09
        .asciz "       ok"






