
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

<h2 id="conclusao">  Conclusão</h2>

<p align="justify"> 
  O computador executa bem a comunicação serial com o dispositivo FPGA, enviando os comandos de requisição e recebendo os comandos de resposta corretamente. A placa faz sua função para cada dado recebido, validando os comandos e endereços coletados e enviando as respostas apropriadas. É possível ativar o sensor DHT11 e coletar os dados enviados por ele de modo estável, mantendo o módulo responsável por essa comunicação modularizado. Todos os objetivos pretendidos com a criação do projeto foram executadas com sucesso.

</p>