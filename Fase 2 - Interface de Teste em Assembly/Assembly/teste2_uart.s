.EQU    O_RDWR,                 2           @ Permissão de leitura e escrita para arquivo
.EQU    sys_open,               5           @ Número do serviço Linux para abrir um arquivo
.EQU    sys_mmap2,              192         @ Número do serviço Linux para mapear memória

.EQU UART_THR,                  0x0000      @ Dado a ser transmitido na UART 
.EQU UART_DLL,                  0x0000      @ 8 bits mais baixos do divisor de baud rate (7:0)
.EQU UART_DLH,                  0x0004      @ 8 bits mais altos do divisor de baud rate (7:0)

.EQU UART_FCR,                  0x0008      @ Registrador de controle dos FIFOs
.EQU UART_FIFOE,                0b1         @ Habilita os FIFOs

.EQU UART_LCR,                  0x000C      @ Registrador de linhas de controle
.EQU UART_DLAB_TR ,             0x00000000  @ Seta para receber/enviar dados (7 << 0)
.EQU UART_DLAB_BD ,             0b10000000  @ Seta o baud rate (7 << 1)
.EQU UART_DLS,                  0b11        @ Tamanho do cojunto de bits da UART (11 - 8 bits)

.EQU UART_HALT,                 0x00A4
.EQU UART_CHANGE_UPDATE,        0b100      
.EQU UART_CHCFG_AT_BUSY,        0b10      

.EQU sys_nanosleep,             162

.global _start

_start:

@UART_preMap

    ldr     r0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    mov     r1,     #O_RDWR
    @mov R2, #S_RDWR                    @ No livro usa - permição de gravação e escrita
    mov     r7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    svc 0 
    mov     r4,     r0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    ldr     r5,     =CCUaddr           @ endereço GPIO / 4096
    ldr     r5,     [r5]                @ carrega o endereço

    ldr     r1,     =pagelen 
    ldr     r1,     [r1]

    mov     r2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    mov     r3,     #1
    mov     r0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    mov     r7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    svc     0
    mov r8, r0

    @ Selecionado clock
    
    ldr r0, [r8, #0x58] @ Conteudo do registrador 
    mov r1, #1
    lsl r1, #25
    orr r0, r1
    str r0, [r8, #0x58]

    @ PASSAE O CLOCK PARA A UART 3

    ldr r0, [r8, #0x6C]
    mov r1, #1
    lsl r1, #19
    orr r0, r1
    str r0, [r8, #0x6C]

    @ resetar barramento de software do registrador

    ldr r0, [r8, #0x2D8]
    mov r1, #1
    lsl r1, #19
    orr r0, r1
    str r0, [r8, #0x2D8]

@UART_Map

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    ldr     R0,     =devMen             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    mov     R1,     #O_RDWR
    @mov R2, #S_RDWR                    @ No livro usa - permição de gravação e escrita
    mov     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    svc 0 
    mov     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    ldr     r5,     =base_uart          @ endereço UART / 4096
    ldr     r5,     [r5]                @ carrega o endereço

    ldr     R1,     =pagelen
    ldr     R1,     [R1]

    mov     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    mov     R3,     #1
    mov     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    mov     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    svc     0

    add     R0,     #0xC00              @ Adiciona o deslocamento para encontrar a UART3
    mov     R9,     R0                  @ Salva o retorno do serviço sys_mmap2 em R8

@UART_Config

    ldr r0, [r9, #UART_LCR]
    orr r0, r0, #UART_DLAB_BD           @ Setando os espaços de endereço para carregar o baud rate
	str r0, [r9, #UART_LCR]   

    ldr r0, [r9, #UART_HALT]
    orr r0, r0, #UART_CHCFG_AT_BUSY         @ Habilitando alteração na setagem de baud rate e configurações do LCR
	str r0, [r9, #UART_HALT] 

    mov r0, #0x45                @ Setando 8 bits baixos do baud rate
	str r0, [r9, #UART_DLL]    

    mov r0, #0x01                @ Setando 8 bits altos do baud rate
	str r0, [r9, #UART_DLH] 

    ldr r0, [r9, #UART_LCR]
    orr r0, r0, #UART_DLS             @ Setando o tamanho do conjunto de bits lidos pela UART
	str r0, [r9, #UART_LCR]  

    mov r0, #0x01                @ Tempo de 1 segundos
	mov r1, #0x00
	mov r7, #sys_nanosleep       @ Contando o tempo de 1 segundo para carregar o baud rate
	svc 0

    ldr r0, [r9, #UART_HALT]
    orr r0, r0, #UART_CHANGE_UPDATE  @ Carregando alterações
	str r0, [r9, #UART_HALT] 

_loop_update:                        @ Aguardando o bit de update resetar

    ldr r0, [r9, #UART_HALT]
    and r0, r0, #0b100
    adds r1, r0, #0b100
    beq _loop_update

    ldr r0, [r9, #UART_LCR]
    mov r0, #(0<<7)                     @ Setando os espaços de endereço para carregar dados de transmissão e recebimento
	str r0, [r9, #UART_LCR]     

    ldr r0, [r9, #UART_HALT]
    mov r0, #(0<<1)                   @ Desabilitando alteração na setagem de baud rate e configurações do LCR
	str r0, [r9, #UART_HALT]  

    ldr r0, [r9, #UART_FCR]
    orr r0, r0, #UART_FIFOE           @ Habilitando o FIFO
	str r0, [r9, #UART_FCR]

@UART_tx_byte  

	mov r0, #0xAA               @ Enviando byte para a UART
	str r0, [r9, #UART_THR]

@teste

    ldr r0, [r9, #0x0008]       @ bits [7:6] indicam se o FIFO está habilitado. 11 - habilitado

    ldr r0, [r9, #0x007C]       @ Indica se o TX FIFO está vazio. [2] = 1, está vazio

_end:   mov     R0, #0      
        mov     R7, #1      
        svc     0   

.data 
devMen:   .asciz  "/dev/mem"
CCUaddr:	.word 0x01C20
base_uart:	.word 0x01C28
pagelen:    .word 0x1000
