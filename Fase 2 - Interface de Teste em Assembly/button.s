@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
@-                            Controlador do botão                                  -
@=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-=-

@ Este código representa uma parte do controlador de botão em linguagem Assembly.
@ A função verificarBotaoPress é responsável por determinar se um botão específico
@ foi pressionado desde a última verificação. O código utiliza os registradores R0
@ e R1 para armazenar o botão escolhido e o estado anterior do botão, respectivamente.

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@;;                             Pegar Click do Botão                                 ;;
@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ Parametro: R0 - Botao escolhido
@            R1 - Estado anterior do botao
@ Retorno:   R0 - Bool informando se o botão foi pressionado 
@            R1 - Estado anterior do botão

verificarBotaoPress: 

    PUSH {LR}                   @ Salva o registrador de link (LR) na pilha

    BL statusInput              @ Chama a sub-rotina statusInput para ler o estado atual do botão

    CMP R0, #0                  @ Compara o valor retornado (estado atual do botão) com zero
    BNE returnFalse             @ Se não for igual a zero, pula para a label returnFalse

    CMP R1, #1                  @ Compara o estado anterior do botão com 1
    BNE returnFalse             @ Se não for igual a 1, pula para a label returnFalse

    MOV R1, R0                  @ Move o valor atual do botão para R1 (estado anterior do botão)
    MOV R0, #1                  @ Move 1 para R0 (indicando que o botão foi pressionado)

    B exitVerificarBotaoPress   @ Pula para a label exitVerificarBotaoPress

returnFalse: 

    MOV R1, R0                  @ Move o valor retornado para R1 (estado anterior do botão)
    MOV R0, #0                  @ Move 0 para R0 (indicando que o botão não foi pressionado)

exitVerificarBotaoPress:

    POP {PC}                    @ Restaura o valor do registrador de link (LR) a partir da pilha
    BX LR                       @ Retorna para a instrução seguinte à chamada da sub-rotina

@_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
