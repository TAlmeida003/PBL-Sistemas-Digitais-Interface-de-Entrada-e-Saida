.EQU UART_APB2_CFG_REG,         0x0058      @ Seta o clock usado na UART
.EQU UART_BUS_CLK_GATING_REG3,  0x006C      @ Habilita clock da UART
.EQU UART_BUS_SOFT_RST_REG4,    0x02D8      @ Seta o Reset da UART

.EQU UART_THR,                  0x0000      @ Dado a ser transmitido na UART 
.EQU UART_RBR,                  0x0000      @ Dado a ser lido na UART 
.EQU UART_DLL,                  0x0000      @ 8 bits mais baixos do divisor de baud rate (7:0)
.EQU UART_DLH,                  0x0004      @ 8 bits mais altos do divisor de baud rate (7:0)
.EQU UART_VALUE_DLL,            0b11011110
.EQU UART_VALUE_DLH,            0b1111

.EQU UART_FCR,                  0x0008      @ Registrador de controle dos FIFOs
.EQU UART_FIFOE,                0b1         @ Habilita os FIFOs. Bit 0 recebe 1 

.EQU UART_LCR,                  0x000C      @ Registrador de linhas de controle
.EQU UART_DLAB_BD ,             0b10000000  @ Seta que os endereços dos divisores de baud rate serão alterados. Bit 7 recebe 1
.EQU UART_DLS,                  0b11        @ Seta tamanho do cojunto de bits a ser enviado na UART. Bits 0 e 1 recebem 1

.EQU UART_HALT,                 0x00A4      @ Registrador de configurações de HALT
.EQU UART_CHCFG_AT_BUSY,        0b10        @ Habilita alterações nos endereços de LCR, DLL e DLH. Bit 1 recebe 1
.EQU UART_CHANGE_UPDATE,        0b100       @ Carrega alterações nos endereços de LCR, DLL e DLH. Bit 2 recebe 1  

.EQU UART_USR,                  0x007C      @ Registrador de status da UART
.EQU UART_RFNE,                 0x1000      @ Bit que indica se o FIFO do RX está vazio ou não. Bit 3 igual a 0 indica que está vazio

ENABLE_UART:

    PUSH {R0-R8, LR}

    @UART_preMap

    LDR     R0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    MOV     R1,     #O_RDWR
    MOV     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    SVC     0 
    MOV     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    LDR     R5,     =CCUaddr            @ endereço GPIO / 4096
    LDR     R5,     [R5]                @ carrega o endereço

    LDR     R1,     =pagelen 
    LDR     R1,     [R1]

    MOV     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    MOV     R3,     #1
    MOV     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    MOV     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    SVC     0
    MOV     R8,     R0

    @ Selecionado clock

    LDR     R0,     [R8, #UART_APB2_CFG_REG] @ Conteudo do registrador 
    MOV     R1,     #1
    LSL     R1,     #25
    ORR     R0,     R1
    STR     R0,     [R8, #UART_APB2_CFG_REG]

    @ PASSAE O CLOCK PARA A UART 3

    LDR     R0,     [R8, #UART_BUS_CLK_GATING_REG3]
    MOV     R1,     #1
    LSL     R1,     #19
    ORR     R0,     R1
    STR     R0,     [R8, #UART_BUS_CLK_GATING_REG3]

    @ resetar barramento de software do regiSTRador

    LDR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]
    MOV     R1,     #1
    LSL     R1,     #19
    BIC     R0,     R1
    STR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]

    LDR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]
    MOV     R1,     #1
    LSL     R1,     #19
    ORR     R0,     R1
    STR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]

    POP     {R0-R8, PC}
    BX      LR

MAP_UART:

    PUSH    {R0-R8, LR}

    @UART_Map

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    LDR     R0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    MOV     R1,     #O_RDWR
    MOV     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    SVC     0 
    MOV     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    LDR     R5,     =base_uart          @ endereço UART / 4096
    LDR     R5,     [R5]                @ carrega o endereço

    LDR     R1,     =pagelen
    LDR     R1,     [R1]

    MOV     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    MOV     R3,     #1
    MOV     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    MOV     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    SVC     0

    ADD     R0,     #0xC00              @ Adiciona o deslocamento para encontrar a UART3
    MOV     R9,     R0                  @ Salva o retorno do serviço sys_mmap2 em R8

    POP     {R0-R8, PC}
    BX      LR

CONFIG_UART:

    PUSH    {R0, LR}

    @UART_Config

    LDR     R0,     [R9, #UART_LCR]
    ORR     R0,     #UART_DLAB_BD               @ Setando os espaços de endereço para carregar o baud rate
    STR     R0,     [R9, #UART_LCR] 

    LDR     R0,     [R9, #UART_HALT]
    ORR     R0,     #UART_CHCFG_AT_BUSY         @ Habilitando alteração na setagem de baud rate e configurações do LCR
    STR     R0,     [R9, #UART_HALT] 

    MOV     R0,     #UART_VALUE_DLL                 @ Setando 8 bits baixos do baud rate
    STR     R0,     [R9, #UART_DLL]    

    MOV     R0,     #UART_VALUE_DLH                 @ Setando 8 bits altos do baud rate
    STR     R0,     [R9, #UART_DLH] 

    LDR     R0,     [R9, #UART_LCR]
    ORR     R0,     #UART_DLS             @ Setando o tamanho do conjunto de bits lidos pela UART
    STR     R0,     [R9, #UART_LCR]

    LDR     R0,     [R9, #UART_HALT]
    ORR     R0,     #UART_CHANGE_UPDATE  @ Carregando alterações
    STR     R0,     [R9, #UART_HALT] 

_loop_update:                        @ Aguardando o bit de update resetar

    LDR     R0,     [R9, #UART_HALT]
    AND     R0,     #0b100
    CMP     R0,     #0b100
    BEQ             _loop_update

    LDR     R0,     [R9, #UART_LCR]
    BIC     R0,     #UART_DLAB_BD
    STR     R0,     [R9, #UART_LCR]     

    LDR     R0,     [R9, #UART_HALT]
    BIC     R0,     #UART_CHCFG_AT_BUSY                   @ Desabilitando alteração na setagem de baud rate e configurações do LCR
    STR     R0,     [R9, #UART_HALT]  

    LDR     R0,     [R9, #UART_FCR]
    ORR     R0,     #UART_FIFOE               @ Habilitando o FIFO
    STR     R0,     [R9, #UART_FCR]

    POP     {R0, PC}
    BX      LR

TX_UART:

    STR     R0,     [R9, #UART_THR]
    BX      LR

RX_UART:

    LDR     R0,     [R9, #UART_RBR]
    BX      LR

RESET_FIFO_UART:

    PUSH    {R0, LR}

    LDR     R0,     [R9, #UART_FCR]
    BIC     R0,     #UART_FIFOE               @ Desabilitando o FIFO
    STR     R0,     [R9, #UART_FCR]

    LDR     R0,     [R9, #UART_FCR]
    ORR     R0,     #UART_FIFOE               @ Habilitando o FIFO
    STR     R0,     [R9, #UART_FCR]

    POP     {R0, PC}
    BX      LR

CHECK_EMPTY_RX_UART:

    PUSH    {LR}

    LDR     R0,     [R9, #UART_USR]
    AND     R0,     #UART_RFNE
    LSR     R0,     #3                        @ Se o bit 0 do R0 for 1, o FIFO do RX não está vazio
    
    POP     {PC}
    BX      LR


.data 

CCUaddr:	.word 0x01C20
base_uart:	.word 0x01C28
