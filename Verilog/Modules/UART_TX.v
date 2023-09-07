/* MÓDULO UART_TX
   ESTE MÓDULO IMPLEMENTA A TRANSMISSÃO UART ASSÍNCRONA.
   ELE TRANSMITE DADOS PARA A PORTA SERIAL COM BASE EM UM CLOCK NATIVO DA PLACA E GERA DADOS DE SAÍDA E SINALIZA QUANDO A TRANSMISSÃO FOI CONCLUÍDA.
   PARÂMETROS:
   - CLKS_PER_BIT: PULSOS DE CLOCK POR BIT, CALCULADOS COM BASE NA TAXA DE BAUD. */
module UART_TX #(
    parameter CLKS_PER_BIT = 5208 // (50000000 / 9600) = 5208 pulsos de clock por bit
) (
    input        clk,                  // CLOCK NATIVO DA PLACA
    input        initial_data,         // CONTROLADOR PARA AVISAR QUE DADOS ESTÃO SENDO ENVIADOS
    input  [7:0] data_transmission,    // CONTEÚDO A SER ENVIADO
    output reg   out_tx,               // DADOS ENVIADOS
    output reg   done                  // FOI TUDO ENVIADO
);

    /* ESTADOS DA MÁQUINA DE ESTADOS DA UART */
    localparam IDLE  = 2'b00, // ESTADO DE OCIOSIDADE
               START = 2'b01, // ESTADO DE INÍCIO DA TRANSMISSÃO
               DATA  = 2'b10, // ESTADO DE TRANSMISSÃO DE DADOS
               STOP  = 2'b11; // ESTADO DE PARADA DA TRANSMISSÃO

    /* REGISTRADORES INTERNOS */
    reg [1:0]  state = 0;          // ESTADO ATUAL DA MÁQUINA DE ESTADOS
    reg [12:0] counter = 0;        // CONTADOR DE TEMPO PARA BAUD RATE
    reg [2:0]  bit_index = 0;      // ÍNDICE DO BIT ATUAL
    reg [7:0]  data_bit = 0;      // BIT DE DADOS A SER ENVIADO


    /* TRANSIÇÃO DE ESTADOS */
    always @(posedge clk) begin
        case (state)

            IDLE: begin
                out_tx    = 1;            // NÍVEL ALTO NO PINO DE SAÍDA
                done      = 0;            // SINALIZA QUE A TRANSMISSÃO NÃO ESTÁ CONCLUÍDA
                counter   = 0;            // ZERAR O CONTADOR DE TEMPO
                bit_index = 0;            // ZERAR O ÍNDICE DO BIT

                if (initial_data == 1) begin        // AVISO QUE DADOS DEVEM SER ENVIADOS
                   
                    data_bit  <= data_transmission; // CARREGAR O DADO A SER ENVIADO
                    state <= START;               // MUDAR PARA O ESTADO DE INÍCIO DA TRANSMISSÃO
                end
                else begin
                    state <= IDLE;              // PERMANECE NO ESTADO DE OCIOSIDADE
                end
            end

            START: begin
                
                out_tx <= 0;           // NÍVEL BAIXO NO PINO DE SAÍDA (BIT DE START)
                done <= 0;             // SINALIZA QUE A TRANSMISSÃO NÃO ESTÁ CONCLUÍDA
                bit_index = 0;         // ZERAR O ÍNDICE DO BIT

                if (counter < CLKS_PER_BIT - 1) begin  // ESPERAR O BAUD RATE
                    counter <= counter + 13'b1;
                    state <= START;                   // PERMANECE NO ESTADO DE INÍCIO DA TRANSMISSÃO
                end
                else begin                             // O BIT DE START TERMINOU
                    counter <= 0;
                    state <= DATA;                    // MUDAR PARA O ESTADO DE TRANSMISSÃO DE DADOS
                end
            end

            DATA: begin
                
                done <= 0;             // SINALIZA QUE A TRANSMISSÃO NÃO ESTÁ CONCLUÍDA
                out_tx <= data_bit[bit_index];  // ENVIAR O BIT ATUAL

                if (counter < CLKS_PER_BIT - 1) begin  // ESPERAR O BAUD RATE
                    counter <= counter + 13'b1;
                    state <= DATA;                    // PERMANECE NO ESTADO DE TRANSMISSÃO DE DADOS
                end
                else begin
                    counter <= 13'd0;
                    if (bit_index >= 7) begin     // ENVIOU O ÚLTIMO BIT
                        bit_index <= 0;
                        state <= STOP;            // MUDAR PARA O ESTADO DE PARADA DA TRANSMISSÃO
                    end
                    else begin                          // FALTA O RESTANTE DOS BITS
                        bit_index <= bit_index + 1'b1;
                        state <= DATA;                  // PERMANECE NO ESTADO DE TRANSMISSÃO DE DADOS
                    end
                end
            end

            STOP: begin
                out_tx <= 1;          // NÍVEL ALTO NO PINO DE SAÍDA (BIT DE STOP)
                bit_index = 0;        // ZERAR O ÍNDICE DO BIT

                if (counter < CLKS_PER_BIT - 1) begin
                    counter <= counter + 13'b1;
                    state <= STOP;       // PERMANECE NO ESTADO DE PARADA DA TRANSMISSÃO
                end
                else begin
                    done <= 1;          // SINALIZA QUE A TRANSMISSÃO FOI CONCLUÍDA
                    state <= IDLE;      // RETORNA AO ESTADO DE OCIOSIDADE
                   
                    counter <= 0;       // ZERAR O CONTADOR DE TEMPO
                end
            end
            default: begin
                state <= IDLE;                // CASO DE ESTADO NÃO RECONHECIDO, RETORNA AO ESTADO DE OCIOSIDADE
                out_tx = 1;                    // NÍVEL ALTO NO PINO DE SAÍDA
                done = 0;                      // SINALIZA QUE A TRANSMISSÃO NÃO ESTÁ CONCLUÍDA
                counter = 0;                   // ZERAR O CONTADOR DE TEMPO
                bit_index = 0;                 // ZERAR O ÍNDICE DO BIT
                end
        endcase
    end

endmodule
