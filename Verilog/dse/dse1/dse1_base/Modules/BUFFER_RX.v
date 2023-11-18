/* MÓDULO REG_2BYTES_UART_RX
   ESTE MÓDULO IMPLEMENTA A RECEPÇÃO DE DOIS BYTES VIA UART ASSÍNCRONA.
   ELE RECEBE DOIS BYTES DE DADOS, ARMAZENA-OS SEQUENCIALMENTE E SINALIZA QUANDO A RECEPÇÃO DOS DOIS BYTES FOI CONCLUÍDA.
   ENTRADAS:
*/

module BUFFER_RX(
    input        clock,       // CLOCK DE ENTRADA
    input        new_data,    // SINAL DE CONTROLE PARA INDICAR A CHEGADA DE NOVOS DADOS
    input  [7:0] data,        // DADO RECEBIDO
    input        reset,       //  SINAL DE RESET PARA REINICIAR O MÓDULO
    output [7:0] out_address, //  PRIMEIRO BYTE RECEBIDO (ENDEREÇO)
    output [7:0] out_command, //  SEGUNDO BYTE RECEBIDO (COMANDO)
    output reg   done         // SINALIZA QUANDO A RECEPÇÃO DOS DOIS BYTES FOI CONCLUÍDA
);

//================================================================================================================================
//                   					 DECLARACAO DOS ESTADOS
//================================================================================================================================

    localparam IDLE_1BYTE  = 2'b00,    // OCIOSIDADE - ESPERANDO O PRIMEIRO BYTE
               ADD_ADDRESS = 2'b01,    // ADIÇÃO DO PRIMEIRO BYTE AO REGISTRADOR
               IDLE_2BYTE  = 2'b10,    // OCIOSIDADE - ESPERANDO O SEGUNDO BYTE
               ADD_COMMAND = 2'b11;    // ADIÇÃO DO SEGUNDO BYTE AO REGISTRADOR

//================================================================================================================================
//                   				 DECLARACAO DOS REGISTRADORES
//================================================================================================================================

    reg  [15:0] registrar = 16'b0;    // REGISTRADOR PARA ARMAZENAR OS DOIS BYTES RECEBIDOS
    reg  [1:0]  state     = 2'b00;    // ESTADO ATUAL DA MÁQUINA DE ESTADOS
    reg  [7:0]  buffer_data = 8'd0;   // BUFFER PARA ARMAZENAR O BYTE RECEBIDO

    assign out_command = registrar[15:8];  // SAÍDA DO SEGUNDO BYTE RECEBIDO
    assign out_address = registrar[7:0];   // SAÍDA DO PRIMEIRO BYTE RECEBIDO

	 
//================================================================================================================================
//                   		MAQUINA DE ESTADOS
//================================================================================================================================

    always @(posedge clock, posedge reset) begin
        if (reset) begin
            registrar <= 16'b0;            // RESETA O REGISTRADOR
            state <= IDLE_1BYTE;           // RETORNA AO ESTADO DE OCIOSIDADE
            done <= 0;                      // REINICIA A FLAG DE CONCLUSÃO
        end
        else begin
            case (state)
                IDLE_1BYTE: begin
                    done <= 0;

                    if (new_data) begin
                        state <= ADD_ADDRESS;      // TRANSIÇÃO PARA O ESTADO DE ADIÇÃO DO PRIMEIRO BYTE
                        buffer_data <= data;       // ARMAZENA O PRIMEIRO BYTE NO BUFFER
                    end
                    else begin
                        state <= IDLE_1BYTE;      // PERMANECE NO ESTADO DE OCIOSIDADE
                    end
                end 
                ADD_ADDRESS: begin
                    done <= 0;
                    registrar[15:8] <= buffer_data; // ARMAZENA O PRIMEIRO BYTE NO REGISTRADOR

                    if (!new_data) begin
                        state <= IDLE_2BYTE;      // TRANSIÇÃO PARA O ESTADO DE OCIOSIDADE ESPERANDO O SEGUNDO BYTE
                    end
                    else begin
                        state <= ADD_ADDRESS;      // PERMANECE NO ESTADO DE ADIÇÃO DO PRIMEIRO BYTE
                    end
                end
                IDLE_2BYTE: begin
                    done <= 0;

                    if (new_data) begin
                        state <= ADD_COMMAND;      // TRANSIÇÃO PARA O ESTADO DE ADIÇÃO DO SEGUNDO BYTE
                        buffer_data <= data;       // ARMAZENA O SEGUNDO BYTE NO BUFFER
                    end
                    else begin
                        state <= IDLE_2BYTE;      // PERMANECE NO ESTADO DE OCIOSIDADE ESPERANDO O SEGUNDO BYTE
                    end
                end
                ADD_COMMAND: begin
               
                    registrar[7:0] <= buffer_data;  // ARMAZENA O SEGUNDO BYTE NO REGISTRADOR

                    if (!new_data) begin
								done <= 1;
                        state <= IDLE_1BYTE;      // TRANSIÇÃO DE VOLTA PARA O ESTADO DE OCIOSIDADE ESPERANDO O PRIMEIRO BYTE
                    end
                    else begin
								done <= 0;
                        state <= ADD_COMMAND;      // PERMANECE NO ESTADO DE ADIÇÃO DO SEGUNDO BYTE
                    end
                end
                default: begin 
                    state <= IDLE_1BYTE;           // CASO DE ESTADO NÃO RECONHECIDO, RETORNA AO ESTADO DE OCIOSIDADE ESPERANDO O PRIMEIRO BYTE
                    registrar <= 16'b0;            // RESETA O REGISTRADOR
                    done <= 0;                      // REINICIA A FLAG DE CONCLUSÃO
                end
            endcase
        end
    end
endmodule
