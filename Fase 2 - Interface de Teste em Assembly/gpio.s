@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-            MAPEAMENTO DE MEMÓRIA PARA A ORANGE PI PC PLUS
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Este código Assembly descreve o mapeamento de memória e configuração de pinos GPIO e UART
@ para a Orange Pi PC Plus, um dispositivo de computação de placa única. Ele contém macros e
@ funções que permitem controlar a memória e os pinos GPIO de forma precisa.


@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                                  Constantes                                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.EQU    O_RDWR,                 2           @ Permissão de leitura e escrita para arquivo
.EQU    S_RDWR,                 0666        @ Direitos de acesso de leitura e gravação (RW) 3

.EQU    sys_open,               5           @ Número do serviço Linux para abrir um arquivo
.EQU    sys_mmap2,              192         @ Número do serviço Linux para mapear memória
.EQU    sys_nanosleep,			162         @ Número do serviço Linux para nanosleep

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                                 Temporizador                                     ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro nanoSleep timespecsec
    PUSH {R0,R1,R7}
    ldr     r0,     =\timespecsec       @ Tempo em s
    ldr     r1,     =\timespecsec       @ Tempo em ns
    mov     r7,     #sys_nanosleep
    svc 0
    POP {R0,R1,R7}
.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                         Mapeamento da mémoria                                    ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro MapeamentoDeMemoria

    @Iniciar o acesso a RAM, pedindo permissão ao SO para acessar a memoria
    ldr     R0,     =devMen             @ Carrega o endereço de "/dev/mem" (arquivo de memória)
    mov     R1,     #O_RDWR
    @mov R2, #S_RDWR                    @ No livro usa - permição de gravação e escrita
    mov     R7,     #sys_open           @ Chama o serviço sys_open para abrir o arquivo
    svc 0 
    mov     R4,     R0                  @ Salva o retorno do serviço sys_open em R4

    @ Acessando o endereço onde a memoria está localizada
    ldr     r5,     =gpioaddr           @ endereço GPIO / 4096
    ldr     r5,     [r5]                @ carrega o endereço

    ldr     R1,     =pagelen 
    ldr     R1,     [R1]

    mov     R2,     #3                  @ (PROT_READ + PROT_WRITE) @ opções de proteção de memória
    mov     R3,     #1
    mov     R0,     #0                  @ Deixar o S0 escolher a memoria aleatoria (Memoria virtual)
    mov     R7,     #sys_mmap2          @ Chamar serviço sys_mmap2 para mapear memória
    svc     0

    add     R0,     #0x800              @ Adiciona o deslocamento para encontrar a GPIO
    mov     R8,     R0                  @ Salva o retorno do serviço sys_mmap2 em R8

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                         Configurar pino para output                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro GPIODirectionOut pin 

    @ Para que o pino seja um output é necessario colocar "001" no "offset da função do pino"

    @ACESSANDO O TIPO DO PINO
    LDR     R0,     =\pin        @ carrega o endereco de memoria de ~pin~
	LDR     R1,     [R0, #0] 	 @ offset do registrador de funcao do pino
	LDR     R2,     [R0, #4]	 @ offset do pino no registrador de funcao (LSB)
    LDR     R5,     [R8, R1]     @ conteudo do registrador de dados do pino

    @ LIMPAR O LUGAR ONDE ESTA ARMAZENADO O TIPO DO PINO
    MOV     R0,     #0b111       @ mascara para limpar 3 bits
    LSL     R0,     R2           @ desloca @111 para posicao do pino no registrador
    BIC     R5,     R0           @ limpa os 3 bits da posição

    @COLOCANDO UM PARA REPRESENTAR O VALOR DA SAÍDA
    MOV     R0,     #1           @ move 1 para R0
    LSL     R0,     R2           @ desloca o bit para a posicao de pino no registrador de funcao

    @INSERINDO UM NO LUGAR ONDE ESTA ARMAZENADO O LUGAR DO TIPO DO PINO
    ORR     R5,     R0           @ adiciona o valor 1 na posicao anteriomente deslocada
    STR     R5,     [R8, R1]     @ armazena o novo valor do registrador de funcao na memoria

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                           Configurar pino para input                             ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro GPIODirectionInp pin

    @ Para que o pino seja um input é necessario colocar "000" no "offset da função do pino"

    @ACESSANDO O TIPO DO PINO
    LDR     R0,     =\pin           @ carrega o endereco de memoria de PINO
	LDR     R1,     [R0, #0] 	    @ offset do registrador de funcao do pino
	LDR     R2,     [R0, #4]	    @ offset do pino no registrador de funcao (LSB)
    LDR     R5,     [R8, R1]        @ conteudo do registrador de dados do pino 

    @ LIMPAR O LUGAR ONDE ESTA ARMAZENADO O TIPO DO PINO
    MOV     R0,     #0b111          @ mascara para limpar 3 bits
    LSL     R0,     R2              @ desloca 111 para posicao do pino no registrador

    @INSERINDO ZERO NO LUGAR ONDE ESTA ARMAZENADO O LUGAR DO TIPO DO PINO
    BIC     R5,     R0              @ limpa os 3 bits da posição
    STR     R5,     [R8, R1]        @ armazena o novo valor do registrador de funcao na memoria

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                                Configurar pino UART                              ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro GPIODirectionUART pin

    @ Para que o pino seja um UART3 é necessario colocar "011" no "offset da função do pino"

    @ACESSANDO O TIPO DO PINO
    LDR     R0,     =\pin        @ carrega o endereco de memoria de ~pin~
	LDR     R1,     [R0, #0] 	 @ offset do registrador de funcao do pino
	LDR     R2,     [R0, #4]	 @ offset do pino no registrador de funcao (LSB)
    LDR     R5,     [R8, R1]     @ conteudo do registrador de dados do pino

    @ LIMPAR O LUGAR ONDE ESTA ARMAZENADO O TIPO DO PINO
    MOV     R0,     #0b111       @ mascara para limpar 3 bits
    LSL     R0,     R2           @ desloca @111 para posicao do pino no registrador
    BIC     R5,     R0           @ limpa os 3 bits da posição

    @COLOCANDO UM PARA REPRESENTAR O VALOR DA SAÍDA
    MOV     R0,     #0b011       @ move 3 para R0
    LSL     R0,     R2           @ desloca o bit para a posicao de pino no registrador de funcao

    @INSERINDO UM NO LUGAR ONDE ESTA ARMAZENADO O LUGAR DO TIPO DO PINO
    ORR     R5,     R0           @ adiciona o valor 1 na posicao anteriomente deslocada
    STR     R5,     [R8, R1]     @ armazena o novo valor do registrador de funcao na memoria

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Definir o valor da saída do pino                      ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ R0 - PIN
@ R1 - Valor Lógico
@ SEM RETORNO

stateLogicPin:

    @ Para que o pino tenha valor alto deve-se colocar "1" no "registrador de dados"
    @ Para que o pino tenha valor baixo deve-se colocar "0" no "registrador de dados"

    PUSH {R0-R8}

    @ ACESSAR O LOCAL ONDE ESTÁ ARMAZENADO O VALOR LÓGICO
    LDR     R2,     [R0, #8]     @ offset do pino no registrador de dados
    LDR     R6,     [R0, #12]    @ offset do registrador de dados do pino
    LDR     R5,     [R8, R6]     @ endereço base + offset do registrador de dados

    @ COLOCANDO UM NA POSIÇÃO QUE ESTÁ LOCALIZADO O VALOR LÓGICO
    MOV     R4,     #1           @ move 1 para R4
    LSL     R4,     R2           @ desloca para R4 R2 vezes

    @ VERIFICAR SE O VALOR LÓGICO VAI SER 1 OU 0
    CMP     R1,     #1           @ Verifica se o valor é igual a 1
    ORREQ   R3,     R5,     R4   @ insere 1 na posição anteriormente deslocada

    CMP     R1,     #1           @ Verifica se o valor é igual a 0
    BICNE   R3,     R5,     R4   @ insere 0 na posição anteriormente deslocada

    STR     R3,     [R8, R6]     @ armazena o novo valor no registrador de dados

    POP {R0-R8}
    BX LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                            Pegar o valor lógico atual do pino                    ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ R0 - pin
@ retorno - Valor Logico

statusInput:

    @ Pegar o valor que está no "registrador de dados"

    PUSH {R1-R8}

    @ACESSAR O LOCAL ONDE ESTA ARMAZENADO O VALOR LOGICO
    LDR     R6,     [R0, #12]    @ offset do registrador de dados do pino
	LDR     R2,     [R0, #8]     @ offset do pino no registrador de dados
    LDR     R5,     [R8, R6]     @ endereco base + offset do registrador de dados

    @COLOCANDO UM NA POSIÇAO QUE ESTÁ LOCALIZADO O VALOR LOGICO
    MOV     R4,     #1           @ move 1 para R4
    LSL     R4,     R2           @ desloca para R4 R2 vezes

    @PEGAR O VALOR LOGICO QUE ESTÁ ARMAZENADO NELE
    AND     R5,     R4           @ PEGAR O VALOR ARMAZENADO NO LOCAL
    LSR     R0,     R5,     R2   @ DEVOLVER O BIT PARA O LUGAR DELE

    POP {R1-R8}
    BX LR

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                          Configuração inicial dos pinos                          ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.macro iniciarPin

        @ LEDS - OUTPUT
        GPIODirectionOut    ledBlue
        GPIODirectionOut    ledRed
        
        @ LCD - OUTPUT
        GPIODirectionOut    E
        GPIODirectionOut    RS
        GPIODirectionOut    pinD4
        GPIODirectionOut    pinD5
        GPIODirectionOut    pinD6
        GPIODirectionOut    pinD7

        @ BOTÕES - INPUT
        GPIODirectionInp    button_back
        GPIODirectionInp    button_ok
        GPIODirectionInp    button_next

        @ UART - UART I/O
        GPIODirectionUART uartTx
        GPIODirectionUART uartRx

.endm

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-

