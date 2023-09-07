/* MÓDULO MAIN
   ESTE MÓDULO REPRESENTA A UNIDADE DE CONTROLE PRINCIPAL DO SISTEMA QUE GERENCIA A COMUNICAÇÃO UART, A INTERFACE DO SENSOR E A TRANSMISSÃO DE DADOS.
   O CÓDIGO ESTÁ DIVIDIDO EM TRÊS BLOCOS PRINCIPAIS: RECEBIMENTO DE DADOS UART, UNIDADE DE CONTROLE E TRANSMISSÃO DE DADOS UART.
*/
module main(
    input  clock_50Mhz, // CLOCK NATIVO DA PLACA DE 50Mhz
    input  uart_rx,     ///PINO DE RECEBIMENTO DE DADOS DA PORTA SERIAL
    inout  sensor_data,      // PINO BIDIRECIONAL DO SENSOR DE TEMPERATURA E UMIDADE
    output uart_tx      // PINO DE TRANFERÊNCIA DE DADOS DA PORTA SERIAL
);
	
//================================================================================================================================
//                    RECEBIMENTO DE DADOS NO PADRÃO UART E ARMAZENAMENTO DO PACOTE DE DADOS DE 2 BYTES
//================================================================================================================================

    // OBS: OS DADOS DEVEM SER RECEBIDOS NA ORDEM: COMANDO + ENDEREÇO
    // OBS: A UART RX ESTÁ CONFIGURADA PARA UMA TAXA DE TRANSMISSÃO DE 96000 bps

    /*FIOS PARA O BLOCO UART RX*/
    wire       received_byte_alert, reset_rx, received_2_Bytes_alert;  //FLAGs DOS BLOCOS UART RX
    wire [7:0] Byte_received, sensor_address, required_command;        // DADOS DE ARMAZENADOS

    /* RECEBIMENTO DE DADOS NO PADRÃO UART, CONVERTENDO UMA ENTRADA SERIAL DE BITS EM UMA SAÍDA PARALELA DE UM BYTE */
    UART_RX  rx(clock_50Mhz, 
                uart_rx, 
                received_byte_alert,  // ALERTAR QUE UM BYTE JÁ FOI RECEBIDO PELO UART E CONVERTIDO EM PARALELO
                Byte_received);       // BYTE ARMAZENADO 

    /* BUFFER PARA ARMAZENAMENTO DOS BYTES ENVIADOS NA UART RX - O LIMITE DO BUFFER É DE 2 BYTES */ 
    reg_2bytes_UART_rx reg_rx(clock_50Mhz,
                              received_byte_alert,       // ESSA FLAG CONTROLA O ARMAZEMENTO DE CADA BYTE NO BUFFER
                              Byte_received,             // DADOS A SEREM ARMAZENADOS NO BUFFER DE 2 BYTES DA UART RX 
                              reset_rx,                  // RESTAURAR OS BITS DO BUFFER PARA 0, QUANDO RESETE FOR 1;
                              sensor_address,            // ENDERÇO RECEBIDO NO PACOTE
                              required_command,          // COMANDO RECEBIDO NO PACOTE
                              received_2_Bytes_alert);   // ALERTAR QUE OS DOIS BYTES JÁ FORAM ARMAZENADOS 

//=================================================================================================================================
 
//================================================================================================================================		
//                                   UNIDADE DE CONTROLE GERAL DO SISTEMA
//================================================================================================================================

    //OBS: TODA VEZ QUE UM NOVO SINAL É ENVIADO O BUFFER DOS DADOS RECEBIDOS É ZERADO

    wire        start_sending_new_package, enable_sensor;   // FLAGs DA UNIDADE DE CONTROLE
    wire [15:0] data_new_package;                           // DADOS QUE SERÃO ENVIADOS 

    MEF_main                exe(clock_50Mhz,              
                                received_2_Bytes_alert,    // ESSA FLAG RETIRA A MÁQUINA DO MODE DE ESPERA
                                required_command,          // COMANDO A SER EXECUTADO NA MÁQUINA
                                sensor_address,            // ENDEREÇO DO SENSOR HÁ SER ANALISADO
                                data_sensor,               // CINDO BYTES ENVIADOS PELO SENSOR
                                data_new_package,          // RESPOSTA DE DOIS BYTE AO COMANDO DEMANDADO
                                start_sending_new_package, // ALERTA PARA ENVIAR INICIAR O ENVIO DA RESPOSTA
                                enable_sensor,             // INICIAR O "DRIVE" DE CONTROLE DO SENSOR
                                reset_rx);                 // FLAG PARA ZERA O O BUFFER DOS DADOS RECEBIDOS

//================================================================================================================================		

//================================================================================================================================		
//                              INTERFACE DE CONTROLE DO SENSOR DE TEMPERATURA E UMIDADE
//================================================================================================================================

    //OBS: A INTERFACE ATUALMENTE ESTÁ COM O "DRIVE" DO DHT11
    //OBS: ATUALMENTE OS 32 ENDEREÇOS ESTÃO LIGADOS AO MESMO SENSOR
    //OBS: ORDEM DOS 5 BYTES DO SENSOR: INTEIRO UMIDADE + DECIMAL UMIDADE + INTEIRO TEMPERATURA + DECIMAL TEMPERATURA + VERIFICAÇÃO

    wire [39:0] data_sensor;               // DADOS DE ARMAZENADOS

    /* COMUNICAÇÃO DE PEDIDO E RECEBIMENTOS DE DADOS COM O SENSOR */
    interface_sensor sensor(clock_50Mhz,
                            enable_sensor, // SINAL PARA COLETAR OS DADOS DO SENSOR
                            sensor_data,        
                            data_sensor);  // TODOS OS 5 BYTES DISPONIBILIZADOS PELO SENSOR

//================================================================================================================================

//================================================================================================================================
//                    TRANSMISSÃO DE DADOS NO PADRÃO UART E ENVIO DO PACOTE DE DADOS DE 2 BYTES
//================================================================================================================================

    // OBS: AO MANDAR UM NOVO PACOTE, CERTIFIQUE-SE QUE OS DADOS JÁ FORAM ARMAZEDOS ANTES DO START
    // OBS: OS DADOS DEVEM SER ENVIADOS NA ORDEM: COMANDO DE RESPOSTA + COMPLEMENTO DO COMANDO

    wire       transfer_byte_alert, start_send_byte;      // FLAGs DOS BLOCOS UART TX
    wire [7:0] data_byte_transfer;                        // DADOS DE ARMAZENADOS

    /* ARMAZENAR O PACOTE DE TRANSMISSÃO DE 2 BYTES E ENVIA UM BYTE POR VEZ A PARTIR DA CONFIRMAÇÃO DE ENVIO DA UART TX */
    reg_2bytes_UART_tx   reg_tx(clock_50Mhz,  
                                start_sending_new_package,    // PULSO PARA INICIAR O ENVIO DO NOVO PACOTE
                                data_new_package[15:8],       // PRIMEIRO BYTE HÁ SER ENVIADO
                                data_new_package[7:0],        // SEGUNDO BYTE HÁ SER ENVIADO
                                transfer_byte_alert,          // RECEBIMENTO DO ALERTA DA UART TX QUE O BYTE JÁ FOI ENVIADO                        
                                data_byte_transfer,           // BYTE QUE SERÁ ENVIADO
                                start_send_byte);             // ALERTA QUE O BYTE JÁ PODE SER ENVIADO

    /* TRANSMISSÃO DE DADOS PADRÃO UART, CONVERTENDO UMA ENTRADA PARALELA DE 1 BYTE EM UMA SAÍDA SERIAL */
    UART_TX              tx(clock_50Mhz,                      
                            start_send_byte,        // PULSO PARA INICIAR O ENVIO DO BYTE
                            data_byte_transfer,     // BYTE QUE SERÁ ENVIADO 
                            uart_tx,                 
                            transfer_byte_alert);   // ALERTA QUE O BYTE FOI ENVIADO
	 
//=================================================================================================================================

endmodule