/* MODULO REFERENTE A TABELA DE COMANDOS
	- PROCESSA OS COMANDOS RECEBIDOS E GERA AS RESPOSTAS ADEQUADAS, ARMAZENANDO O RESULTADO EM BUFFER_TX.
*/
module commands_table(input [7:0] exe_command,		// COMANDO EM EXECUCAO
							 input [7:0] next_command,		// NOVO COMANDO RECEBIDO
							 input crt_decoder,				// ENABLE DE DECODIFICACAO PARA CASOS REGULARES
							 input [39:0] data_sensor,		// DADOS DO SENSOR
							 input command_invalid,			// ENABLE DE DECODIFICACAO PARA CASOS IRREGULARES
							 input [7:0] next_address,		// NOVO ENDERECO RECEBIDO
							 input [7:0] exe_address,		// ENDERECO EM EXECUCAO
							 output reg [15:0] buffer_tx	// BUFFER DE SAIDA PARA A TRANSMISSAO
);


//================================================================================================================================
//                   					COMANDOS DE REQUISICAO DO USUARIO
//================================================================================================================================
		
	localparam CURRENT_SENSOR_SITUATION      = 8'h1,	// COMANDO PARA OBTER A SITUACAO ATUAL DO SENSOR
              TEMPERATURE_MEASUREMENT       = 8'h2,	// COMANDO PARA A MEDICAO DA TEMPERATURA	
              HUMIDITY_MEASUREMENT          = 8'h3,	// COMANDO PARA A MEDICAO DA UMIDADE
              ACTIVE_CONTINUOS_TEMPERATURE  = 8'h4,	// COMANDO PARA ATIVAR O SENSORIAMENTO CONTINUO DE TEMPERATURA
              ACTIVE_CONTINUOS_HUMIDITY     = 8'h5,	// COMANDO PARA ATIVAR O SENSORIAMENTO CONTINUO DE UMIDADE
              DISABLE_CONTINUOS_TEMPERATURE = 8'h6,	// COMANDO PARA DESATIVAR O SENSORIAMENTO CONTINUO DE TEMPERATURA
              DISABLE_CONTINUOS_HUMIDITY    = 8'h7;	// COMANDO PARA DESATIVAR O SENSORIAMENTO CONTINUO DE UMIDADE

				  
//================================================================================================================================
//                   				    COMANDOS DE RESPOSTA AO USUARIO
//================================================================================================================================
	
	localparam PROBLEM_SENSOR                      = 8'h1F,	// RESPOSTA DE SENSOR COM PROBLEMA
              SENSOR_WORKING                      = 8'h08,	// RESPOSTA DE SENSOR FUNCIONANDO NORMALMENTE
              CURRENT_HUMIDITY_MEASUREMENT        = 8'h09,	// RESPOSTA COM A MEDICAO ATUAL DE UMIDADE
              CURRENT_TEMPERATURE_MEASUREMENT     = 8'h0A,	// RESPOSTA COM A MEDICAO ATUAL DE TEMPERATURA
              TEMPERATURE_CONTINUOUS_DEACTIVATION = 8'h0B,	// RESPOSTA DE DESATIVAMENTO DO SENSORIAMENTO CONTINUO DE TEMPERATURA
              HUMIDITY_CONTINUOUS_DEACTIVATION    = 8'h0C,	// RESPOSTA DE DESATIVAMENTO DO SENSORIAMENTO CONTINUO DE UMIDADE
              VOID                                = 8'hFF,	// RESPOSTA VAZIA
              COMMAND_DOES_NOT_EXIST              = 8'hCF,	// RESPOSTA DE COMANDO NAO EXISTENTE
              ADDRESS_DOES_NOT_EXIST              = 8'hEF,	// RESPOSTA DE ENDERECO NAO EXISTENTE
              INCORRECT_COMMAND                   = 8'hDF,	// RESPOSTA DE COMANDO INCORRETO
              INCORRECT_SENSOR_ADDRESS            = 8'h6F;	// RESPOSTA DE ENDERECO INCORRETO
					
					
	/* SEMPRE QUE HOUVER MUDANCAS EM UMA DAS TRES ENTRADAS */
	always @(exe_command, crt_decoder, data_sensor, command_invalid, next_address, exe_address, next_command) begin
	
		// VERIFICA SE O DECODIFICADOR ESTA ATIVADO
		if (crt_decoder) begin
		
			// DETERMINA A RESPOSTA COM BASE NO COMANDO EM EXECUCAO
			case (exe_command)
			
				/* SITUACAO ATUAL DO SENSOR */
				CURRENT_SENSOR_SITUATION: begin 		
					if (data_sensor == 40'd1099511627775) begin  // SENSOR COM PROBLEMA
						buffer_tx[15:8] <= PROBLEM_SENSOR;
						buffer_tx[7:0] <= VOID;							
					end
					
					else begin 				                      	// SENSOR FUNCIONANDO 			
						buffer_tx[15:8] <= SENSOR_WORKING;
						buffer_tx[7:0] <= VOID;							
					end		
					
				end
			
				/* MEDICAO DA TEMPERATURA */
				TEMPERATURE_MEASUREMENT: begin	
					if (data_sensor == 40'd1099511627775) begin	 // SENSOR COM PROBLEMA							
						buffer_tx[15:8] <= PROBLEM_SENSOR;						
						buffer_tx[7:0]  <= VOID;		
					end					
					
					else begin 		                            	 // TEMPERATURA ATUAL						
						buffer_tx[15:8] <= CURRENT_TEMPERATURE_MEASUREMENT; 
						buffer_tx[7:0] <= data_sensor[23:16];							
					end	
					
				end
				
				/* MEDICAO DA UMIDADE */
				HUMIDITY_MEASUREMENT: begin                                    
					if (data_sensor == 40'd1099511627775) begin	// SENSOR COM PROBLEMA									
						buffer_tx[15:8] <= PROBLEM_SENSOR;
						buffer_tx[7:0] <= VOID;										
					end
								 
					else begin		                          		// UMIDADE ATUAL								
						buffer_tx[15:8] <= CURRENT_HUMIDITY_MEASUREMENT;            
						buffer_tx[7:0] <= data_sensor[39:32];										
					end
									
				end
				
				/* SENSORIAMENTO CONTINUO DE TEMPERATURA ATIVO */
				ACTIVE_CONTINUOS_TEMPERATURE: begin
				
					// CASO DE ERRO: PROXIMO COMANDO DIFERENTE DO DE DESABILITAR O SENSORIAMENTO CONTINUO
					if (next_command != DISABLE_CONTINUOS_TEMPERATURE && next_command != 8'd0 
                        && next_command != ACTIVE_CONTINUOS_TEMPERATURE) begin   
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_TEMPERATURE;
					end
					
					// CASO DE ERRO: PROXIMO COMANDO DIFERENTE DO DE DESABILITAR O CONTINUO MAS COM ENDERECOS IGUAIS
					else if (next_command != DISABLE_CONTINUOS_TEMPERATURE && next_command != 8'd0 
                        && next_command != ACTIVE_CONTINUOS_TEMPERATURE  &&  exe_address == next_address) begin   
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_TEMPERATURE;
					end
					
					// CASO DE ERRO: TENTATIVA DE ATIVAR O SENSORIAMENTO CONTINUO DE OUTRO SENSOR
					else if (next_command != DISABLE_CONTINUOS_TEMPERATURE && next_command != 8'd0 
                        && next_command == ACTIVE_CONTINUOS_TEMPERATURE  &&  exe_address != next_address) begin   
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_TEMPERATURE;
					end
					
					// CASO DE ERRO: ENDERECO DIFERENTE DO EM EXECUCAO
					else if (next_command == DISABLE_CONTINUOS_TEMPERATURE && exe_address != next_address) begin
						buffer_tx[15:8] <= INCORRECT_SENSOR_ADDRESS;                                                
						buffer_tx[7:0] <= exe_address;
					end
					
					// CASO DE ERRO: SENSOR COM PROBLEMA
					else if (data_sensor == 40'd1099511627775) begin  		
						buffer_tx[15:8] <= PROBLEM_SENSOR;
						buffer_tx[7:0] <= VOID;								
					end	
					
					// TEMPERATURA ATUAL
					else begin                                        
						buffer_tx[15:8] <= CURRENT_TEMPERATURE_MEASUREMENT;
						buffer_tx[7:0] <= data_sensor[23:16];
					end
								
				end
				
				/* SENSORIAMENTO CONTINUO DE UMIDADE ATIVO */
				ACTIVE_CONTINUOS_HUMIDITY: begin

					// CASO DE ERRO: PROXIMO COMANDO DIFERENTE DO DE DESABILITAR O SENSORIAMENTO CONTINUO
					if (next_command != DISABLE_CONTINUOS_HUMIDITY && next_command != 8'd0 
                        && next_command != ACTIVE_CONTINUOS_HUMIDITY) begin 
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_HUMIDITY;
					end
					
					// CASO DE ERRO: PROXIMO COMANDO DIFERENTE DO DE DESABILITAR O CONTINUO MAS COM ENDERECOS IGUAIS
					else if (next_command != DISABLE_CONTINUOS_HUMIDITY && next_command != 8'd0 
                        && next_command != ACTIVE_CONTINUOS_HUMIDITY  &&  exe_address == next_address) begin   
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_HUMIDITY;
					end
					
					// CASO DE ERRO: TENTATIVA DE ATIVAR O SENSORIAMENTO CONTINUO DE OUTRO SENSOR
					else if (next_command != DISABLE_CONTINUOS_HUMIDITY && next_command != 8'd0 
                        && next_command == ACTIVE_CONTINUOS_HUMIDITY  &&  exe_address != next_address) begin   
						buffer_tx[15:8] <= INCORRECT_COMMAND;
						buffer_tx[7:0] <= DISABLE_CONTINUOS_HUMIDITY;
					end
					
					// CASO DE ERRO: ENDERECO DIFERENTE DO EM EXECUCAO
					else if (next_command == DISABLE_CONTINUOS_HUMIDITY && exe_address != next_address) begin
						buffer_tx[15:8] <= INCORRECT_SENSOR_ADDRESS;                   	
						buffer_tx[7:0] <= exe_address;
					end
					
					// CASO DE ERRO: SENSOR COM PROBLEMA
					else if (data_sensor == 40'd1099511627775) begin 				
						buffer_tx[15:8] <= PROBLEM_SENSOR;
						buffer_tx[7:0] <= VOID;								
					end
						
					// UMIDADE ATUAL
					else begin 	             				
						buffer_tx[15:8] <= CURRENT_HUMIDITY_MEASUREMENT;
						buffer_tx[7:0] <= data_sensor[39:32];								
					end

				end
					
				/* DESATIVA SENSORIAMENTO CONTINUO DE TEMPERATURA */
				DISABLE_CONTINUOS_TEMPERATURE: begin	
						buffer_tx[15:8] <= TEMPERATURE_CONTINUOUS_DEACTIVATION;
						buffer_tx[7:0] <= VOID;	
				end
				
				/* DESATIVA SENSORIAMENTO CONTINUO DE UMIDADE */
				DISABLE_CONTINUOS_HUMIDITY: begin
						buffer_tx[15:8] <= HUMIDITY_CONTINUOUS_DEACTIVATION;
						buffer_tx[7:0] <= VOID;
				end
			
				/* CASO PADRAO: SE NENHUM OUTRO CASO SEJA CORRESPONDENTE */
				default: begin
                    buffer_tx <= 16'd0;
                end			
			
			endcase
		
		end	
		
		// CASO O NOVO PACOTE TENHA ALGUM DADO INVALIDO
		else if (command_invalid) begin
			
			// COMANDO NAO EXISTENTE
			if (exe_command == 8'd0 || exe_command >= 8'd8)begin // comando invalido
				buffer_tx[15:8] <= COMMAND_DOES_NOT_EXIST;	
				buffer_tx[7:0] <= VOID; 
			end
			
			// ENDERECO NAO EXISTENTE
			else begin
				buffer_tx[15:8] <= ADDRESS_DOES_NOT_EXIST;
				buffer_tx[7:0] <= VOID;
			end
			
		end
		
		else 
			buffer_tx <= 16'd0;				
	end		

endmodule
