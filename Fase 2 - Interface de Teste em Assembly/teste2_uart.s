.EQU    O_RDWR,                 2           @ Permissão de leitura e escrita para arquivo
.EQU    sys_open,               5           @ Número do serviço Linux para abrir um arquivo
.EQU    sys_mmap2,              192         @ Número do serviço Linux para mapear memória

.EQU UART_THR,          0x0000   @ Dado a ser transmitido na UART 
.EQU UART_DLL,          0x0000   @ 8 bits mais baixos do divisor de baud rate (7:0)
.EQU UART_DLH,          0x0004   @ 8 bits mais altos do divisor de baud rate (7:0)

.EQU UART_FCR,          0x0008   @ Registrador de controle dos FIFOs
.EQU UART_FIFOE,        0b1   @ Habilita os FIFOs

.EQU UART_LCR,          0x000C   @ Registrador de linhas de controle
.EQU UART_DLAB_TR ,     0x00000000   @ Seta para receber/enviar dados (7 << 0)
.EQU UART_DLAB_BD ,     0b10000000   @ Seta o baud rate (7 << 1)
.equ UART_DLS,          0b11    @ Tamanho do cojunto de bits da UART (11 - 8 bits)

.EQU sys_nanosleep,     162

.macro UART_Mapeamento

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

    ldr     R1,     =pagelenn 
    ldr     R1,     [R1]

    mov     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    mov     R3,     #1
    mov     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    mov     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    svc     0

    add     R0,     #0xC00              @ Adiciona o deslocamento para encontrar a UART3
    mov     R9,     R0                  @ Salva o retorno do serviço sys_mmap2 em R8

.endm

.macro UART_Config

    mov r0, #UART_DLAB_BD         @ Setando os espaços de endereço para carregar o baud rate
	str r0, [r9, #UART_LCR]   

    mov r0, #0x45                @ Setando 8 bits baixos do baud rate
	str r0, [r9, #UART_DLL]    

    mov r0, #0x01                @ Setando 8 bits altos do baud rate
	str r0, [r9, #UART_DLH] 

    mov r0, #0x01                @ Tempo de 1 segundos
	mov r1, #0x00
	mov r7, #sys_nanosleep       @ Contando o tempo de 1 segundo para carregar o baud rate
	svc 0

    mov r0, #UART_DLAB_TR         @ Setando os espaços de endereço para carregar dados de transmissão e recebimento
	str r0, [r9, #UART_LCR]     

    mov r0, #UART_DLS             @ Setando o tamanho do conjunto de bits lidos pela UART
	str r0, [r9, #UART_LCR]   

    mov r0, #UART_FIFOE           @ Habilitando o FIFO
	str r0, [r9, #UART_FCR]

.endm

.macro UART_tx_byte  

	mov r0, #0xAA               @ Enviando byte para a UART
	str r0, [r9, #UART_THR]

.endm

.data 
base_uart:	.word 0x01C28
pagelenn:    .word 0x1000