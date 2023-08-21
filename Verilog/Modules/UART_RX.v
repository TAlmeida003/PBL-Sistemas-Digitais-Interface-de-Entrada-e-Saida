module UART_RX #(
	parameter CLKS_PER_BIT = 5208 // 50000000)/(9600) = 5208
)(
    input  clk, 						// CLOCK NATIVO DA PLACA 50 Mhz
    input  input_rx, 				
    output done,						//O DADO FOI RECEBIDO COMPLETAMENTE
    output [7:0] out_rx          // CONTEÚDO COMPLETO
);

	/*ESTADOS DA RECEIVE UART*/
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;
				
	 /*BLOCO DE REGISTRADORES*/
    reg data_serial_buffer = 1'b1; // SINAL DA PORTA SERIAL É ALTO 
    reg rx_data            = 1'b1; 
     
    reg [1:0]  state       = 1'b0;
    reg [12:0] counter     = 13'd0; // TEMPO PARA MANDAR TODOS OS DADOS - BOUND RATE
    reg [2:0]  bit_index   = 1'b0;  
    reg        data_avail  = 1'b0;
    reg [7:0]  data_reg    = 1'b0;
	
	 /*SAÍDAS*/
    assign out_rx = data_reg;
    assign done = data_avail;

    /*RESOLVER PROBLEMA DE CAPTURA DE SINAL AO MANDAR OS BITS*/
    always @(posedge clk) begin
        data_serial_buffer <= input_rx;
        rx_data            <= data_serial_buffer;
    end
    
    /*TRANSINÇÃO DE ESTADOS*/
    always @(posedge clk) begin
        case (state)

            IDLE:begin 
                data_avail <= 0;
                counter    <= 13'd0;
                bit_index  <= 3'b000;

                if (rx_data == 0)     // INICIO DO BIT DE START
                    state <= START;	  
                else
                    state <= IDLE;
            end 

            START: begin
                data_avail   <= 0;
                bit_index    <= 3'b000;

                if (counter == ( CLKS_PER_BIT - 1) / 2) begin // TROCAR DE ESTADO ANTER DO SINAL DE DATA CHEGAR
						  counter <= 13'd0;
						  
                    if (rx_data == 0) begin  					  // AINDA ESTÁ NO SINAL DE START
                        state <= DATA;
                    end
                    else                                      // ESTÁ FORA DO SINAL DE START, FOI PERDIDO O BIT DE DATA 
								state <= IDLE;
                end
                else begin
                    counter <= counter + 13'b1;               // TEMPO DE RATE BOUND RATE
                    state   <= START;
                end 
            end
				
            DATA: begin
                data_avail <= 0;

                if (counter < CLKS_PER_BIT - 1) begin 		  //  TEMPO DE RATE BOUND RATE - PEGA O MEIO DO BIT
                    counter <= counter + 13'b1;
                    state   <= DATA;
                end
                else begin
                    counter             <= 13'd0;
                    data_reg[bit_index] <= rx_data;          // ADICIONAR O DADO RECEBIDO AO REGISTRADOR

                   if (bit_index >= 7) begin                 // FORAM MANDADOS TODOS OS BITS DE DATA
                        bit_index <= 3'b000;
                        state <= STOP;   
                    end
                    else begin                               // AINDA FALTA CHEGAR OS RESTANTES DOS DADOS
                        bit_index <= bit_index + 3'b1;       // BIT ATUAL HÁ SER RECEBIDO
                        state <= DATA;
                    end
                end
            end

            STOP:begin            
					data_avail <= 1;                    
					bit_index <= 3'b000;							
						
					if (counter >= CLKS_PER_BIT - 1) begin        // TEMPO PARA RECEBER O BIT DE START
						counter <= 13'd0;
						state <= IDLE;
					end
					else begin                                    // ESPERAR O BIT DE START
						counter <= counter + 13'b1;
						state <= STOP;
					end
				end
				
            default: begin
                 state <= IDLE;
					  data_avail <= 0;
                 counter    <= 13'd0;
                 bit_index  <= 0;
            end
        endcase
    end

endmodule 