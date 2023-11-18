#include <stdio.h>              // Inclusão de biblioteca padrão de entrada e saída
#include <string.h>             // Inclusão de biblioteca para manipulação de strings
#include <unistd.h>             // Inclusão de biblioteca para funções de sistema POSIX
#include <fcntl.h>              // Inclusão de biblioteca para controle de arquivos
#include <ctype.h>              // Inclusão de biblioteca para funções de caracteres
#include <stdlib.h>             // Inclusão de biblioteca padrão
#include <termios.h>            // Inclusão de biblioteca para controle de terminal
#include <sys/ipc.h>            // Inclusão de biblioteca para funções IPC (Inter-Process Communication)
#include <sys/shm.h>            // Inclusão de biblioteca para manipulação de memória compartilhada  


// Função para exibir a tabela com as medições de temperatura e umidade.
void schedule (unsigned char temperature[32], unsigned char humidity[32], char warning[200], int hour, int minute, int second,unsigned char receivedData[255], int len){
    system("clear");        // Limpa a tela do terminal
    printf("\033[1;34m+================================================================+\033[1;94m\n");
    printf("|                          RECEBER DADOS                         |\n");
    printf("\033[1;34m+================================================================+\033[1;94m\n");
    printf("                           -=%02d:%02d:%02d=-\n\n",hour,minute,second);
    printf("+-------------+  +-------------+  +-------------+  +-------------+\n");
    printf("| S   | T | U |  | S   | T | U |  | S   | T | U |  | S   | T | U |\n");
    printf("+-------------+  +-------------+  +-------------+  +-------------+\n");
    printf("|0x00 |%02d |%02d |  |0x08 |%02d |%02d |  |0x10 |%02d |%02d |  |0x18 |%02d |%02d | \n", temperature[0], humidity[0], temperature[8], humidity[8], temperature[16], humidity[16], temperature[24], humidity[24]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x01 |%02d |%02d |  |0x09 |%02d |%02d |  |0x11 |%02d |%02d |  |0x19 |%02d |%02d | \n", temperature[1], humidity[1], temperature[9], humidity[9], temperature[17], humidity[17], temperature[25], humidity[25]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x02 |%02d |%02d |  |0x0A |%02d |%02d |  |0x12 |%02d |%02d |  |0x1A |%02d |%02d | \n", temperature[2], humidity[2], temperature[10], humidity[10], temperature[18], humidity[18], temperature[26], humidity[26]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x03 |%02d |%02d |  |0x0B |%02d |%02d |  |0x13 |%02d |%02d |  |0x1B |%02d |%02d | \n", temperature[3], humidity[3], temperature[11], humidity[11], temperature[19], humidity[19], temperature[27], humidity[27]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x04 |%02d |%02d |  |0x0C |%02d |%02d |  |0x14 |%02d |%02d |  |0x1C |%02d |%02d | \n", temperature[4], humidity[4], temperature[12], humidity[12], temperature[20], humidity[20], temperature[28], humidity[28]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x05 |%02d |%02d |  |0x0D |%02d |%02d |  |0x15 |%02d |%02d |  |0x1D |%02d |%02d | \n", temperature[5], humidity[5], temperature[13], humidity[13], temperature[21], humidity[21], temperature[29], humidity[29]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x06 |%02d |%02d |  |0x0E |%02d |%02d |  |0x16 |%02d |%02d |  |0x1E |%02d |%02d | \n", temperature[6], humidity[6], temperature[14], humidity[14], temperature[22], humidity[22], temperature[30], humidity[30]);
    printf("|-------------|  |-------------|  |-------------|  |-------------|\n");
    printf("|0x07 |%02d |%02d |  |0x0F |%02d |%02d |  |0x17 |%02d |%02d |  |0x1F |%02d |%02d | \n", temperature[7], humidity[7], temperature[15], humidity[15], temperature[23], humidity[23], temperature[31], humidity[31]);
    printf("+-------------+  +-------------+  +-------------+  +-------------+\n\n");

    printf("+------------------------------+  +------------------------------+\n");
    printf("  %d bytes recebido                 ", len);        // Imprime a quantidade de bytes recebidos.
    printf("Dados recebidos : ");
    for (int i = 0; i < len; i++){
        printf("0x%02x ", receivedData[i]);                     // Loop para imprimir os bytes recebidos em formato hexadecimal.
    }
    printf("            \n");
    printf("+------------------------------+  +------------------------------+\n");
    printf("\n");
    printf("+----------------------------------------------------------------+\n");
    printf("%s", warning);                  // Imprime informações de aviso ou status armazenadas na variável "warning".
    printf("+----------------------------------------------------------------+\n");
}

// Função para exibir uma animação de desligamento.
void off (){
    int time = 300000;
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

    int fd;                                               // Descritor do dispositivo serial.  
    int len = 0;                                          // Armazenar o comprimento dos dados recebidos
    int time = 1;                                         // definir um intervalo de tempo em segundos
    int second = 0;                                       // Armazenar os segundos do horário atual da execuçao
    int minute = 0;                                       // Armazenar os minutos do horário atual da execuçao
    int hour = 0;                                         // Armazenar as horas do horário atual da execuçao
    int shared_data;                                      // Armazenar dados compartilhados
    int on_off = 1;                                       // controlar o estado ligado/desligado do sistema
    char warning[200] = "  Aguardando atualização...\n";  // String para armazenar mensagens de aviso ou status
    unsigned char receivedData[255];                      // Array para armazenar os dados recebidos da porta serial
    unsigned char temperature[32];                        // Array para armazenar dados de temperatura
    unsigned char humidity[32];                           // Array para armazenar dados de umidade

    
    // inicializando array com valor 0x00
    for(int i =0; i < 32; i++){
        temperature[i] = 0x00;
        humidity[i] = 0x00;
    }

    
    system("clear");
    
    
    struct termios options;                                     // Configurações do terminal.
    // Abertura do dispositivo serial para comunicação.
    fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY);
    if (fd < 0) {
  	    perror("Erro ao abrir porta serial");                  // Exibe mensagem de erro em caso de falha na abertura.
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

    

    
    while (on_off == 1){


        second = second + time; // Incrementa a variável "second" pelo valor de "time".
        if (second >= 60) {     // Se os segundos excederem 59 (um minuto completo)...
            second = 0;         // ... reinicializa os segundos para 0.
            minute++;           // Incrementa a variável "minute" para indicar que passou um minuto.
        }

        if (minute == 60) {     // Se os minutos excederem 59 (uma hora completa)...
            minute = 0;         // ... reinicializa os minutos para 0.
            hour++;             // Incrementa a variável "hour" para indicar que passou uma hora.
        }

        schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);

        // Utiliza a função "memset" para preencher o array "receivedData" com zeros.
        // Isso limpa o conteúdo anterior do array, reiniciando-o com zeros.
        memset(receivedData, 0, sizeof(receivedData));
        // Lê dados da porta serial representada pelo descritor de arquivo (fd) e armazena esses dados em "receivedData".
        // O tamanho máximo a ser lido é especificado como "sizeof(receivedData)" e o número de bytes lidos é armazenado em "len".
	    len = read(fd, receivedData, sizeof(receivedData));

        // Cria uma chave única com a função "ftok" para identificar a memória compartilhada.
        key_t key = ftok("/tmp", 'A');
        if (key == -1) {
            perror("Erro ao criar a chave");
            exit(1);
        }
        int shmid = shmget(key, sizeof(int), IPC_CREAT | 0666);     // Cria ou obtém a memória compartilhada com base na chave "key".
        if (shmid == -1) {
        perror("Erro ao criar/obter a memória compartilhada");
        exit(1);
        }
        int *shared_memory = (int *)shmat(shmid, NULL, 0);          // Anexa a memória compartilhada ao espaço de endereçamento do processo.
        if (shared_memory == (int *)(-1)) {
            perror("Erro ao anexar a memória compartilhada");
            exit(1);
        }
        if (*shared_memory < 32){               // Se o valor na memória compartilhada for menor que 32, atribui esse valor a "shared_data".
            shared_data = *shared_memory;
        }

        // Cria uma segunda chave para outra área de memória compartilhada.
        key_t key2 = ftok("/tmp", 'B');
        if (key2 == -1) {
            perror("Erro ao criar a chave");
            exit(1);
        }
        // Obtém a segunda memória compartilhada com base na segunda chave.
        int shmid2 = shmget(key2, sizeof(int), 0666);
        if (shmid2 == -1) {
            perror("Erro ao obter a segunda memória compartilhada");
            exit(1);
        }
        // Anexa a segunda memória compartilhada ao espaço de endereçamento do processo.
        int *shared_memory2 = (int *)shmat(shmid2, NULL, 0);
        if (shared_memory2 == (int *)(-1)) {
            perror("Erro ao anexar a segunda memória compartilhada");
            exit(1);
        }
        // Atribui o valor da segunda memória compartilhada à variável "on_off".
        on_off = *shared_memory2;

        // Desanexa a segunda memória compartilhada do espaço de endereçamento do processo.
        shmdt(shared_memory2);

        
        switch (receivedData[0])
        {
        case 0x1F: // sensor com problema
            sprintf (warning, "  Sensor 0x%02x com problema\n", shared_data);
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;
        
        case 0x08: // sensor funcionando
            sprintf (warning, "  Sensor 0x%02X funcionando normalmente\n", shared_data);
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;
        
        case 0x09: // medida de umidade
            humidity[shared_data] = receivedData[1];
            sprintf (warning, "  Sensor: 0x%02x \n  Medida da umidade: %02d%%\n", shared_data, receivedData[1]);
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        case 0x0A: // medida de temperatura
            temperature[shared_data] = receivedData[1];
            sprintf (warning, "  Sensor: 0x%02x \n  Medida da temperatura %02d°C\n", shared_data, receivedData[1]);
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;
        
        case 0x0B: // desativacao do continuo de temperatura
            sprintf (warning, "  Sensoriamento continuo de temperatura desativado\n");
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        case 0x0C: // desativacao do continuo de umidade
            sprintf (warning, "  Sensoriamento continuo de umidade desativado\n");
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;
        
        case 0xCF: // comando nao existe
            sprintf (warning, "  Protocolo nao idetificado!\n");
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        case 0xEF: // endereco nao existe
            sprintf (warning, "  Endereco de sensor nao existe\n");
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        case 0xDF: // comando incorreto
            sprintf (warning, "  Nao eh posivel realizar essa acao no momento\n  O unico comando valido no momento eh 0x%02x\n",receivedData[1]);
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        case 0x6F: // endereco incorreto
            sprintf (warning, "  Nao eh posivel acessar esse sensor no momento\n  Sensor em execucao 0x%02x\n",receivedData[1]);
            shared_data = receivedData[1];
            schedule(temperature, humidity, warning, hour, minute, second, receivedData, len);
            sleep(time);
            break;

        default:
            printf ("\nAguardando resposta...\n");    
            sleep(time);
            break;
        }
    }
    off();      // Chama a função "off()" para realizar a ação de desligamento.
    return 0;   // Retorna 0 como código de saída, indicando um encerramento bem-sucedido do programa.
}

