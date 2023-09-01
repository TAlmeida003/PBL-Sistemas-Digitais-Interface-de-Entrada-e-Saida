module DHT11_teste (

    input clk_50MHz,      	   // Sinal de clock de 50 MHz
    input rst,              	// Sinal de reset
    inout dht_data,        	// Pino de dados
    output [39:0] data_out,   // Dados coletados
    output error,           	// Sinal que indica a ocorrência de erro na transmissão de dados
    output reg done           // Sinaliza quando a letura termina
    );

    
    reg dir;                            	// Usado para alterar o sentido do pino de entrada e saída do DHT11
    reg dht_out;                        	// Dado enviado da FPGA para o DHT11
    reg error_reg;  	                     // Registradores de erro
    reg [25:0] counter;                 	// Contador para as divisões de clock
    reg [5:0] index;                    	// Usado para indexação dos dados no barramento     
    reg [39:0] data;                    	// Barramento que armazena os dados retornados do DHT11
    wire dht_in;                        	// Dado enviado do DHT11 para a FPGA        	 
    
    // Conectando os registradores com as saída
    assign error = error_reg;

    // Módulo para alterar o pino de ligação com o DHT11 para o modo de envio ou leitura.
    TRI_State TRIS0 (
   	 .port( dht_data),
   	 .dir( dir),
   	 .send( dht_out),
   	 .read( dht_in)
   	 );
   	 
    assign data_out = data;
    
    // Registradora com os estados
    reg [3:0] state;
    
    // Estados do circuito
    parameter S0 = 1, S1 = 2, S2 = 3, S3 = 4, S4 = 5, S5 = 6,
   			  S6 = 7, S7 = 8, S8 = 9, S9 = 10, STOP = 0, START = 11;
    
    // Lógica da FSM (Finite State Machine)
    always @( posedge clk_50MHz)
   	 
   	 // Iniciando máquina de estados
   	 begin: FSM
   				 
   				 // Verificando o reset
   				 if ( rst == 1'b1)
   					 
   					 begin
   				
   						 done <= 1'b0;
   						 dht_out <= 1'b1;	// Manda o sinal para que DHT11 fique pronto para operar
   						 counter <= 26'b00000000000000000000000000;
   						 data <= 40'b0000000000000000000000000000000000000000;
   						 dir <= 1'b1;   	// Configurando a transmissão como uma saída (FPGA -> DHT11)
   						 error_reg <= 1'b0;
   						 state <= START;	// Mudando de estado
   						 
   					 end
   					 
   				 else begin
   			 
   					 case (state)
   					 
   						 // Inicialização da máquina de estados
   						 START:
   						 
   							 begin
   							 
   								 dir <= 1'b1;   	// Configurando a transmissão como uma saída (FPGA -> DHT11)
   								 dht_out <= 1'b1;   // Manda o sinal para que DHT11 fique pronto para operar
   								 state <= S0;   	// Mudando de estado
   								 
   							 end
   						 
   						 // Estado de preparação do start bit.
   						 // Mantém nível lógico alto por 18 ms.
   						 S0:
   						 
   							 begin
   							 
   								 dir <= 1'b1;   	// Configurando a transmissão como uma saída (FPGA -> DHT11)
   								 dht_out <= 1'b1;   // É mantido em nível lógico alto
   								 error_reg <= 1'b0;
   								 
   								 if (counter >= 900000) begin  	// É preciso aguardar um tempo de 18 ms
   									 
										 counter <= 26'b00000000000000000000000000;
   									 state <= S1;
										 
									 end
   								 
   								 else begin    	
   									 
   									 counter <= counter + 1'b1;
										 state <= S0;
   									 
   								 end
   								 
   							 end
   						 
   						 // Manda o start bit para o sensor.
   						 // Manda nível lógico baixo por 18 ms.
   						 S1:
   						 
   							 begin
								 
   								 dht_out <= 1'b0;   // Bit de start
   								 
   								 if (counter >= 900000) begin  	// É preciso aguardar um tempo de 18 ms
   									 
										 counter <= 26'b00000000000000000000000000;
   									 state <= S2;
										 
									 end
   								 
   								 else begin      
   									 
   									 counter <= counter + 1'b1;
										 state <= S1;
   									 
   								 end
   								 
   							 end
   						 
   						 // Manda-se novamente nível lógico alto.
   						 // Permanecendo nesse estado por 20 us (a resposta do DHT11 deve ocorrer entre 20 a 40 us).
   						 S2:
   						 
   							 begin
								 
   								 dht_out <= 1'b1;
   								 
   								 if ( counter >= 1000) begin
									 
										 dir <= 1'b0;	// Muda a direção do pino para receber dados do DHT11 (DHT11 -> FPGA)
   									 state <= S3;
										
									 end
   								 
   								 else begin
   								 
   									 counter <= counter + 1'b1;
										 state <= S2;
   								 
   								 end
   							 
   							 end
   						 
   						 // Aguarda o dht11 enviar nível lógico baixo.
   						 // indicando que o DHT11 está sincronizando. O tempo de espera é de 60 us.
   						 S3:
   						 
   							 begin
   								 
   								 if ( dht_in == 1'b0) begin
   									 
   										 counter <= 26'b00000000000000000000000000;
   										 state <= S4;
   										 
   								 end
   									 
   								 else if ( counter >= 3000) begin 	
										 
										    error_reg <= 1'b1; 	// Ocorreu um erro
   									    counter <= 26'b00000000000000000000000000;
   										 state <= STOP;
										 
								    end
										 
									 else begin
										 
											 counter <= counter + 1'b1;
											 state <= S3;
										 
									 end
   				 								 
   							 end
   						 
   						 // Estado responsável por continuar detectando o pulso de sincronismo do DHT11.
   						 // O DHT11 deve enviar nível lógico alto antes do tempo limite de 88 us.
   						 S4:
   						 
   							 begin
   							 
   								 if ( dht_in == 1'b1) begin   	// O DHT11 ainda não enviou nível lógico alto
   									 
   									 counter <= 26'b00000000000000000000000000;
   									 state <= S5;
   									 
   								 end
   								 
   								 else if (counter >= 4400) begin
										 
										 error_reg <= 1'b1; 	// Ocorreu um erro
   									 counter <= 26'b00000000000000000000000000;
   									 state <= STOP;
										 
								    end
										 
									 else begin
										 
										 counter <= counter + 1'b1;
										 state <= S4;
										 
									 end
   								 
   							 end
   						 
   						 // Estado responsável por fazer a última checagem do processo de sincronismo com o DHT11.
   						 // O DHT11 deve enviar nível lógico baixo antes do tempo limite de 88 us.
   						 S5:
   						 
   							 begin
   							 
   								 if ( dht_in == 1'b0) begin   	
   								 
										 state <= S6;
   									 error_reg <= 1'b0;
   									 index <= 6'b000000;   	// Reseta o indexador
   									 counter <= 26'b00000000000000000000000000;
   								 
   								 end
   								 
   								 else if (counter >= 4400) begin
										 
										 error_reg <= 1'b1; 	// Ocorreu um erro
   									 counter <= 26'b00000000000000000000000000;
   									 state <= STOP;
										 
									 end
										 
									 else begin
										 
										 counter <= counter + 1'b1;
										 state <= S5;
										 
									 end
   								 
   							 end
   							 
   						 // Inicio da leitura de dados ---------------------------- Será que da pra tirar
   						 S6:
   							 
   							 begin
   								 
   								 if ( dht_in == 1'b0) begin	// Sinal realmente está em 0
   								 
   									 state <= S7;
   								 
   								 end
   									 
   								 else begin
   									 
   									 error_reg <= 1'b1;  	// Sinal de erro
   									 counter <= 26'b00000000000000000000000000;
   									 state <= STOP;
   									 
   								 end
   								 
   							 end
   							 
   						 // Aguarda o nível lógico alto, que representa o bit de dado.
   						 S7:
   							 
   							 begin
   								 
   								 if ( dht_in == 1'b1) begin	// Está tudo ok
   									 
   									 counter <= 26'b00000000000000000000000001;
   									 state <= S8;
   								 
   								 end
   									 
   								 else if ( counter >= 1600000) begin   // Tempo de 32 ms para o DHT11 responder
   										 
										 counter <= 26'b00000000000000000000000000;
   									 error_reg <= 1'b1;     	// Sinal de erro
   									 state <= STOP;	 
   										 
   								 end
   										 
   								 else begin 	
   										 
   									 counter <= counter + 1'b1;
   									 state <= S7;
   										 
   								 end
   								 
   							 end
   							 
   						 // Estado de leitura dos pulsos.
   						 // O nível baixo e alto é determinado pela largura do pulso de nível
   						 // lógico alto enviado.
   						 S8:
   							 
   							 begin
   								 
   								 if ( dht_in == 1'b0) begin 	// Terminou de medir o nível lógico alto.
   									 
   									 // A largura do pulso de nível lógico alto foi lida corretamente
   										 
   									 if ( counter > 2500) begin  // Contador é maior que 50 us, então é nível lógico alto
   										 
   										 data[index] <= 1'b1; 	// Armazena o dado no barramento de 40 bits
   										 
   									 end
   										 
   									 else begin              	// Contador é menor que 50 us, então é nível lógico baixo
   										 
   										 data[index] <= 1'b0; 	// Armazena o dado no barramento de 40 bits
   										 
   									 end
   										 
   									 if ( index < 39) begin    	// Ainda não acabou a leitura de todos os bits
   										 
   										 counter <= 26'b00000000000000000000000000;
   										 state <= S9;
   										 
   									 end
   										 
   									 else begin       	// Todos os bits foram lidos, o estado vai para o de STOP
   										 
   										 error_reg <= 1'b0;    
   										 state <= STOP;
   										 
   									 end
   									 
   								 end
									 
									 else if (counter >= 1600000) begin       // Tempo limite de 32 ms 
									 
											 error_reg <= 1'b1;     	// Sinal de erro
   										 state <= STOP;
									 
									 end
   									 
   								 else begin   // É contabilizada a largura do pulso de nível lógico alto
   									 
   									 counter <= counter + 1'b1;
   									 state <= S8;
   									 
   								 end
   								 
   							 end
   							 
   						 // O index é incrementado em um estado separado para ter certeza que o registrador
   						 // terá tempo de se estabilizar.
   						 // O circuito volta para o S6 e o processo ocorre novamente para cada bit.
   						 S9:
   							 
   							 begin
   								 
   								 index <= index + 1'b1;
   								 state <= S6;
   								 
   							 end
   								 
   						 STOP:
   							 
   							 begin
   							 
   								 done <= 1'b1;
   								 
   								 state <= STOP;
   									 
   								 if ( error_reg <= 1'b0) begin  	// Não ocorreu nenhum erro
   									 
   									 dht_out <= 1'b1;
   									 counter <= 26'b00000000000000000000000000;
   									 dir <= 1'b1;           	// Configurando conexão com o DHT11 como transmissão (FPGA -> DHT11)
   									 error_reg <= 1'b0;         	// Erro é resetado
   									 index <= 6'b000000;
   									 
   								 end
   									 
   								 else begin  	// Se ocorreu erro
   									 
   									 data <= 40'b1111111111111111111111111111111111111111;
   									 
   								 end
   								 
   							 end
   	 
   					 endcase
    
   			 end  	 
   		 
   	 end    

endmodule
