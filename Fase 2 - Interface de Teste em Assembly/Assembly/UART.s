@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                             GERENCIAMENTO DA UART                               -
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Este código Assembly descreve a lógica para uso da UART 3. Possui funções com os 
@ seguintes objetivos: setagem de clock e alteração do reset; mapeamento de memória; 
@ configuração; envio e recebimento de dados; e checagem de recebimento de dados. 


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                                  Constantes                                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.EQU UART_APB2_CFG_REG,         0x0058      @ Seta o clock usado nas UARTs [25:24] 
.EQU UART_BUS_CLK_GATING_REG3,  0x006C      @ Habilita o clock da UART 3 [19] 
.EQU UART_BUS_SOFT_RST_REG4,    0x02D8      @ Seta o Reset da UART 3 [19] 

.EQU UART_THR,                  0x0000      @ Dado a ser transmitido na UART [7:0]
.EQU UART_RBR,                  0x0000      @ Dado a ser lido na UART [7:0]        
.EQU UART_DLL,                  0x0000      @ Local de armazenamento dos 8 bits mais baixos do divisor de baud rate [7:0]
.EQU UART_DLH,                  0x0004      @ Local de armazenamento dos 8 bits mais altos do divisor de baud rate [7:0]
.EQU UART_VALUE_DLL,            0b11011110  @ 8 bits mais baixos do divisor de baud rate [7:0]
.EQU UART_VALUE_DLH,            0b1111      @ 8 bits mais altos do divisor de baud rate [7:0]
                                            @ Valor divisor = 4062

.EQU UART_FCR,                  0x0008      @ Registrador de controle dos FIFOs
.EQU UART_FIFOE,                0b1         @ Habilita os FIFOs. Bit 0 recebe 1 

.EQU UART_LCR,                  0x000C      @ Registrador de linhas de controle
.EQU UART_DLAB_BD ,             0b10000000  @ Seta que os endereços dos divisores de baud rate serão alterados. Bit 7 recebe 1
.EQU UART_DLS,                  0b11        @ Seta tamanho do cojunto de bits a ser enviado na UART. Bits 0 e 1 recebem 1

.EQU UART_HALT,                 0x00A4      @ Registrador de configurações de HALT
.EQU UART_CHCFG_AT_BUSY,        0b10        @ Habilita alterações nos endereços de LCR, DLL e DLH. Bit 1 recebe 1
.EQU UART_CHANGE_UPDATE,        0b100       @ Carrega alterações nos endereços de LCR, DLL e DLH. Bit 2 recebe 1  

.EQU UART_USR,                  0x007C      @ Registrador de status da UART
.EQU UART_RFNE,                 0b1000      @ Bit que indica se o FIFO do RX está vazio ou não. Bit 3 igual a 0 indica que está vazio

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Habilitação e reset da UART                                  ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Sem Parametro
@ Sem Retorno

ENABLE_UART:

    PUSH {R0-R8, LR}

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    LDR     R0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    MOV     R1,     #O_RDWR
    MOV     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    SVC     0 
    MOV     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    LDR     R5,     =CCUaddr            @ endereço CUU / 4096
    LDR     R5,     [R5]                @ carrega o endereço

    LDR     R1,     =pagelen 
    LDR     R1,     [R1]

    MOV     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    MOV     R3,     #1
    MOV     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    MOV     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    SVC     0
    MOV     R8,     R0

    @ Selecionando o clock PLL_PERIPH0 para a UART, que possui frequência de 624 MHz

    LDR     R0,     [R8, #UART_APB2_CFG_REG]         @ Carrega conteudo do registrador 
    MOV     R1,     #1
    LSL     R1,     #25                              @ Coloca o bit da posição 25 do registrador como 1
    ORR     R0,     R1                               @ Altera o bit da posição 25 dos dados carregados para selecionar o clock PLL_PERIPH0 
    STR     R0,     [R8, #UART_APB2_CFG_REG]         @ Salva alterações

    @ Habilitando o clock da UART 3

    LDR     R0,     [R8, #UART_BUS_CLK_GATING_REG3]  @ Carrega conteudo do registrador 
    MOV     R1,     #1
    LSL     R1,     #19                              @ Coloca o bit da posição 19 do registrador como 1
    ORR     R0,     R1                               @ Altera o bit da posição 19 dos dados carregados para habilitar o clock da UART 3
    STR     R0,     [R8, #UART_BUS_CLK_GATING_REG3]  @ Salva alterações

    @ Resetando dados e configurações da UART 3

    LDR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]    @ Carrega conteudo do registrador 
    MOV     R1,     #1
    LSL     R1,     #19                              @ Coloca o bit da posição 19 do registrador como 1
    BIC     R0,     R1                               @ Limpa o bit da posição 19 dos dados carregados para habilitar o reset da UART 3
    STR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]    @ Salva alterações

    @ Desabilitando o reset de dados e configurações da UART 3

    LDR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]    @ Carrega conteudo do registrador
    MOV     R1,     #1
    LSL     R1,     #19                              @ Coloca o bit da posição 19 do registrador como 1
    ORR     R0,     R1                               @ Altera o bit da posição 19 dos dados carregados para desabilitar o reset da UART 3
    STR     R0,     [R8, #UART_BUS_SOFT_RST_REG4]    @ Salva alterações

    POP     {R0-R8, PC}
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                     Mapeamento de memória da UART                                ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Sem Parametro
@ Retorno: R9 - Endereço base do mapeamento da UART 3

MAP_UART:

    PUSH    {R0-R8, LR}

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    LDR     R0,     =devMem             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    MOV     R1,     #O_RDWR
    MOV     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    SVC     0 
    MOV     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    LDR     R5,     =base_uart          @ endereço UART3 / 4096
    LDR     R5,     [R5]                @ carrega o endereço

    LDR     R1,     =pagelen
    LDR     R1,     [R1]

    MOV     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    MOV     R3,     #1
    MOV     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    MOV     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    SVC     0

    ADD     R0,     #0xC00              @ Adiciona o deslocamento para encontrar a UART3
    MOV     R9,     R0                  @ Salva o retorno do serviço sys_mmap2 em R9

    POP     {R0-R8, PC}
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Configuração da UART 3                                ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R9 - Endereço base do mapeamento da UART 3
@ Sem Retorno

CONFIG_UART:

    PUSH    {R0, LR}

    LDR     R0,     [R9, #UART_LCR]          @ Carrega conteudo do registrador
    ORR     R0,     #UART_DLAB_BD            @ Setando os espaços de endereço para alterar o valor do baud rate
    STR     R0,     [R9, #UART_LCR]          @ Salva alterações

    LDR     R0,     [R9, #UART_HALT]         @ Carrega conteudo do registrador
    ORR     R0,     #UART_CHCFG_AT_BUSY      @ Habilitando alteração na setagem de baud rate e configurações do LCR
    STR     R0,     [R9, #UART_HALT]         @ Salva alterações

    MOV     R0,     #UART_VALUE_DLL          @ Seta 8 bits baixos do baud rate
    STR     R0,     [R9, #UART_DLL]          @ Salva os 8 bits baixos do baud rate

    MOV     R0,     #UART_VALUE_DLH          @ Seta 8 bits altos do baud rate
    STR     R0,     [R9, #UART_DLH]          @ Salva os 8 bits altos do baud rate

    LDR     R0,     [R9, #UART_LCR]          @ Carrega conteudo do registrador
    ORR     R0,     #UART_DLS                @ Setando o tamanho do conjunto de bits lidos pela UART para 8 bits
    STR     R0,     [R9, #UART_LCR]          @ Salva alterações

    LDR     R0,     [R9, #UART_HALT]         @ Carrega conteudo do registrador
    ORR     R0,     #UART_CHANGE_UPDATE      @ Chamando o salvamento das alterações do divisor do baud rate e do endereço LCR 
    STR     R0,     [R9, #UART_HALT]         @ Salva alterações

_loop_update:                                @ Aguardando o bit de update resetar

    LDR     R0,     [R9, #UART_HALT]         @ Carrega conteudo do registrador
    AND     R0,     #0b100
    CMP     R0,     #0b100                   @ Verifica se o bit do UART_CHANGE_UPDATE foi limpo, indicando que a atualização ocorreu
    BEQ             _loop_update             @ Se ele não tiver limpado, continua o loop

    LDR     R0,     [R9, #UART_LCR]          @ Carrega conteudo do registrador
    BIC     R0,     #UART_DLAB_BD            @ Limpa o bit UART_DLAB para setar os endereços como recebimento e envio de dados 
    STR     R0,     [R9, #UART_LCR]          @ Salva alterações

    LDR     R0,     [R9, #UART_HALT]         @ Carrega conteudo do registrador
    BIC     R0,     #UART_CHCFG_AT_BUSY      @ Desabilitando alteração na setagem de baud rate e configurações do LCR
    STR     R0,     [R9, #UART_HALT]         @ Salva alterações

    LDR     R0,     [R9, #UART_FCR]          @ Carrega conteudo do registrador 
    ORR     R0,     #UART_FIFOE              @ Habilita FIFOs
    STR     R0,     [R9, #UART_FCR]          @ Salva alterações

    POP     {R0, PC}
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Enviando byte pela UART                               ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R0 - Byte a ser enviado pelo TX; R9 - endereço base da UART 3
@ Sem Retorno

TX_UART:

    STR     R0,     [R9, #UART_THR]      @ Colocando byte no FIFO para enviar na UART
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                           Recebendo byte pela UART                               ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R9 - endereço base da UART 3
@ Retorno: R0 - Byte lido pelo RX

RX_UART:
 
    LDR     R0,     [R9, #UART_RBR]      @ Lendo byte da UART, armazenado no FIFO
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                       Checando se o FIFO do RX está vazio                        ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R9 - endereço base da UART 3
@ Retorno: R0 - Retorna se o FIFO do RX está vazio ou não. Se R0 for 0, o FIFO está vazio, se for 1, não está

CHECK_EMPTY_RX_UART:

    PUSH    {LR}

    LDR     R0,     [R9, #UART_USR]     @ Carrega conteudo do registrador
    AND     R0,     #UART_RFNE          @ Isolando bit que indica se o FIFO do RX está vazio ou não
    LSR     R0,     #3                  @ Desloca o bit para o LSB
    
    POP     {PC}
    BX      LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

.data 

CCUaddr:	.word 0x01C20      @ Endereço base da CCU dividido por 4096
base_uart:	.word 0x01C28      @ Endereço base da UART 3 dividido por 4096
