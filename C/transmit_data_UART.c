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
    int len_command;
    int len_address;
    char input[5];
    char aviso[70] = "";
    unsigned char command;
    unsigned char address;
  	unsigned char Data[2];
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
    
    
    void tabela(char aviso[70]){

        printf("\033[1;34m=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\033[1;94m\n");
        printf("                         \033[1;34mENVIAR DADOS\033[0m                        \n");
        printf("\033[1;34m=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\033[1;94m\n");


        printf("+-----------------------------------------------------------+\n");
        printf("|                   Comando de requisicao                   |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| Codigo | Descricao do comando                             |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x00   | Solicita a situacao atual do sensor              |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x01   | Solicita a medida de temperatura atual           |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x02   | Solicita a medida de umidade atual               |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x03   | Ativa o sensoriamento continuo de temperatura    |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x04   | Ativa o sensoriamento continuo de umidade        |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x05   | Desativa o sensoriamento continuo de temperatura |\n");
        printf("+--------+--------------------------------------------------+\n");
        printf("| 0x06   | Desativa o sensoriamento continuo de umidade     |\n");
        printf("+--------+--------------------------------------------------+\n\n\n");
        printf("\033[1;31m%s\033[0m\n\n", aviso);
        
    }

    // geral
    while(1){
        system("clear");
        tabela(aviso);
        fflush(stdin);

        //comando
        int controle_commad = 1;
        while(controle_commad == 1){

            printf("Digite um comando que deseja execultar: ");

            if (fgets(input, sizeof(input), stdin) == NULL){
                system("clear");
                strcpy(aviso,"Erro ao ler entrada. Tente novamente.");
                tabela(aviso);
            }

            if (input[0] == '\n'){
                system("clear");
                strcpy(aviso,"Entrada vazia. Digite um valor hexadecimal valido.");
                tabela(aviso);
            }

            input[strcspn(input, "\n")] = '\0';

            for (int i = 0; input[i]; i++){
                input[i] = toupper(input[i]);
            }

            if ((strlen(input) == 2 || strlen(input) == 4) && input[0] == '0' && input[1] == 'X' && strspn(input + 2, "0123456789ABCDEF") == strlen(input) - 2){
                sscanf(input, "%hhx", &Data[0]);

                if (Data[0] <= 0xFF){
                    strcpy(aviso, " ");
                    controle_commad = 0;
                }
                else{
                    system("clear");
                    strcpy(aviso,"Valor fora do intervalo permitido (0x00 a 0xFF).");
                    tabela(aviso);
                }
            }

            else if(strlen(input) == 2 && strspn(input, "0123456789ABCDEF") == 2){
                sscanf(input, "%hhx", &Data[0]);
                if(Data[0] <= 0xFF) {
                    strcpy(aviso, " ");
                    controle_commad = 0;
                }
                else{
                    system("clear");
                    strcpy(aviso,"Valor fora do intervalo permitido (00 a FF).");    
                    tabela(aviso);
                }
            }

            else {
                system("clear");
                strcpy(aviso,"Entrada invalida. Digite um valor hexadecimal valido.");
                tabela(aviso);
            }

        }
        

        fflush(stdin);
        
        command = Data[0];

        
        //endereco
        int controle_addessn = 1;
        while(controle_addessn == 1){
            
            printf("Digite um endereco que deseja: ");

            if (fgets(input, sizeof(input), stdin) == NULL){
                system("clear");
                strcpy(aviso,"Erro ao ler entrada. Tente novamente.");
                tabela(aviso);
                printf("Digite um comando que deseja execultar: 0x%02X\n", command);
            }

            if (input[0] == '\n'){
                system("clear");
                strcpy(aviso,"Entrada vazia. Digite um valor hexadecimal valido.");
                tabela(aviso);
                printf("Digite um comando que deseja execultar: 0x%02X\n", command);
            }

            input[strcspn(input, "\n")] = '\0';

            for (int i = 0; input[i]; i++){
                input[i] = toupper(input[i]);
            }

            if ((strlen(input) == 2 || strlen(input) == 4) && input[0] == '0' && input[1] == 'X' && strspn(input + 2, "0123456789ABCDEF") == strlen(input) - 2){
                sscanf(input, "%hhx", &Data[1]);

                if (Data[1] <= 0xFF){
                    strcpy(aviso, " ");
                    controle_addessn = 0;
                }
                else{
                    system("clear");
                    strcpy(aviso,"Valor fora do intervalo permitido (0x00 a 0xFF).");
                    tabela(aviso);
                    printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                }
            }

            else if(strlen(input) == 2 && strspn(input, "0123456789ABCDEF") == 2){
                sscanf(input, "%hhx", &Data[1]);
                if(Data[1] <= 0xFF) {
                    strcpy(aviso, " ");
                    controle_addessn = 0;
                }
                else{
                    system("clear");
                    strcpy(aviso,"Valor fora do intervalo permitido (00 a FF).");    
                    tabela(aviso);
                    printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                }
            }

            else {
                system("clear");
                strcpy(aviso,"Entrada invalida. Digite um valor hexadecimal valido.");
                tabela(aviso);
                printf("Digite um comando que deseja execultar: 0x%02X\n", command);
            }
        }

        //compartilhar memoria
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
        /// escrever na memoria
        int *memoria_compartilhada = (int *)shmat(shmid, NULL, 0);
        if (memoria_compartilhada == (int *)(-1)) {
            perror("Erro ao anexar a memória compartilhada");
            exit(1);
        }

        dados_compartilhado = Data[1];
        ////
        *memoria_compartilhada = dados_compartilhado;

        //
        shmdt(memoria_compartilhada);

        
        system("clear");
        tabela(aviso);
        command = Data[0];
        address = Data[1];
        // enviar dados
        len_command = write(fd, &command, sizeof(command));
        len_address = write(fd, &address, sizeof(address));
        
        printf("Enviando dados...\n");
        sleep(1);
        system("clear");
        tabela(aviso);
        printf("\033[1;94mDados enviando.\033[0m\n");
        printf("Comando: %02X\n", command);
        printf("Endereco: %02X\n", address);
        sleep(2);


    }
    

    close(fd);
    return 0;


}