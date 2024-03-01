#include <stdio.h>         // Inclusão da biblioteca padrão de entrada/saída.
#include <string.h>        // Inclusão da biblioteca para manipulação de strings.
#include <unistd.h>        // Inclusão da biblioteca para chamadas de sistema POSIX.
#include <fcntl.h>         // Inclusão da biblioteca para manipulação de descritores de arquivo.
#include <ctype.h>         // Inclusão da biblioteca para funções de manipulação de caracteres.
#include <stdlib.h>        // Inclusão da biblioteca padrão para funções como 'system'.
#include <termios.h>       // Inclusão da biblioteca para configuração do terminal.
#include <sys/ipc.h>       // Inclusão da biblioteca para interprocess communication (IPC).
#include <sys/shm.h>       // Inclusão da biblioteca para gerenciamento de memória compartilhada.


// Função para exibir a tabela de comandos com uma mensagem de aviso.
void schedule(char warning[70]){
    system("clear");       // Limpa a tela do terminal.
    printf("\033[1;34m+===========================================================+\033[1;94m\n");
    printf("|                        ENVIAR DADOS                       |\n");
    printf("\033[1;34m+===========================================================+\033[1;94m\n");
    printf("+-----------------------------------------------------------+\n");
    printf("|                   Comando de requisicao                   |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| Codigo | Descricao do comando                             |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x00   | Desligar terminais                               |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x01   | Solicita a situacao atual do sensor              |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x02   | Solicita a medida de temperatura atual           |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x03   | Solicita a medida de umidade atual               |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x04   | Ativa o sensoriamento continuo de temperatura    |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x05   | Ativa o sensoriamento continuo de umidade        |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x06   | Desativa o sensoriamento continuo de temperatura |\n");
    printf("+--------+--------------------------------------------------+\n");
    printf("| 0x07   | Desativa o sensoriamento continuo de umidade     |\n");
    printf("+--------+--------------------------------------------------+\n\n\n");
    printf("\033[1;31m%s\033[0m\n\n", warning);         // Exibe mensagens de aviso em vermelho.
}

// Função para exibir uma animação de desligamento.
void off (){
    int time = 300000;   // Define o tempo de pausa em microssegundos.
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░");
    printf("\n                   00%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░");
    printf("\n                   05%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░");
    printf("\n                   13%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░");
    printf("\n                   25%%\n");
    usleep(time);
    system("clear"); 
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░");
    printf("\n                   50%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░");
    printf("\n                   75%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░");
    printf("\n                   98%%\n");
    usleep(time);
    system("clear");
    printf("\n\n\n\n\n\n                 Desligando\n");
    printf("▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓");
    printf("\n                   100%%\n");
    usleep(time);
    system("clear");
}

int main(){
    int fd;                                      // Descritor do dispositivo serial.                       
    int temperature_continuous = 0;              // Flag para sensor de temperatura contínuo.
    int humidity_continuous = 0;                 // Flag para sensor de umidade contínuo.
    int len_command;                             // Variável para o tamanho do comando.
    int len_address;                             // Variável para o tamanho do endereço.
    int shared_data;                             // Variável para dados compartilhados entre terminais.
    int on_off = 1;                              // Flag para ligar/desligar o programa.
    int control_command;                         // Variável de controle para o loop responsável pela inserção do comando.
    int control_address;                         // Variável de controle para o loop responsável pela inserção do endereço.
    char input[5];                               // Buffer de entrada para entrada do usuário.
    char warning[70] = "";                       // Mensagem de aviso.
    unsigned char command;                       // Variável para o comando.
    unsigned char address;                       // Variável para o endereço.
    unsigned char continuous_address;            // Variável para endereço em modo contínuo.
  	unsigned char data[2];                       // Array para armazenar dados de comando e endereço.

    struct termios options;                      // Configurações do terminal.
    
    // Abertura do dispositivo serial para comunicação.
    fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
  	    perror("Erro ao abrir porta serial");             // Exibe mensagem de erro em caso de falha na abertura.
  	    return -1;
	}

    // Configuração das opções do terminal para comunicação serial.
    options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
    // Configuração da comunicação serial:
    // - B9600: Baud rate de 9600 bps.
    // - CS8: 8 bits de dados por byte.
    // - CLOCAL: Ignora a detecção do estado do modem.
    // - CREAD: Habilita a recepção de caracteres.
	options.c_iflag = IGNPAR;   // Opção para ignorar erros de paridade na entrada
    options.c_oflag = 0;        // Opções de controle de saída não configuradas.
	options.c_lflag = 0;        // Opções de controle local não configuradas.

    tcflush(fd, TCIFLUSH);                     // Limpa o buffer de entrada.
	tcsetattr(fd, TCSANOW, &options);          // Define as configurações do terminal.
    
    // Loop principal do programa.
    while (on_off == 1){

        key_t key2 = ftok("/tmp", 'B');        // Cria uma chave única para a segunda memória compartilhada.

        if (key2 == -1) {
            perror("Erro ao criar a chave");   // Exibe mensagem de erro se a chave não puder ser criada.
            exit(1);
        }

        int shmid2 = shmget(key2, sizeof(int), IPC_CREAT | 0666);            // Cria ou obtém a segunda memória compartilhada.
        if (shmid2 == -1) {
            perror("Erro ao criar/obter a segunda memória compartilhada");   // Exibe mensagem de erro se a memória não puder ser criada/obtida.
            exit(1);
        }

        int *shared_memory2 = (int *)shmat(shmid2, NULL, 0);            // Anexa a segunda memória compartilhada.
        if (shared_memory2 == (int *)(-1)) {
            perror("Erro ao anexar a segunda memória compartilhada");   // Exibe mensagem de erro se a memória não puder ser anexada.
            exit(1);
        }

        *shared_memory2 = on_off;              // Define o valor da segunda memória compartilhada como on_off.

        schedule(warning);                     // Chama a função para exibir a tabela com uma mensagem de aviso.
        
        control_command = 1;
        while (control_command == 1){   // Loop para validar o comando.
            fflush(stdin);                                         // Limpa o buffer de entrada.
            printf("Digite um comando que deseja executar: ");     // Solicita o comando ao usuário.

            if (fgets(input, sizeof(input), stdin) == NULL){
                strcpy(warning,"Erro ao ler entrada. Tente novamente.");   // Define uma mensagem de erro.
                schedule(warning);
            }
            // Validação: Verifica se a entrada está vazia.
            if (input[0] == '\n'){
                strcpy(warning,"Entrada vazia. Digite um valor hexadecimal valido.");  // Define uma mensagem de erro.
                schedule(warning);
            }

            input[strcspn(input, "\n")] = '\0';      // Remove a quebra de linha.

            for (int i = 0; input[i]; i++){
                input[i] = toupper(input[i]);        // Converte o texto para maiúsculas.
            }
            // Validação: Verifica se a entrada é um valor hexadecimal válido (0x00 a 0xFF).
            if ((strlen(input) == 2 || strlen(input) == 4) && input[0] == '0' && input[1] == 'X' && strspn(input + 2, "0123456789ABCDEF") == strlen(input) - 2){
                sscanf(input, "%hhx", &data[0]);                     // Lê o valor hexadecimal do comando.

                if (data[0] <= 0xFF){
                    strcpy(warning, " ");           // Limpa a mensagem de aviso.
                    control_command = 0;            // Sai do loop.
                }
            
                else{
                    strcpy(warning,"Valor fora do intervalo permitido (0x00 a 0xFF).");         // Define uma mensagem de erro.
                    schedule(warning);
                }
            }

            else if(strlen(input) == 2 && strspn(input, "0123456789ABCDEF") == 2){
                sscanf(input, "%hhx", &data[0]);
                if(data[0] <= 0xFF) {
                    strcpy(warning, " ");
                    control_command = 0;
                }
                else{
                    strcpy(warning,"Valor fora do intervalo permitido (00 a FF).");            // Define uma mensagem de erro.
                    schedule(warning);
                }
            }

            else {
                strcpy(warning,"Entrada invalida. Digite um valor hexadecimal valido.");       // Define uma mensagem de erro.
                schedule(warning);
            }

        }
        
        if (data[0] == 0x00){      // Condição para continuar o programa.
            on_off = 0;
        }
        else{
            on_off = 1;
            command = data[0];

            control_address = 1;
            while (control_address == 1){
                fflush(stdin);

                printf("Digite um endereco que deseja: ");

                if (fgets(input, sizeof(input), stdin) == NULL){
                    strcpy(warning,"Erro ao ler entrada. Tente novamente.");
                    schedule(warning);
                    printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                }
                // Validação: Verifica se a entrada está vazia.
                if (input[0] == '\n'){
                    strcpy(warning,"Entrada vazia. Digite um valor hexadecimal valido.");
                    schedule(warning);
                    printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                }

                input[strcspn(input, "\n")] = '\0';

                for (int i = 0; input[i]; i++){
                    input[i] = toupper(input[i]);
                }
                 // Validação: Verifica se a entrada é um valor hexadecimal válido (0x00 a 0xFF).
                if ((strlen(input) == 2 || strlen(input) == 4) && input[0] == '0' && input[1] == 'X' && strspn(input + 2, "0123456789ABCDEF") == strlen(input) - 2){
                    sscanf(input, "%hhx", &data[1]);

                    if (data[1] <= 0xFF){
                        strcpy(warning, " ");
                        control_address = 0;
                    }
                    else{
                        strcpy(warning,"Valor fora do intervalo permitido (0x00 a 0xFF).");
                        schedule(warning);
                        printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                    }
                }

                else if(strlen(input) == 2 && strspn(input, "0123456789ABCDEF") == 2){
                    sscanf(input, "%hhx", &data[1]);
                    if(data[1] <= 0xFF) {
                        strcpy(warning, " ");
                        control_address = 0;
                    }
                    else{
                        strcpy(warning,"Valor fora do intervalo permitido (00 a FF).");    
                        schedule(warning);
                        printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                    }
                }

                else {
                    strcpy(warning,"Entrada invalida. Digite um valor hexadecimal valido.");
                    schedule(warning);
                    printf("Digite um comando que deseja execultar: 0x%02X\n", command);
                }
            }

            // Conjunto de condicionais desenvolvido para bloquear a variável de endereço enquanto o programa 
            // estiver operando em modo contínuo, a fim de evitar a perda do endereço de execução
            if(data[0] == 0x04 && humidity_continuous == 0 && temperature_continuous == 0){
                temperature_continuous = 1;
                continuous_address = data[1];
            }

            if(data[0] == 0x06 && data[1] == continuous_address && humidity_continuous == 0 && temperature_continuous == 1){
                temperature_continuous = 0;
            }

            if(data[0] == 0x05 && humidity_continuous == 0 && temperature_continuous == 0){
                humidity_continuous = 1;
                continuous_address = data[1];
            }
            if(data[0] == 0x07 && data[1] == continuous_address && humidity_continuous == 1 && temperature_continuous == 0){
                humidity_continuous = 0;
            }
            

            if(humidity_continuous == 0 && temperature_continuous == 0){
                shared_data = data[1];
            }
            else{
                shared_data = continuous_address;
            }
            

            key_t key = ftok("/tmp", 'A');                     // Cria uma chave única para a memória compartilhada.
            if (key == -1) {
                perror("Erro ao criar a chave");               // Exibe mensagem de erro se a chave não puder ser criada.
                exit(1);
            }
            
            int shmid = shmget(key, sizeof(int), IPC_CREAT | 0666);    // Cria ou obtém a memória compartilhada.
            if (shmid == -1) {
                perror("Erro ao criar/obter a memória compartilhada"); // Exibe mensagem de erro se a memória não puder ser criada/obtida.
                exit(1);
            }

            int *shared_memory = (int *)shmat(shmid, NULL, 0);    // Anexa a memória compartilhada.
            if (shared_memory == (int *)(-1)) {
                perror("Erro ao anexar a memória compartilhada"); // Exibe mensagem de erro se a memória não puder ser anexada.
                exit(1);
            }

               
            *shared_memory = shared_data;                         // Define o valor da memória compartilhada como shared_data.                  
            shmdt(shared_memory);                                 // Desanexa a memória compartilhada.


            schedule(warning);                                    // Chama a função para exibir a tabela com uma mensagem de aviso.
            command = data[0];
            address = data[1];

            len_command = write(fd, &command, sizeof(command));   // Escreve o comando no dispositivo serial.
            len_address = write(fd, &address, sizeof(address));   // Escreve o endereço no dispositivo serial.

            printf("Enviando dados...\n");
            sleep(1);
            schedule(warning);
            printf("\033[1;94mDados enviando.\033[0m\n");         // Exibe uma mensagem de confirmação.
            printf("Comando: 0x%02X\n", command);                 // Exibe o comando enviado.
            printf("Endereco: 0x%02X\n", address);                // Exibe o endereço enviado.
            sleep(2);
        }
        

        *shared_memory2 = on_off;          // Define o valor da segunda memória compartilhada como on_off.
        shmdt(shared_memory2);             // Desanexa a segunda memória compartilhada.
    }
    off();          // Chama a função de desligamento.
    close(fd);      // Fecha o dispositivo serial.
    return 0;

}
    