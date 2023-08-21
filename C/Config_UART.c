#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int main() {
	int fd, len;
	unsigned char text = 0x00; /*"unsigned char" declara a variável como um tipo de dado que pode armazenar valores inteiros sem sinal de 8 bits.
    Armazenar valores positivos de 0 a 255.*/
	struct termios options; /* Configurações da porta serial */

    /* Abrir a porta serial /dev/ttyS0 para leitura e escrita. 
    Se não conseguir abrir a porta, exibirá uma mensagem de erro usando a função "perror()"*/
	fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
  	    perror("Error opening serial port");
  	    return -1;
	}

	/* Configuração da porta serial*/

    /*"options.c_cflag" define as configurações de controle da porta,
    como velocidade de transmissão (9600 bps), tamanho dos caracteres (8 bits), ignorar sinal de modem (CLOCAL) e permitir leitura (CREAD).*/
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR; /*options.c_iflag define as opções de entrada (ignorar erros de paridade).*/
    options.c_oflag = 0;
	options.c_lflag = 0;

	/*Aplicar as configurações*/
    
	tcflush(fd, TCIFLUSH); /*"tcflush()" limpa o buffer de entrada*/
	tcsetattr(fd, TCSANOW, &options); /*"tcsetattr()" define as opções da porta serial imediatamente*/

	/*Escreve na porta serial*/

  	text = 0xFF; 
	len = write(fd, &text, sizeof(text));
	printf("Wrote %d bytes over UART\n", len);

	//printf("You have 5s to send me some input data...\n", len);
	sleep(5);

	/* Ler da porta serial */

  	unsigned char receivedData[255];
	memset(receivedData, 0, sizeof(receivedData));
	len = read(fd, receivedData, sizeof(receivedData));
	printf("Received %d bytes\n", len);
	printf("Received string: %d\n", receivedData);
  	for (int i = 0; i < len; i++){
   	    printf("%02x", receivedData[i]);
    }

	close(fd); /* A porta serial é fechado usando a função "close()"*/
	return 0;
}
