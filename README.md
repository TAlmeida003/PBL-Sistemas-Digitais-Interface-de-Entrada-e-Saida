
<h1 align="center"> Interface de Entrada e Saída </h1>
<h3 align="center"> Projeto de leitura de sensor digital em FPGA através de comunicação serial. </h3>  


<h2 id="sobre-o-projeto">  Sobre o Projeto</h2>

<p align="justify"> 
  O dispositivo FPGA Cyclone IV é usado para processar os dados de humidade e temperatura lidos pelo sensor DHT11. O envio de comandos para a placa e visualização dos dados coletados é feito através do computador, com o código implementado em linguagem C. Essa comunicação é serial do tipo UART. O sistema foi feito com o intuito de ser modular, possuindo a capacidade de mudar o tipo de sensor utilizado, sem mexer em áreas do circuito além daquela relacionada ao próprio sensor.
</p>


<h2 id="sensor-dht11"> Sincronização e leitura do sensor DHT11</h2>

<p align="justify"> 

O módulo geral de sincronização e leitura do DHT11 possui os seguintes valores de entradas e saídas.

* Sinal de clock de 50 MHz (entrada): a frequência usada nesse processo do sistema é de 1 MHz, então o sinal de 50 MHz é dividido dentro do módulo para ser utilizado.
* Sinal de reset (entrada): usado para resetar valores e liberar a máquina de estados.
* Pino de dados do DHT11 (entrada/saída): pino de envio e recebimento de dados do DHT11.
* Dados recebidos do DHT11 (saída): os 40 bits de dados transmitidos pelo DHT11 são transmitidos para a saída do módulo.

</p>

<p align="justify"> 
    Os processos de sincronização e leitura do DHT11 são feitos a partir de uma máquina de estados, que se ativa quando o valor da entrada reset é 1, caso contrário, a máquina, e todos os recursos utilizados no decorrer dela, são resetados. A partir do nível lógico alto do reset é feito um sinal de enable que se ativa por um curto período, para impedir que a máquina se ative uma segunda vez sem ter sido resetada.

Os 11 estados da máquina são explicados a seguir:

* IDLE: Estado inicial da máquina. Aguarda o sinal de ativação do enable para começar a enviar o sinal de start para o DHT11. Em seguida, vai para o estado START_BIT.

* START_BIT: Envia nível lógico baixo para o sensor por 19 ms. Esse é o primeiro passo de ativação do sensor. Em seguida, vai para o estado SEND_HIGH_20US.
* SEND_HIGH_20US: Envia nível lógico alto para o sensor por 20 us. Após isso, é terminada a parte de sincronização por parte da FPGA, indo para o estado WAIT_LOW. Agora, apenas serão recebidos dados do sensor.
* WAIT_LOW: É esperado que o sensor envie nível lógico baixo antes do tempo limite de 65 us. Caso passe o limite de tempo, vai para o estado ERROR. No caso do recebimento esperado, vai para o estado WAIT_HIGH.
* WAIT_HIGH: É esperado que o sensor envie nível lógico alto antes do tempo limite de 65 us. Caso passe o limite de tempo, vai para o estado de ERROR. No caso do recebimento esperado, vai para o estado FINAL_SYNC.
* FINAL_SYNC: Última etapa de sicronização. É esperado que o sensor envie nível lógico baixo antes do tempo limite de 65 us. Caso passe o limite de tempo, vai para o estado de ERROR. No caso do recebimento esperado, significa que o sensor está pronto para enviar os bits de dados, indo para o estado WAIT_BIT_DATA.
* WAIT_BIT_DATA: Período anterior ao envio de um bit de dado. É esperado que o sensor envie nível lógico alto antes do tempo limite de 65 us. Caso passe o limite de tempo, vai para o estado de ERROR. No caso do recebimento esperado, vai para a estapa READ_DATA, que faz a identificação e coleta do bit de dado.
* READ_DATA: Cronometra o tempo que o sensor envia nível lógico alto para identificar se o bit enviado é 1 ou 0. Se o tempo for maior que 60 us, significa que foi enviado o bit 1, se for menor, o bit 0. Toda vez que um bit de dado é registrado, é checada a quantidade lida até o momento, caso não tenha atingido os 40 bits, vai para o estado WAIT_BIT_DATA para recomeçar a contagem para o próximo bit. Quando todos os 40 são lidos, vai para o estado COLLECT_ALL_DATA. O sensor pode enviar o nível lógico alto por 65 us, se esse tempo for ultrapassado, vai para o estado ERROR.
* COLLECT_ALL_DATA: Transmite os 40 bits coletados para a saída do módulo. É checado se o pino de entrada e saída do DHT11 está enviando nível lógico alto, indicando que a transmissão foi finalizada, indo para o estado END_PROCESS. Caso não esteja enviando nível lógico alto, é esperado o tempo de 65 us para o sinal se normalizar, caso passe o tempo, vai para o estado de IDLE direto.
* END_PROCESS: Último estado do processo normal da máquina. Vai para o estado de IDLE.
* ERROR: Representa a situação de ter ocorrido um erro durante a sincronização ou leitura de dados do sensor. Coloca todos os bits da saída como 1 para indicar que um erro aconteceu. É checado se o pino de entrada e saída do DHT11 está enviando nível lógico alto, indo para o estado END_PROCESS. Caso não esteja enviando nível lógico alto, é esperado o tempo de 65 us para o sinal se normalizar, caso passe o tempo, vai para o estado de IDLE direto.

</p>
<h2 id="about-the-project"> Estrutura do código C no terminal</h2>

<p align="justify"> 
  A interação entre o computador e a placa é estabelecida através de dois terminais que operam simultaneamente em um ambiente Linux e são programados em linguagem C. Cada terminal desempenha uma função específica na comunicação. O terminal Tx_UART_PC é designado exclusivamente para que o usuário interaja com a placa por meio de comandos específicos. Por outro lado, o terminal Rx_UART_PC é reservado exclusivamente para visualizar as respostas da placa, sem permitir a interação direta do usuário.


  #### **Tx_UART_PC**

O terminal Tx (Transmit Data - Transmitir Dados) é responsável pelo envio de dados para a placa. Nesse terminal, o usuário pode interagir digitando comandos/protocolos de ação, juntamente com endereços de sensores. Ambas as informações devem ser inseridas em formato hexadecimal. Esses dados são temporariamente armazenados em variáveis dentro do código C. Quando o usuário conclui sua interação, os dados em formato hexadecimal são convertidos em valores binários pela UART e enviados via porta serial para a placa. No total, são enviados 2 bytes, sendo o primeiro byte o comando e o segundo o endereço do sensor desejado. O sistema oferece suporte a 32 endereços de sensores e 8 comandos de execução.

Um comando especial é o 0x00 (ou simplesmente 00), cuja função é encerrar imediatamente a execução de ambos os terminais, sem a necessidade de inserir um endereço. Importante destacar que esse comando não é transmitido pela UART.
#### **Rx_UART_PC**

O terminal Rx (Receive Data - Receber Dados) é uma interface projetada para apresentar as respostas das solicitações feitas pelo usuário no terminal Tx de forma amigável. Ele recebe 2 bytes de dados pela placa FPGA em formato binário, que são interpretados pelo código em C como valores hexadecimais. O primeiro byte indica a situação atual do sensor, enquanto o segundo fornece informações complementares, como medidas feitas pelo sensor.

O terminal Rx conta com uma tabela de sensores que exibe os valores de temperatura e umidade medidos. Esses valores não são mostrados em tempo real, em vez disso, o terminal exibe o valor da última medição solicitada pelo usuário. No entanto, em caso de modo contínuo ativo, os valores são atualizados a cada 2 segundos.

#### **Funcionamento do Tx e RX**

O terminal Rx depende do terminal Tx, e essa dependência é gerenciada por meio de 2 variáveis compartilhadas. Somente o terminal Tx pode modificar essas variáveis. O Tx é responsável por informar ao Rx qual sensor está sendo utilizado no momento. Essa informação é usada pelo Rx para atualizar a tabela de temperatura e umidade presente nele. A tabela é composta por 2 arrays, um para temperatura e outro para umidade, e o endereço fornece o índice correspondente na lista. Além disso, o endereço também é exibido quando o modo contínuo está ativo, para que o usuário saiba o endereço no momento da desativação. Se o usuário cometer um erro no endereço, a FPGA também retornarar o endereço correto ativo no modo contínuo.

A segunda variável compartilhada é de controle. Se o usuário digitar 00, o Tx envia um comando para encerrar a execução do Rx. O Tx será encerrado imediatamente, mas o Rx pode ter um atraso de até 1 segundo para encerrar.

#### **Como usar:**

Ao utilizar o sistema, o usuário deve seguir um procedimento específico. Primeiramente, é necessário inicializar o arquivo Tx_UART_PC.c, pois ele é responsável por criar e modificar as variáveis compartilhadas e exibe o menu de comandos. Este terminal possui uma tabela de comandos disponível para ser usada, junto com o significado de cada um.

Em seguida, é importante executar o arquivo Rx_UART_PC.c para visualizar as respostas da placa. Se o terminal Rx for executado primeiro, pode ocorrer um encerramento inesperado, pois as variáveis compartilhadas não terão sido criadas ou atualizadas apropriadamente. A ordem de ligar a placa FPGA em relação aos terminais não é crítica, pois o sistema é projetado para funcionar independentemente dessa sequência.

Com todos os sistemas em funcionamento, o usuário pode utilizar o teclado para inserir os comandos e endereços desejados. É importante verificar se o terminal Tx está mostrando a interação que ocorre no teclado. Caso contrário, basta clicar com o botão esquerdo do mouse sobre o terminal para garantir que as entradas do usuário sejam registradas.

Os comandos aceitos pelo sistema estão no intervalo de 0x00 a 0x07, e os endereços disponíveis variam de 0x00 a 0x1F. É válido mencionar que o uso do prefixo "0x" não é obrigatório, pois o código em C reconhece ambos os formatos de entrada.
Se o usuário inserir um valor que não seja hexadecimal ou que seja maior que 0xFF, o sistema exibirá uma mensagem de erro e solicitará que o usuário insira novamente os dados, seguindo os requisitos estabelecidos para garantir o funcionamento adequado do sistema.


#### **Observações:**
* **Executar Rx_UART_PC.c antes de Tx_UART_PC.c:** Resultará no encerramento imediato do Rx, pois as variáveis de controle não foram criadas ou atualizadas pelo Tx.
* **Desligar a placa enquanto o modo contínuo estiver ativo:**  Quando o modo contínuo está ativo, o Tx_UART_PC.c bloqueia a variável de endereço exibida no Rx. Ela só será desbloqueada quando o comando de desativação for inserido com o endereço correto. Se a placa for desligada, a medição contínua será desativada automaticamente. A solução é reiniciar o terminal Tx ou inserir o comando de desativação contínua com o endereço correto para desbloquear a variável. A placa não precisa estar ligada para realizar esse procedimento.
* **Comandos e endereços iniciados com "0x":** Pode ocorrer um falso aviso de erro ao inserir comandos que começam com "0x". Isso ocorre devido a um bug ao limpar o buffer do teclado. Quando o usuário digita o comando começando com "0x" e confirma, o buffer do teclado pode conter um valor aleatório, conhecido como "lixo de memória". Esse valor pode ser exibido como um hexadecimal inválido. No entanto, a entrada de comando foi aceita e a próxima entrada será o de endereço mesmo contendo o aviso. O código fornecerá informações sobre o que está sendo solicitado no momento.

</p>

<h2 id="conclusao">  Conclusão</h2>

<p align="justify"> 
  O computador executa bem a comunicação serial com o dispositivo FPGA, enviando os comandos de requisição e recebendo os comandos de resposta corretamente. A placa faz sua função para cada dado recebido, validando os comandos e endereços coletados e enviando as respostas apropriadas. É possível ativar o sensor DHT11 e coletar os dados enviados por ele de modo estável, mantendo o módulo responsável por essa comunicação modularizado. Todos os objetivos pretendidos com a criação do projeto foram executadas com sucesso.

</p>