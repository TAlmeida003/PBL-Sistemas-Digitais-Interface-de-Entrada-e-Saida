/* MÓDULO UART_RX
   ESTE MÓDULO IMPLEMENTA A RECEPÇÃO UART ASSÍNCRONA.
   ELE RECEBE DADOS DA PORTA SERIAL COM BASE EM UM CLOCK DE 50 MHZ E GERA DADOS DE SAÍDA E SINALIZA QUANDO UM DADO FOI RECEBIDO COMPLETAMENTE.
   PARÂMETROS:
   - CLKS_PER_BIT: PULSOS DE CLOCK POR BIT, CALCULADOS COM BASE NA TAXA DE BAUD. */
module UART_RX #(
    parameter CLKS_PER_BIT = 5208 // 50000000 / 9600 = 5208 PULSOS DE CLOCK POR BIT
)(
    input  clk,         // CLOCK DA PLACA A 50 MHZ
    input  input_rx,    // DADOS RECEBIDOS PELA PORTA SERIAL
    output done,        // SINALIZADO QUANDO UM DADO FOI RECEBIDO COMPLETAMENTE
    output [7:0] out_rx // DADOS DE SAÍDA COMPLETOS
);

    /* ESTADOS DA MÁQUINA DE RECEBIMENTO UART */
    localparam IDLE  = 2'b00, // ESTADO DE OCIOSIDADE
               START = 2'b01, // ESTADO DE INÍCIO DA RECEPÇÃO
               DATA  = 2'b10, // ESTADO DE RECEPÇÃO DE DADOS
               STOP  = 2'b11; // ESTADO DE PARADA DA RECEPÇÃO

    /* REGISTRADORES INTERNOS */
    reg data_serial_buffer = 1'b1; // SINAL DA PORTA SERIAL É ALTO
    reg rx_data            = 1'b1; // DADO RECEBIDO

    reg [1:0]  state       = 1'b0;    // ESTADO DA MÁQUINA
    reg [12:0] counter     = 13'd0;   // CONTADOR DE TEMPO PARA BAUD RATE
    reg [2:0]  bit_index   = 1'b0;    // ÍNDICE DO BIT ATUAL
    reg        data_avail  = 1'b0;    // FLAG PARA SINALIZAR DADO DISPONÍVEL
    reg [7:0]  data_reg    = 1'b0;    // REGISTRADOR PARA ARMAZENAR DADOS RECEBIDOS

    /* SAÍDAS */
    assign out_rx = data_reg; // SAÍDA DOS DADOS RECEBIDOS
    assign done = data_avail; // SINALIZADO QUANDO UM DADO FOI RECEBIDO COMPLETAMENTE

    /* RESOLVER PROBLEMA DE CAPTURA DE SINAL AO MANDAR OS BITS */
    always @(posedge clk) begin
        data_serial_buffer <= input_rx;           // ARMAZENAR SINAL DE ENTRADA
        rx_data            <= data_serial_buffer; // CAPTURAR O DADO
    end

   /* TRANSIÇÃO DE ESTADOS */
    always @(posedge clk) begin
        case (state)
            IDLE:begin
                data_avail <= 0;      // NENHUM DADO DISPONÍVEL NO ESTADO IDLE
                counter    <= 13'd0;  // ZERAR CONTADOR DE TEMPO
                bit_index  <= 3'b000; // ZERAR ÍNDICE DE BIT

                if (rx_data == 0)      // SE O DADO DE ENTRADA FOR BAIXO, INICIA A RECEPÇÃO
                    state <= START;
                else                   // CASO CONTRÁRIO, PERMANECE NO ESTADO IDLE
                    state <= IDLE;     
            end

            START: begin
                data_avail   <= 0;       // NENHUM DADO DISPONÍVEL NO ESTADO START
                bit_index    <= 3'b000;  // ZERAR ÍNDICE DE BIT

                if (counter == (CLKS_PER_BIT - 1) / 2) begin
                    counter <= 13'd0;

                    if (rx_data == 0) begin
                        state <= DATA;    // AINDA ESTÁ NO SINAL DE START, MUDA PARA O ESTADO DATA
                    end
                    else
                        state <= IDLE;     // FORA DO SINAL DE START, BIT DE DADO PERDIDO, VOLTA PARA IDLE
                end
                else begin
                    counter <= counter + 13'b1; // INCREMENTA O CONTADOR DE TEMPO
                    state   <= START;           // CONTINUA NO ESTADO START
                end
            end

            DATA: begin
                data_avail <= 0;              // NENHUM DADO DISPONÍVEL NO ESTADO DATA

                if (counter < CLKS_PER_BIT - 1) begin
                    counter <= counter + 13'b1; // INCREMENTA O CONTADOR DE TEMPO
                    state   <= DATA;            // CONTINUA NO ESTADO DATA
                end
                else begin
                    counter             <= 13'd0;
                    data_reg[bit_index] <= rx_data; // ARMAZENA O DADO RECEBIDO NO REGISTRADOR

                    if (bit_index >= 7) begin
                        bit_index <= 3'b000;
                        state <= STOP;         // TODOS OS BITS DE DADOS FORAM RECEBIDOS, MUDA PARA O ESTADO STOP
                    end
                    else begin
                        bit_index <= bit_index + 3'b1; // INCREMENTA O ÍNDICE DE BIT
                        state <= DATA;                  // CONTINUA NO ESTADO DATA
                    end
                end
            end

            STOP:begin
                data_avail <= 1;               // SINALIZA QUE UM DADO ESTÁ DISPONÍVEL
                bit_index <= 3'b000;           // ZERAR O ÍNDICE DE BIT

                if (counter >= CLKS_PER_BIT - 1) begin
                    counter <= 13'd0;
                    state <= IDLE;             // TEMPO NECESSÁRIO PARA RECEBER O PRÓXIMO DADO, VOLTA PARA IDLE
                end
                else begin
                    counter <= counter + 13'b1; // INCREMENTA O CONTADOR DE TEMPO
                    state <= STOP;              // CONTINUA NO ESTADO STOP
                end
            end

            default: begin
                state <= IDLE;                // CASO DE ESTADO NÃO RECONHECIDO, VOLTA PARA IDLE
                data_avail <= 0;              // NENHUM DADO DISPONÍVEL
                counter    <= 13'd0;          // ZERAR CONTADOR DE TEMPO
                bit_index  <= 0;              // ZERAR ÍNDICE DE BIT
            end
        endcase
    end

endmodule
