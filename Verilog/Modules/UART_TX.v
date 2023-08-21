module UART_TX #(
    parameter CLKS_PER_BIT = 5208      // 50000000)/(9600) = 5208
) (
    input        clk,                  // CLOCK NÁTIVO DA PLACA
    input  		  initial_data,         // CONTROLER PARA AVISAR QUE DADOS ESTÃO SENDO MANDADOS
    input  [7:0] data_transmission,    // CONTEÚDO HÁ SER MANDADO 
    output reg   tx_active,            // OS DADOS ESTÃO SENDO ENVIADOS 
    output reg   out_tx,               // DADOS ENVIADOS
    output reg   done                  // FOI TUDO ENVIDADO
);

	/*ESTADOS DA MAQUINA DE ESTADOS DA UART*/
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;
    
	 /*REGISTRADORES*/
    reg [1:0]  state = 0;
    reg [12:0] counter = 0;
    reg [2:0]  bit_index = 0;
    reg [7:0]  data_bit = 0;

	 /*TRANSIÇÃO DE ESTADOS*/
    always @(posedge clk) begin
        case (state)
		  
            IDLE: begin
                out_tx    = 1;
                done      = 0;
                counter   = 0;
                bit_index = 0;

                if (initial_data == 1) begin        // AVISO QUE DADOS DEVEM SER MANDADOS 
                    tx_active <= 1;
                    data_bit  <= data_transmission;
                    state <= START;
                end
                else begin
                    state <= IDLE;
					 end
            end 
				
            START: begin
                tx_active <= 1;
                out_tx <= 0;
				done <= 0;
				bit_index = 0;
					 
					 
					 
                if (counter < CLKS_PER_BIT - 1) begin  // ESPERA O BOUND RATE
                    counter <= counter + 13'b1;
                    state <= START;
                end
                else begin                             // O BIT DE START ACABOU 
                    counter <= 0;
                    state <= DATA;
                end
            end
				
            DATA: begin
                tx_active <= 1;
					 done <= 0;
                out_tx <= data_bit[bit_index];        // MANDAR O BIT ATUAL   
					 
                if (counter < CLKS_PER_BIT - 1) begin  // BOUND RATE
						  counter <= counter + 13'b1;
                    state <= DATA;
                end
                else begin
                    counter <= 13'd0;
                    if (bit_index >= 7) begin     // MANDOU O ÚLTIMO BIT      
                        bit_index <= 0;
                        state <= STOP;
                    end
                    else begin                          // FALTA O RESTANTE DOS BITS
                        bit_index <= bit_index + 1'b1;   
								state <= DATA;
                    end
                end
            end
				
            STOP: begin
                out_tx <= 1;
					 bit_index = 0;
					 
                if (counter < CLKS_PER_BIT - 1) begin
						  counter <= counter + 13'b1;
                    state <= STOP;
                end
                else begin
                    done <= 1;
                    state <= IDLE;
                    tx_active <= 0;
						  counter <= 0;
                end
            end
            default: begin 
					 state <= IDLE;
					 out_tx = 1;
                done = 0;
                counter = 0;
                bit_index = 0;
				end
        endcase
    end
    
endmodule