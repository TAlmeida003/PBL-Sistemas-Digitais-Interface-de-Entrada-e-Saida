/* MÓDULO REG_2BYTES_UART_TX
   ESTE MÓDULO IMPLEMENTA A TRANSMISSÃO DE DOIS BYTES VIA UART ASSÍNCRONA.
   ELE ACEITA DOIS BYTES DE DADOS, TRANSMITE-OS SEQUENCIALMENTE E SINALIZA QUANDO A TRANSMISSÃO DOS DOIS BYTES FOI CONCLUÍDA.
 */

module reg_2bytes_UART_tx (
    input clk,               // CLOCK DE ENTRADA
    input enable,            // SINAL DE CONTROLE PARA INICIAR A TRANSMISSÃO
    input [7:0]  byte_one,   // PRIMEIRO BYTE A SER TRANSMITIDO
    input [7:0]  byte_two,   // SEGUNDO BYTE A SER TRANSMITIDO
    input        done_tx,    // SINALIZA QUANDO A TRANSMISSÃO DE UM BYTE FOI CONCLUÍDA
    output [7:0] data,       // BYTE SENDO ATUALMENTE TRANSMITIDO
    output       send        // SINALIZA QUANDO A TRANSMISSÃO DOS DOIS BYTES FOI CONCLUÍDA
);

    /* ESTADOS DA MÁQUINA DE ESTADOS */
    localparam IDLE     = 3'b000,
               SEND_BYTE_ONE = 3'b001,
               STOP_ACK_1   = 3'b010,
               SEND_BYTE_TWO = 3'b011,
               STOP_ACK_2 = 3'b100;

    /* REGISTRADORES INTERNOS */
    reg [2:0] state = 0;          // ESTADO ATUAL DA MÁQUINA DE ESTADOS
    reg [7:0] data_aux = 0;       // DADO ATUAL SENDO TRANSMITIDO
    reg byte_sent = 0;           // INDICA SE UM BYTE FOI TRANSMITIDO
    reg [15:0] buffer = 0;        // BUFFER PARA ARMAZENAR OS BYTES A SEREM TRANSMITIDOS

    assign send = byte_sent;      // SINALIZA QUANDO A TRANSMISSÃO DOS DOIS BYTES FOI CONCLUÍDA
    assign data = data_aux;       // BYTE SENDO ATUALMENTE TRANSMITIDO

   /* TRANSIÇÃO DE ESTADOS */
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                byte_sent <= 0;

                if (enable) begin
                    state <= SEND_BYTE_ONE;              // TRANSIÇÃO PARA O ESTADO DE ENVIO DO PRIMEIRO BYTE
                    data_aux <= buffer[7:0];        // CARREGA O PRIMEIRO BYTE PARA TRANSMISSÃO
                    buffer <= {byte_two, byte_one}; // REARRANJA OS BYTES NO BUFFER PARA TRANSMISSÃO
                end
                else begin
                    state <= IDLE;                // PERMANECE NO ESTADO DE OCIOSIDADE
                    buffer <= 8'd0;               // ZERA O BUFFER
                end
            end
            SEND_BYTE_ONE: begin
                data_aux <= buffer[7:0];         // CARREGA O PRIMEIRO BYTE PARA TRANSMISSÃO
                state <= STOP_ACK_1;              // TRANSIÇÃO PARA O ESTADO DE INÍCIO DA TRANSMISSÃO DO PRIMEIRO BYTE
                byte_sent <= 1;                  // INDICA QUE UM BYTE FOI TRANSMITIDO
            end
            STOP_ACK_1 : begin
                byte_sent <= 0;

                if (done_tx) begin
                    state <= SEND_BYTE_TWO;           // SE O PRIMEIRO BYTE FOI TRANSMITIDO COM SUCESSO, TRANSIÇÃO PARA O ESTADO DE ENVIO DO SEGUNDO BYTE
                end
                else begin
                    state <= STOP_ACK_1;          // PERMANECE NO ESTADO DE INÍCIO DA TRANSMISSÃO DO PRIMEIRO BYTE
                end
            end
            SEND_BYTE_TWO: begin
                byte_sent <= 1;
                data_aux <= buffer[15:8];         // CARREGA O SEGUNDO BYTE PARA TRANSMISSÃO
                state <= STOP_ACK_2;               // TRANSIÇÃO PARA O ESTADO DE INÍCIO DA TRANSMISSÃO DO SEGUNDO BYTE
            end
            STOP_ACK_2 : begin
                byte_sent <= 0;

                if (done_tx) begin
                    state <= IDLE;               // SE O SEGUNDO BYTE FOI TRANSMITIDO COM SUCESSO, TRANSIÇÃO DE VOLTA PARA O ESTADO DE OCIOSIDADE
                end
                else begin
                    state <= STOP_ACK_2;          // PERMANECE NO ESTADO DE INÍCIO DA TRANSMISSÃO DO SEGUNDO BYTE
                end
            end
            default: state <= IDLE;              // CASO DE ESTADO NÃO RECONHECIDO, RETORNA AO ESTADO DE OCIOSIDADE
        endcase
    end


endmodule
