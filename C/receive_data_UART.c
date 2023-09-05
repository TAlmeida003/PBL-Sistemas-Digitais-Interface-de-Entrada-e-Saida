#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <ctype.h>
#include <stdlib.h>
///import exclusivo linux/////
#include <termios.h>     //
#include <sys/ipc.h>     //  
#include <sys/shm.h>     //
//////////////////////////////


int main(){
    system("clear");
    /*Variaveis*/
    int fd;
    int len;
    int len_address;
    char input[5];
    char aviso[50] = "";
    unsigned char command;
    unsigned char address;
    int controle = 0;
    unsigned char receivedData[255];
    unsigned char temperatura[32];
    unsigned char umidade[32];
    int temp = 5;
    int segundo = 0;
    int minuto = 0;
    int hora = 0;
    int dados_compartilhado;


    

    struct termios options;
    
    fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
  	    perror("Error opening serial port");
  	    return -1;
	}

    options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
    options.c_oflag = 0;
	options.c_lflag = 0;

    tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);



    for(int i =0; i < 32; i++){
        temperatura[i] = 0x00;
        umidade[i] = 0x00;
    }
    void tabela(unsigned char temperatura[32], unsigned char umidade[32]) {
            system("clear");
            printf("\033[1;34m=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\033[1;94m\n");
            printf("                         \033[1;96mRECEBER DADOS\033[0m                        \n");
            printf("\033[1;34m=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\033[1;94m\n");
            printf("                           -=%02d:%02d:%02d=-\n\n",hora,minuto,segundo);

            printf("+-------------+  +-------------+  +-------------+  +-------------+\n");
            printf("| S   | T | U |  | S   | T | U |  | S   | T | U |  | S   | T | U |\n");
            printf("+-------------+  +-------------+  +-------------+  +-------------+\n");
            printf("|0x00 |%02d |%02d |  |0x08 |%02d |%02d |  |0x10 |%02d |%02d |  |0x18 |%02d |%02d | \n", temperatura[0], umidade[0], temperatura[8], umidade[8], temperatura[16], umidade[16], temperatura[24], umidade[24]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x01 |%02d |%02d |  |0x09 |%02d |%02d |  |0x11 |%02d |%02d |  |0x19 |%02d |%02d | \n", temperatura[1], umidade[1], temperatura[9], umidade[9], temperatura[17], umidade[17], temperatura[25], umidade[25]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x02 |%02d |%02d |  |0x0A |%02d |%02d |  |0x12 |%02d |%02d |  |0x1A |%02d |%02d | \n", temperatura[2], umidade[2], temperatura[10], umidade[10], temperatura[18], umidade[18], temperatura[26], umidade[26]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x03 |%02d |%02d |  |0x0B |%02d |%02d |  |0x13 |%02d |%02d |  |0x1B |%02d |%02d | \n", temperatura[3], umidade[3], temperatura[11], umidade[11], temperatura[19], umidade[19], temperatura[27], umidade[27]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x04 |%02d |%02d |  |0x0C |%02d |%02d |  |0x14 |%02d |%02d |  |0x1C |%02d |%02d | \n", temperatura[4], umidade[4], temperatura[12], umidade[12], temperatura[20], umidade[20], temperatura[28], umidade[28]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x05 |%02d |%02d |  |0x0D |%02d |%02d |  |0x15 |%02d |%02d |  |0x1D |%02d |%02d | \n", temperatura[5], umidade[5], temperatura[13], umidade[13], temperatura[21], umidade[21], temperatura[29], umidade[29]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x06 |%02d |%02d |  |0x0E |%02d |%02d |  |0x16 |%02d |%02d |  |0x1E |%02d |%02d | \n", temperatura[6], umidade[6], temperatura[14], umidade[14], temperatura[22], umidade[22], temperatura[30], umidade[30]);
            printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
            printf("|0x07 |%02d |%02d |  |0x0F |%02d |%02d |  |0x17 |%02d |%02d |  |0x1F |%02d |%02d | \n", temperatura[7], umidade[7], temperatura[15], umidade[15], temperatura[23], umidade[23], temperatura[31], umidade[31]);
            printf("+-------------+  +-------------+  +-------------+  +-------------+\n\n");
            
            printf("+------------------------------+  +------------------------------+\n");
            printf("| Received %d bytes            |  | ", len); //Exibi a quantidade de Bytes recebido
            printf("Received data: ");
            for (int i = 0; i < len; i++){
                printf("0x%02x ", receivedData[i]); //Exibi o hexadecimal recebido
            }
            printf("              |\n");
            printf("+------------------------------+  +------------------------------+\n");

            printf("\n");

    }
    while(1){
        segundo = segundo + temp;
        if(segundo >= 59){
            segundo = 0;
            minuto++;
        }
        if (minuto == 59){
            minuto = 0;
            hora++;
        }
        
        tabela(temperatura, umidade);

	    memset(receivedData, 0, sizeof(receivedData));
	    len = read(fd, receivedData, sizeof(receivedData));


        //cria uma chave
        key_t chave = ftok("/tmp", 'A');
        if (chave == -1) {
            perror("Erro ao criar a chave");
            exit(1);
        }

        /// 
        int shmid = shmget(chave, sizeof(int), IPC_CREAT | 0666);
        if (shmid == -1) {
        perror("Erro ao criar/obter a memória compartilhada");
        exit(1);
        }

       

        // Anexe a memória compartilhada e escreva o valor
        int *memoria_compartilhada = (int *)shmat(shmid, NULL, 0);
        if (memoria_compartilhada == (int *)(-1)) {
            perror("Erro ao anexar a memória compartilhada");
            exit(1);
        }
        dados_compartilhado = *memoria_compartilhada;

        

        //printf("dados c. %d \n", dados_compartilhado);
        //receivedData[0] = 0x08;
        //receivedData[1] = 0x0A;
        switch (receivedData[0])
        {
            case 0x07 :
                printf ("Sensor 0x%02X funcionando normalmente\n",receivedData[1]);
                sleep(temp);
            break;
            
            case 0x08 :
                if (dados_compartilhado <= 31) {
                    umidade[dados_compartilhado] = receivedData[1];
                    tabela(temperatura, umidade);
                    printf ("Sensor: 0x%02x \nMedida da umidade: %02d\n", dados_compartilhado, receivedData[1]);
                    sleep(temp);
                }
                else {
                    printf("Endereco nao encontrado\n");
                    sleep(temp);
                }
            break;
            
            case 0x09 :
                if (dados_compartilhado <= 31) {
                    temperatura[dados_compartilhado] = receivedData[1];
                    tabela(temperatura, umidade);
                    printf ("Sensor: 0x%02x \nMedida da temperatura %02d\n", dados_compartilhado, receivedData[1]);
                    sleep(temp);
                }
                else {
                    printf("Endereco nao encontrado\n");
                    sleep(temp);
                }
            break;
            
            case 0x0A :
                printf ("Sesoriamento continuo de temperatura desativado\n");
                sleep(temp);
            break;
            
            case 0x0B :
                printf ("Sesoriamento continuo de umidade desativado\n");
                sleep(temp);
            break;
            
            case 0x0C :
                printf ("Comando nao existente\n");
                sleep(temp);
            break;
            
            case 0x0D :
                printf ("Endereco de sensor nao existe\n");
                sleep(temp);
            break;

            case 0x0E :
                printf ("A medicao de temperatura ja se encontra nesta situacao\n");
                sleep(temp);
            break;

            case 0x0F :
                printf ("A medicao de umidade ja se encontra nesta situacao\n");
                sleep(temp);
            break;

            case 0x1F :
                printf ("Sensor com problema\n");
                sleep(temp);
            break;
            
            default :
                printf ("Protocolo nao indetificado!\n");
                sleep(temp);
        }
        
            //sleep(10);
            //printf("\nDados recebidos. Pressione Enter para continuar...\n");getchar();


    }

    return 0;
}