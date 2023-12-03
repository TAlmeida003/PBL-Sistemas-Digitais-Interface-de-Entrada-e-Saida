.EQU UART_APB2_CFG_REG,         0x0058      @ Seta o clock usado na UART
.EQU UART_BUS_CLK_GATING_REG3,  0x006C      @ Habilita clock da UART
.EQU UART_BUS_SOFT_RST_REG4,    0x02D8      @ Seta o Reset da UART

.EQU UART_THR,                  0x0000      @ Dado a ser transmitido na UART 
.EQU UART_RBR,                  0x0000      @ Dado a ser lido na UART 
.EQU UART_DLL,                  0x0000      @ 8 bits mais baixos do divisor de baud rate (7:0)
.EQU UART_DLH,                  0x0004      @ 8 bits mais altos do divisor de baud rate (7:0)

.EQU UART_FCR,                  0x0008      @ Registrador de controle dos FIFOs
.EQU UART_FIFOE,                0b1         @ Habilita os FIFOs. Bit 0 recebe 1 

.EQU UART_LCR,                  0x000C      @ Registrador de linhas de controle
.EQU UART_DLAB_TR ,             0b00000000  @ Seta o uso dos endereços do RX e TX . Bit 7 recebe 0
.EQU UART_DLAB_BD ,             0b10000000  @ Seta que os endereços dos divisores de baud rate serão alterados. Bit 7 recebe 1
.EQU UART_DLS,                  0b11        @ Seta tamanho do cojunto de bits a ser enviado na UART. Bits 0 e 1 recebem 1

.EQU UART_HALT,                 0x00A4      @ Registrador de configurações de HALT
.EQU UART_CHCFG_AT_BUSY,        0b10        @ Habilita alterações nos endereços de LCR, DLL e DLH. Bit 1 recebe 1
.EQU UART_CHANGE_UPDATE,        0b100       @ Carrega alterações nos endereços de LCR, DLL e DLH. Bit 2 recebe 1  

MAP_UART:

    PUSH {R0-R8, LR}

    @UART_preMap

    ldr     r0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    mov     r1,     #O_RDWR
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

    ldr r0, [r8, #UART_APB2_CFG_REG] @ Conteudo do registrador 
    mov r1, #1
    lsl r1, #25
    orr r0, r1
    str r0, [r8, #UART_APB2_CFG_REG]

    @ PASSAE O CLOCK PARA A UART 3

    ldr r0, [r8, #UART_BUS_CLK_GATING_REG3]
    mov r1, #1
    lsl r1, #19
    orr r0, r1
    str r0, [r8, #UART_BUS_CLK_GATING_REG3]

    @ resetar barramento de software do registrador

    ldr r0, [r8, #UART_BUS_SOFT_RST_REG4]
    mov r1, #1
    lsl r1, #19
    bic r0, r1
    str r0, [r8, #UART_BUS_SOFT_RST_REG4]

    ldr r0, [r8, #UART_BUS_SOFT_RST_REG4]
    mov r1, #1
    lsl r1, #19
    orr r0, r1
    str r0, [r8, #UART_BUS_SOFT_RST_REG4]

    @UART_Map

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    ldr     R0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    mov     R1,     #O_RDWR
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

    POP {R0-R8, PC}
    BX LR

CONFIG_UART:

    PUSH {R0, R1, LR}

    @UART_Config

    ldr r0, [r9, #UART_LCR]
    orr r0, r0, #UART_DLAB_BD           @ Setando os espaços de endereço para carregar o baud rate
    str r0, [r9, #UART_LCR] 

    ldr r0, [r9, #UART_HALT]
    orr r0, r0, #UART_CHCFG_AT_BUSY         @ Habilitando alteração na setagem de baud rate e configurações do LCR
    str r0, [r9, #UART_HALT] 

    mov r0, #0b11011110                @ Setando 8 bits baixos do baud rate
    str r0, [r9, #UART_DLL]    

    mov r0, #0b1111                @ Setando 8 bits altos do baud rate
    str r0, [r9, #UART_DLH] 

    ldr r0, [r9, #UART_LCR]
    orr r0, r0, #UART_DLS             @ Setando o tamanho do conjunto de bits lidos pela UART
    str r0, [r9, #UART_LCR]

    ldr r0, [r9, #UART_HALT]
    orr r0, r0, #UART_CHANGE_UPDATE  @ Carregando alterações
    str r0, [r9, #UART_HALT] 

_loop_update:                        @ Aguardando o bit de update resetar

    ldr r0, [r9, #UART_HALT]
    and r0, r0, #0b100
    adds r1, r0, #0b100
    beq _loop_update

    ldr r0, [r9, #UART_LCR]
    mov r1, #0b10000000
    bic r0, r1
    str r0, [r9, #UART_LCR]     

    ldr r0, [r9, #UART_HALT]
    mov r1, #0b10
    bic r0, r1                   @ Desabilitando alteração na setagem de baud rate e configurações do LCR
    str r0, [r9, #UART_HALT]  

    ldr r0, [r9, #UART_FCR]
    orr r0, r0, #UART_FIFOE           @ Habilitando o FIFO
    str r0, [r9, #UART_FCR]

    POP {R0, R1, PC}
    BX LR

TX_UART:

    str r0, [r9, #UART_THR]
    BX LR

RX_UART:

    ldr r0, [r9, #UART_RBR]
    BX LR

.data 

CCUaddr:	.word 0x01C20
base_uart:	.word 0x01C28
