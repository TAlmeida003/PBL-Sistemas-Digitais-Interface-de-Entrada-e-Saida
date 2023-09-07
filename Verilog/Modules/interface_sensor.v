module interface_sensor (

	input wire       	clk		 ,     // Clock de 50 MHz
//input wire 		  	start     ,     // Sinal de Start da máquina
	input wire	     	rst_n		 ,     // Sinal de reset
	inout	          	dat_io	 ,     // Pinagem inout do sensor
	output reg [39:0]	data            // Barramento de armazenamento dos dados recebidos pelo sensor

);

	reg        read_flag;     // Determina a direção do pino inout do sensor
	reg        dout;          // Dados enviados para o sensor
	wire       din;           // dados recebidos dos sensor
	
	reg       clk_1MHz;       // Clock de 1 MHz
	reg [5:0] cnt_clk;        // Contadora utilizada para dividir o clock 
	
	reg [5:0]  data_cnt;       // Contadora de quantos bits já foram lidos
	reg [39:0] data_buf;       // Armazenamento dos 40 bits coletados
	reg [15:0] cnt ;           // Contadora usada para cronometrar o tempo nos estados
	reg        rst_1, rst_2, rst_rising;
 //reg       start_f1, start_f2, start_rising;     // Sinais usados para confirmar sinal de start
	
	// Estados do circuito
	reg  [3:0] state;        
	 
	localparam IDLE             = 0;
	localparam START_BIT        = 1;
	localparam SEND_HIGH_20US   = 2;
	localparam WAIT_LOW         = 3;
	localparam WAIT_HIGH        = 4;
	localparam FINAL_SYNC       = 5;
	localparam WAIT_BIT_DATA    = 6;
	localparam READ_DATA        = 7;
	localparam COLLECT_ALL_DATA = 8;
	localparam END_PROCESS      = 9;
	localparam ERROR            = 10;
	
	// Setando a direção do pino inout do sensor
	assign dat_io = read_flag ? 1'bz : dout;       // Se "read_flag" for 0, o pino recebe o valor indicado pelo circuito através do "dout"
	assign din = dat_io;                           // "din"  transmite o sinal recebido do DHT11
	
	// Dividindo o sinal de clock de 50 MHz para 1 MHz
	always @(posedge clk) begin

		if (cnt_clk == 6'd50) begin
	
			cnt_clk = 0;
			clk_1MHz = 1'b1;

		end
		else begin
			
			cnt_clk = cnt_clk + 1'b1;
			clk_1MHz = 1'b0;
		
		end
	
	end

/*
	// Lendo sinal de start
	always@(posedge clk_1MHz, negedge rst_n)
	begin
		if(!rst_n)begin
			start_f1 <=1'b0;
			start_f2 <= 1'b0;
			start_rising<= 1'b0;
		end
		else begin
			start_f1 <= start;
			start_f2 <= start_f1;
			start_rising <= start_f1 & (~start_f2);
		end
	end
*/

	always @ ( posedge clk_1MHz, negedge rst_n) begin
	
		if ( !rst_n) begin
		
			rst_1 <= 1'b0;
			rst_2 <= 1'b0;
			rst_rising <= 1'b0;
			
		end
		
		else begin
		
			rst_1 <= rst_n;
			rst_2 <= rst_1;
			rst_rising <= rst_1 & (~rst_2);
			
		end
		
	end

	// Processo da máquina de estados
	always @ ( posedge clk_1MHz, negedge rst_n) begin
	
		// Resetando valores
		if ( rst_n == 1'b0) begin
		
			read_flag <= 1'b1;
			state <= IDLE;
			dout <= 1'b1;
			data_buf <= 40'd0;
			cnt <= 16'd0;
			data_cnt <= 6'd0;
			data<=40'd0;
			
		end
		
		else begin
		
			case (state)
			
				// Preparando para iniciar o processo de sincronização com o sensor
				IDLE : begin        
				
					 //if(start_rising && din==1'b1)begin
					 
					   if ( rst_rising && din == 1'b1) begin         // O pino do sensor precisa estar em nível lógico alto para depois enviar o start bit
						
							state <= START_BIT;
							read_flag <= 1'b0;           // Seta direção do pino do sensor para FPGA -> DHT11
							dout <= 1'b0;                // Começando o envio do start bit
							cnt <= 16'd0;
							data_cnt <= 6'd0;
							
						end
						
						else begin
						
							read_flag <= 1'b1;
							dout <= 1'b1;
							cnt <= 16'd0;
							
						end	
						
					end
				
				// Envia o start bit para o sensor por 19 ms
				START_BIT : begin      
				
						if ( cnt >= 16'd19000) begin
						
							state <= SEND_HIGH_20US;
							dout <= 1'b1;        // Envia nível lógico alto para o sensor como próximo passo da sincronização
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt<= cnt + 1'b1;
							
						end
						
					end
				
				// Envia nível lógico alto por 20 us para depois esperar a resposta do sensor
				SEND_HIGH_20US : begin           
				
						if ( cnt >= 16'd20)begin
						
							cnt <= 16'd0;
							read_flag <= 1'b1;      // Seta direção do pino do sensor para DHT11 -> FPGA
							state <= WAIT_LOW;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
						end
						
					end
				
				// É esperado que o sensor envie nível lógico baixo antes de atingir o tempo limite	
				WAIT_LOW:begin            
				
						if ( din == 1'b0) begin
						
							state <= WAIT_HIGH;
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin        // Atingiu tempo limite de 65 us e o sensor não respondeu
							
								state <= ERROR;       // Vai para o estado de erro
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				// É esperado que o sensor envie nível lógico alto antes de atingir o tempo limite
				WAIT_HIGH: begin           
				
						if ( din == 1'b1) begin
						
							state <= FINAL_SYNC;
							cnt <= 16'd0;
							data_cnt <= 6'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // Atingiu tempo limite de 65 us e o sensor não respondeu
							
								state <= ERROR;       // Vai para o estado de erro
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end
							
						end
						
					end
				
				// Última etapa de sincronização. É esperado que o sensor envie nível lógico baixo antes de atingir o tempo limite
				FINAL_SYNC : begin          
				
						if ( din == 1'b0) begin           
						
							state <= WAIT_BIT_DATA;
							cnt <= cnt + 1'b1;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							 
							if ( cnt >= 16'd65500) begin       // Atingiu tempo limite de 65 us e o sensor não respondeu
							
								state <= ERROR;      // Vai para o estado de erro
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end			
							
						end
						
					end
				
				// O sensor deve enviar nível lógico alto que vai representar um dos bits de dados antes do tempo limite
				WAIT_BIT_DATA:begin            
				
						if ( din == 1'b1) begin
						
							state <= READ_DATA;
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // Atingiu tempo limite de 65 us e o sensor não respondeu
							
								state <= ERROR;      // Vai para o estado de erro
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				// Cronometra o tempo em nível lógico alto para determinar qual foi o bit enviado
				READ_DATA : begin
				
						if ( din == 1'b0) begin        // Terminou o envio do bit de dado        
						
							data_cnt <= data_cnt + 1'b1;               // Contabilizando quantos bits já foram lidos
							state <= (data_cnt >= 6'd39) ? COLLECT_ALL_DATA : WAIT_BIT_DATA;    // Se todos os bits já foram lidos, vai para COLLECT_ALL_DATA, senão, continua lendo o resto
							cnt <= 16'd0;
							
							if ( cnt >= 16'd60) begin        // Se o tempo em nível lógico alto for maior que 60 us, foi enviado o bit 1
							
								data_buf <= { data_buf[39:0], 1'b1};
								
							end
							
							else begin                       // Se o tempo em nível lógico alto for menor que 60 us, foi enviado o bit 0
							
								data_buf <= { data_buf[39:0], 1'b0};
								
							end
							
						end
						
						else begin         // Contabilizando o tempo em nível lógico alto
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin       // Atingiu tempo limite de 65 us 
							
								state <= ERROR;         // Vai para o estado de erro
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
					end
				
				// Coleta  todos os dados lidos
				COLLECT_ALL_DATA : begin

						data <= data_buf;
						
						if ( din == 1'b1) begin
						
							state <= END_PROCESS;
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin
							
								state <= IDLE;
								cnt <= 16'd0;
								read_flag <= 1'b1;
								
							end
							
						end
						
					end
					
				// Fim de todo o progresso da máquina de estados
				END_PROCESS : begin
				
						state <= IDLE;
						cnt <= 16'd0;
						
					end
				
				// Estado de erro
				ERROR: begin
				
						data <= 40'b1111111111111111111111111111111111111111;    // Todos os bits são colocados em 1 para indicar um erro
						
						if ( din == 1'b1) begin
						
							state <= END_PROCESS;
							cnt <= 16'd0;
							
						end
						
						else begin
						
							cnt <= cnt + 1'b1;
							
							if ( cnt >= 16'd65500) begin
							
								state <= IDLE;
								cnt<=16'd0;
								read_flag <= 1'b1;
								
							end	
							
						end
						
				   end
					
				default : begin
				
						state <= IDLE;
						cnt <= 16'd0;
						
					end	
					
			endcase
			
		end		
		
	end

	
endmodule