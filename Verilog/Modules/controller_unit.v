/* MODULO REFERENTE A MAQUINA DE ESTADOS
	- ESTE MODULO REPRESENTA UMA MAQUINA DE ESTADOS QUE MANIPULA O SISTEMA GERAL, CONTROLANDO O SENSOR E O GERENCIAMENTO DOS DADOS.
*/
module controller_unit(input clock,					// CLOCK NATIVO DA PLACA DE 50 MHz
					 input new_data, 				// NOVO PACOTE DE DADOS RECEBIDO
					 input [7:0] next_command,	// REQUISICAO RECEBIDA
					 input [7:0] next_address,	// ENDERECO RECEBIDO DO SENSOR
					 input [39:0] data_sensor, // INFORMACOES DO SENSOR
					 output [15:0] buffer_tx,	// NOVO PACOTE A SER ENVIADO
					 output reg send_data_tx,	// SINAL DO PACOTE A SER ENVIADO PARA O TX
					 output reg inout_sensor,	// INICIALIZACAO DO SENSOR
					 output reg rest_uart_rx   // RESETA A ENTRADA DE DADOS
);
		
		
//================================================================================================================================
//                   					 DECLARACAO DOS ESTADOS
//================================================================================================================================
 
	localparam IDLE            = 3'b000,    // ESTADO DE ESPERA
			   READ_DATA         = 3'b001,    // ESTADO DE INTERPRETACAO DOS DADOS
			   CONTROLLER_SENSOR = 3'b010,    // ESTADO DE CONTROLE DO SENSOR
			   PROCESS_DATA      = 3'b011,    // ESTADO DE PROCESSAMENTO DOS DADOS
			   SEND_DATA         = 3'b100,    // ESTADO DE ENVIO DAS INFORMACOES 
			   INCORRECT_DATA    = 3'b101;	 // ESTADO DE PROCESSAMENTO DOS DADOS INVALIDOS
		
		
//================================================================================================================================
//                   				 DECLARACAO DOS REGISTRADORES
//================================================================================================================================
		
	reg [2:0] state = 0;							 // ARMAZENA O ESTADO ATUAL
	reg [27:0] cont = 0;							 // CONTADOR PARA A LEITURA DOS DADOS DO SENSOR
	reg crt_decoder, 								 // ENABLE DE DECODIFICACAO PARA CASOS REGULARES
		 loop = 0;									 // AVISO REFERENTE AO SENSORIAMENTO CONTINUO
	reg [7:0] exe_command = 0;					 // ARMAZENA O COMANDO EM EXECUCAO
	reg [7:0] exe_address = 0;					 // ARMAZENA O ENDERECO EM EXECUCAO
	reg command_invalid = 0;					 // ENABLE DE DECODIFICACAO PARA OS CASOS IRREGULARES
	reg [39:0] reg_data_sensor = 0;			 // ARMAZENA OS DADOS DO SENSOR (nao perde-os quando reinicia)

//================================================================================================================================
//                   		 DECLARACAO DO MODULO DA TABELA DE COMANDOS
//================================================================================================================================
	
	
	/* CHAMADA DO MODULO COMMANDS_TABLE
		- INSTANCIA O MODULO PARA O PROCESSAMENTO DOS COMANDOS E GERACAO DE SAIDAS ADEQUADAS, ARMAZENANDO O RESULTADO EM BUFFER_TX.
	*/
	commands_table responseCommand(exe_command, next_command, crt_decoder, reg_data_sensor, command_invalid, next_address, exe_address, buffer_tx);
	
	
	/* DETECCAO DO MODO DE LOOP 
		- VERIFICA SE O SINAL DE SEND_DATA_TX TEVE UMA TRANSIÇÃO DE NÍVEL POSITIVO.
	*/
	always @ (posedge send_data_tx) begin
		// INDICACAO DO MODO DE LOOP, SE O COMANDO EM EXECUCAO SEJA DE SENSORIAMENTO CONTINUO
		if ((exe_command == 4 || exe_command == 5)) begin
			loop <= 1;
		end
		
		// INDICACAO DO MODO NAO LOOP, CASO CONTRARIO
		else begin
			loop <= 0;
		end	
		
	end
	
	
	/* ARMAZENAMENTO DO COMANDO ATUAL 
		- VERIFICA A BORDA DE SUBIDA DO SINAL DE CLOCK.
	*/
	always @(posedge clock) begin 
		// SE ESTIVER EM SENSORIAMENTO CONTINUO E O ENDERECO EM EXECUCAO SEJA IGUAL AO NOVO RECEBIDO, ATUALIZA APENAS O COMANDO EM EXECUCAO
		if (loop) begin 
			if (((exe_command == 4 && next_command == 6) || (exe_command == 5 && next_command == 7)) && exe_address == next_address && next_command != 0 && new_data) begin
				exe_command <= next_command;
			end
		end
		
		// CASO CONTRARIO, ATUALIZA O ENDERECO E COMANDO EM EXECUCAO
		else begin
			exe_address <= next_address;
			exe_command <= next_command;
		end
			
	end
		
		
//================================================================================================================================
//                   		MAQUINA DE ESTADOS
//================================================================================================================================

	always @(posedge clock) begin 
			case (state)

				/* ESTADO IDLE: AGUARDO POR UM NOVO PACOTE DE DADOS */
				IDLE: begin

					// SAIDAS EM IDLE
					send_data_tx <= 0;		// DESATIVA O ENVIO DO PACOTE	
					crt_decoder <= 0;			// DESATIVA O DECODIFICADOR
					inout_sensor <= 0;		// DESATIVA O SENSOR
					command_invalid <= 0;	// DESATIVA O INDICADOR DE COMANDO INVALIDO	
					rest_uart_rx <= 0;		// DESATIVA O RESET DA ENTRADA DE DADOS

					// TRANSICAO DOS ESTADOS EM IDLE
					if (new_data)
						state <= READ_DATA;	// TRANSICAO PARA READ_DATA, SE CHEGAR UM NOVO PACOTE DE DADOS
						 
					else 
						state <= IDLE;			// PERMANENCIA EM IDLE, CASO CONTRARIO
				
				end
				
				
				/* ESTADO READ_DATA: LEITURA DOS DADOS DO SENSOR E VERIFICACAO DOS COMANDOS */
				READ_DATA: begin
				
					// SAIDAS EM READ_DATA
					send_data_tx <= 0;			
					crt_decoder <= 0;			
					inout_sensor <= 0;		
					command_invalid <= 0;	
					rest_uart_rx <= 0;		
				
					// TRANSICAO DOS ESTADOS EM READ_DATA
					if ((exe_command != 8'd0 && exe_command < 8'd8) && exe_address < 8'd32) begin
						state <= CONTROLLER_SENSOR;	// TRANSICAO PARA CONTROLLER_SENSOR SE O COMANDO EM EXECUCAO ESTIVER CORRETO E O ENDERECO ESTEJA DENTRO DO INTERVALO
						inout_sensor <= 1;				// ATIVA O SENSOR
					end
					
					else begin
						state <= INCORRECT_DATA; 		// TRANSICAO PARA INCORRECT_DATA, CASO CONTRARIO
						command_invalid <= 1;			// ATIVA O INDICADOR DE COMANDO INVALIDO
					end
				
				end
		
		
				/* ESTADO CONTROLLER_SENSOR: CONTROLE DO SENSOR E AGUARDO DOS DADOS */
				CONTROLLER_SENSOR: begin 
				
					// SAIDAS EM CONTROLLER_SENSOR
					send_data_tx = 0;
					crt_decoder = 0;
					command_invalid = 0;
					rest_uart_rx = 0;
					
					// TRANSICAO DOS ESTADOS EM CONTROLLER_SENSOR
					if (cont == 28'd1) begin		// TEMPORIZADOR REFERENTE AO RECEBIMENTO DOS DADOS DO SENSOR
						state <= PROCESS_DATA;				// TRANSITA PARA PROCESS_DATA SE O TEMPO FOR ATINGIDO
						cont <= 0;								// ZERA A CONTADORA
						reg_data_sensor <= data_sensor;	// ARMAZENA OS DADOS RECEBIDOS DO SENSOR
						inout_sensor <= 0;					// DESATIVA O SENSOR
						crt_decoder <= 1;						// ATIVA O DECODIFICADOR	
					end
					
					else begin									// PERMANENCIA EM CONTROLLER_SENSOR ATE A CONTADORA CHEGAR AO SEU LIMITE
						state <= CONTROLLER_SENSOR;
						inout_sensor <= 1;					// PERSISTENCIA DO SENSOR ATIVO
						cont = cont + 28'd1;					// INCREMENTO NA CONTADORA
					end
				
				end			
			
			
				/* ESTADO PROCESS_DATA: PROCESSAMENTO DOS DADOS DO SENSOR E PREPARO PARA ENVIO */
				PROCESS_DATA: begin
				
					// SAIDAS EM PROCESS_DATA
					send_data_tx <= 1;		// ATIVA ENVIO DOS DADOS
					inout_sensor <= 0;		// DESATIVA O SENSOR
					command_invalid <= 0;	// DESATIVA INDICADOR DE COMANDO INVALIDO
					crt_decoder <= 1;			// ATIVA O DECODIFICADOR
					rest_uart_rx <= 0;		// DESATIVA RESET DA ENTRADA DE DADOS
					
					state <= SEND_DATA;		// TRANSICAO PARA O ESTADO SEND_DATA	
				
				end
					
				
				/* ESTADO SEND_DATA: ENVIO DOS DADOS PROCESSADOS */
				SEND_DATA: begin

					// SAIDAS EM SEND_DATA
					inout_sensor <= 0;		// DESATIVA O SENSOR
					send_data_tx <= 1;		// ATIVA O ENVIO DOS DADOS	

					if (loop && next_command != 0 && !new_data) begin
						rest_uart_rx <= 1;	// ATIVA RESET DA ENTRADA DE DADOS CASO ESTEJA EM LOOP E O PROXIMO COMANDO SEJA VALIDO
					end
					
					else begin
						rest_uart_rx <= 0;
						
					end
					
					// TRANSICAO DOS ESTADOS EM SEND_DATA
					if (loop) begin
						state <= READ_DATA;		// TRANSITA DE VOLTA PARA READ_DATA SE ESTIVER EM SENSORIAMENTO CONTINUO
						send_data_tx <= 0;
						command_invalid <= 0;
						crt_decoder <= 0;
					end
						
					else begin
						state <= IDLE;				// TRANSITA DE VOLTA PARA IDLE, CASO CONTRARIO
						send_data_tx <= 0;
						command_invalid <= 0;
						crt_decoder <= 0;
					end	
							
				end
					
					
				/* ESTADO INCORRECT_DATA: TRATAMENTO DOS DADOS INCORRETOS OU COMANDOS INVALIDOS */
				INCORRECT_DATA: begin
				
					// SAIDAS EM INCORRECT_DATA
					send_data_tx <= 1;		// ATIVA O ENVIO DE DADOS
					crt_decoder <= 0;			// DESATIVA O DECODIFICADOR 
					command_invalid <= 1;	// ATIVA O INDICADOR DE COMANDO INVALIDO
					inout_sensor <= 0;		// DESATIVA O SENSOR
					rest_uart_rx <= 0;		// DESATIVA O RESET DA ENTRADA DE DADOS
					
					state <= SEND_DATA;		// TRANSITA DE VOLTA PARA SEND_DATA
					
				end
				
				
				/* ESTADO PADRAO: CASO NENHUM OUTRO ESTADO SEJA CORRESPONDENTE */
				default: state <= IDLE;
			
			endcase

		end
		
endmodule 
