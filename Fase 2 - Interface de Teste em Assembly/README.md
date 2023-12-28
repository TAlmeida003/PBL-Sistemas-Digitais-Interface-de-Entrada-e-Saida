<h1 align="center"> Sistema de Temperatura e Umidade </h1>
<h3 align="center"> Projeto de interface homem-máquina em Orange Pi PC Plus usando linguagem Assembly  </h3>

<div id="sobre-o-projeto"> 
<h2> Sobre o Projeto</h2>

Em tempos de alto avanço tecnológico, processos complexos são feitos para realizar as mais variadas tarefas. O sistema processador, que realiza a tarefa, e o operador, que manuseia o programa utilizado, devem se comunicar de forma clara e concisa. O intermédio que possibilita essa comunicação é chamado de interface homem-máquina (IHM), funcionando como um painel de operação do sistema.

Este projeto visa desenvolver uma IHM para o projeto da Fase 1. É reutilizado o código em verilog carregado na placa FPGA Cyclone IV para envio de comandos e processamento de dados do sensor DHT11. Um display LCD é utilizado para apresentar a interface do sistema ao usuário. O processamento lógico é feito em uma Orange Pi PC Plus, sendo ela, um computador de placa única.

Os requisitos para elaboração do sistema são apresentados a seguir:

* O código carregado na Orange Pi PC Plus deve ser feito em Assembly;
* O display LCD deve ser usado para apresentar a interface do sistema ao usuário;
* Só podem ser usados dispositivos já presentes no protótipo montado;
* O código em verilog carregado na placa FPGA Cyclone IV deve ser o mesmo desenvolvido na Fase 1;
* O protocolo seguido na comunicação da Orange Pi com a FPGA também deve ser o mesmo desenvolvido na Fase 1.

<h2>  Equipe: <br></h2>
<uL> 
	<li>Samara dos Santos Ferreira<br></li>
	<li>Silvio Azevedo de Oliveira<br></li>
	<li>Sival Leão de Jesus<br></li>
  <li>Thiago Neri dos Santos Almeida<br></li>
</ul>

<h1 align="center"> Sumário </h1>
<div id="sumario">
	<ul>
        <li><a href="#">  Descrição dos equipamentos e software utilizados</a></li>
        <li><a href="#"> Mapeamento de memória</a></li>
        <li><a href="#GPIO"> GPIO </a></li>
        <li><a href="#UART"> UART </a></li>
        <li><a href="#displayLCD"> Display LCD </a></li>
        <li><a href="#interfaceUsuario"> Interface do Usuário </a></li>
        <li><a href="#solucao-geral"> Solução Geral do projeto </a></li>
        <li><a href="#"> Testes Realizados </a></li>
        <li><a href="#"> Conclusão </a></li>
        <li><a href="#"> Execução do projeto </a></li>
        <li><a href="#"> Referências </a></li>
	</ul>	
</div>

<div id=""> 
<h2> Descrição dos equipamentos e software utilizados</h2>
<p align="justify"> 


**SBC (Orange Pi PC Plus)**

Nesta fase do projeto, a implementação foi conduzida em um sistema computacional de placa única, cuja compatibilidade estende-se a diversos sistemas operacionais, destacando-se especialmente Ubuntu, Debian, Android 4.4 e Android 7.0, todos pertencentes à família de sistemas derivados do Linux. A condução do projeto recaiu sobre a Orange Pi PC Plus, a qual integra o processador Allwinner H3 system-on-chip. Este processador, um quad-core, possui quatro núcleos de processamento de dados e opera a uma frequência máxima de 600 MHz. Notavelmente, o dispositivo dispõe de uma interface de rede integrada Ethernet 10/100 RJ45, além de oferecer 40 pinos periféricos de baixo nível.

  
O dispositivo em questão apresenta uma capacidade de armazenamento interno de 8GB, com a possibilidade de expansão para até 32GB mediante a utilização de um cartão SD. Adicionalmente, conta com 1GB de RAM, utilizando a tecnologia de memória DDR3.

A placa em questão foi programada em Verilog, utilizando a IDE (Ambiente de Desenvolvimento Integrado) VS Code para programação e transmissão de códigos por meio da rede Wi-Fi, devido a sua rede integrada que costa na placa. O objetivo primordial desse processo de programação foi capacitar a placa para enviar e receber comandos da FPGA Cyclone IV (placa utilizada na fase 1). Isso inclui a interpretação precisa desses comandos e a execução das ações solicitadas. Essa abordagem substituiu o computador desktop que estava em uso na fase 1, marcando uma transição significativa na arquitetura do sistema.


**Display LCD**

Para proporcionar uma interface amigável, o projeto incorpora um Display LCD (Liquid Crystal Display/Visor de Cristal Líquido) 16x2, que possui 16 colunas por 2 linhas, com iluminação de fundo em azul e caracteres em cor branca. Este display é equipado com o controlador HD44780, que é capaz de exibir caracteres alfanuméricos, alfabético e caracteres do alfabeto japonês (kana) e símbolos. O controlador pode ser configurado para ser controlado por um microprocessador de 4 ou 8 bits.

Uma característica fundamental desse controlador é a inclusão interna de todas as funções necessárias para operar um display de matriz de pontos, como a RAM de exibição, o gerador de caracteres e o driver de cristal líquido. Essa integração interna simplifica a conexão de um sistema mínimo a esse controlador/driver, facilitando assim a interface com o display de matriz de pontos.

Além disso, o display conta com um Gerador de Caracteres, onde o ROM (Read-Only Memory) do gerador de caracteres do HD44780U foi expandido para gerar 208 fontes de caracteres de 5 × 8 pontos e 32 fontes de caracteres de 5 × 10 pontos, totalizando 240 diferentes fontes de caracteres. Essa variedade de fontes proporciona flexibilidade na apresentação de informações no display. 


**Botões**

Para a interação do usuário com o sistema, foram incorporados três botões micro chave de 6 x 6 x 5 mm, alinhados de maneira sequencial em uma disposição horizontal. Cada botão desempenha uma função específica, proporcionando uma interface intuitiva.

O primeiro botão, situado à esquerda, possui a função de voltar/decrementar. Dependendo da tela atual exibida pelo LCD, ele permite retroceder para uma tela anterior ou decrementar um valor numérico apresentado.

O segundo botão, posicionado no centro, tem a função de confirmar. Este botão atua como um validador para as ações executadas, dando o respaldo necessário para as decisões tomadas pelo usuário.

O terceiro botão, localizado à direita, tem a função de incrementar. Ele possibilita o aumento de um valor numérico exibido na tela.

**Interface de entrada e saída (Fase 1)**

Na fase 2 do projeto, manteve-se a utilização do projeto desenvolvido na fase 1, com foco específico na Placa FPGA Cyclone IV. Esta placa incorpora integralmente o projeto anterior, incluindo sua programação em Verilog. A função primordial da Placa FPGA Cyclone IV nesta etapa consiste em receber os comandos provenientes da Orange Pi PC Plus, interpretá-los de maneira precisa e estabelecer comunicação com o sensor de temperatura e umidade DHT11, também empregado na fase 1.

A interação com o sensor DHT11 tem como objetivo fundamental a coleta de dados. Após interpretar os comandos e efetuar a comunicação com o sensor, a Placa FPGA Cyclone IV assume a responsabilidade de enviar de volta à Orange Pi PC Plus o comando de resposta pertinente. Este retorno informa sobre a temperatura, umidade ou eventuais erros de leitura ou funcionamento do sensor, levando em consideração os dados fornecidos pelo sensor e as ações executadas.

</p>
</div>

<div id=""> 
<h2> Arquitetura do Processador</h2>
<p align="justify"> 

A Orange Pi PC Plus utiliza um processador Allwinner H3 Quad-core Cortex-A7, baseado na arquitetura ARM, especificamente na ARMv7-A. Esse processador oferece suporte a implementações em uma ampla gama de pontos de desempenho. A simplicidade inerente aos processadores ARM resulta em implementações compactas, contribuindo para a eficiência do espaço e permitindo que dispositivos alcancem níveis baixos de consumo de energia.


#### **Tipo RISC (Reduced Instruction Set Computing)**

A arquitetura ARM é classificada como RISC (Computador com conjunto de intruções reduzido), caracterizada por um conjunto otimizado e reduzido de instruções. Essas arquiteturas são projetadas para executar mais instruções em menos tempo, o que leva a softwares compilados para RISC a possuírem mais linhas de código em linguagens de programação de baixo nível, como assembly. O conceito fundamental por trás do tipo RISC é realizar a execução de cada instrução em um único ciclo de clock, buscando assim eficiência e desempenho otimizado.

#### **Load/Store**

Na arquitetura ARM, as operações de processamento de dados são exclusivamente realizadas nos conteúdos dos registradores, não sendo efetuadas diretamente nos conteúdos da memória. Nesse paradigma, as operações de leitura (load) e escrita (store) na memória são conduzidas explicitamente por instruções separadas. Para carregar dados da memória para os registradores, utiliza-se a instrução LDR, enquanto a instrução STR é empregada para escrever na memória dados provenientes dos registradores.


#### **Registradores**

Essa arquitetura ARM dispõe de 13 registradores gerais de 32 bits, numerados de R0 a R12. Além desses, são fornecidos três registradores especiais de 32 bits, designados como SP (R13), LR (R14) e PC (R15). Esses registradores especiais têm finalidades distintas na execução do programa:

1. **SP (R13 - Ponteiro de Pilha):** Responsável por armazenar o endereço atual da pilha, permitindo o gerenciamento eficiente da memória durante a execução do programa.

2. **LR (R14 - Registrador de Link):** O registrador de link é especial, pois pode armazenar informações de retorno de link, geralmente utilizado para armazenar o endereço de retorno de uma sub-rotina (função ou procedimento) quando uma chamada de função é realizada.

3. **PC (R15 - Contador de Programa):** Este registrador atua como o contador de programa, armazenando o endereço da instrução atual em execução. Ao executar uma instrução ARM, o PC lê o endereço da instrução atual mais 8. Isso ocorre porque as instruções ARM são normalmente 4 bytes de comprimento, e o PC é incrementado para apontar para a próxima instrução.


#### **Tipos de dados na memória**

  Os processadores ARMv7-A suportam diversos tipos de dados tanto na memória quanto nos registradores.

  * **Na Memória:**
    1. **Byte:** 8 bits
    2. **Halfword:** 16 bits
    3. **Word:** 32 bits
    4. **Doubleword:** 64 bits

  * **Nos Registradores:**

    1. **Ponteiros de 32 bits**
    2. **Inteiros de 32 bits:** Podem ser assinados ou não assinados.
    3. **Inteiros de 16 bits ou 8 bits não assinados:** Mantidos na forma zero-extendida.
    4. **Inteiros de 16 bits ou 8 bits assinados:** Mantidos na forma de extensão de sinal.
    5. **Dois inteiros de 16 bits empacotados em um registro.**
    6. **Quatro inteiros de 8 bits empacotados em um registro.**
    7. **Inteiros de 64 bits:** Podem ser assinados ou não assinados, mantidos em dois registros.

</p>
</div>

<div id=""> 
<h2> Conjunto de instruções utilizadas</h2>
<p align="justify"> 

 A programação da Orange Pi PC Plus foi conduzida utilizando linguagem assembly, na qual foram empregadas diversas instruções no desenvolvimento do sistema.

**Aritmética:** São responsáveis por realizar operações matemáticas nos dados dos registradores.  

* **ADD** - Adição
* **MUL** - Multiplicação
* **SUB** - Subtração
* **SDIV** - Divisão com Sinal

**Lógica:** Operam em nível de bit e realizam operações booleanas. Elas incluem operações como "AND" lógico, "OR" lógico e limpeza de bits.

* **AND** - Operação Lógica "AND"
* **BIC** - Limpeza de Bits
* **ORR** - Operação Lógica "OR"

**Controle de Fluxo:** Direcionam o fluxo de execução do programa. Elas incluem saltos condicionais e incondicionais, permitindo que o programa tome decisões e execute diferentes partes do código com base em condições.

* **B** - Ramificação Incondicional
* **BL** - Salto de Sub-Rotina
* **BX** - Ramificação e Troca de Estado
* **CMP** - Comparação

**Deslocamento e Rotação:** Manipulam os bits dos registradores, movendo-os para a esquerda ou para a direita. Essas operações são frequentemente usadas para realizar multiplicação ou divisão por potências de dois de forma eficiente.

* **LSL** - Deslocamento à Esquerda
* **LSR** - Deslocamento à Direita

**Acesso à Memória:** São responsáveis por ler ou escrever dados na memória.

* **LDR** - Carregamento
* **STR** - Armazenamento
* **STRB** - Armazenamento de Byte

**Transferência de Dados:** Movem dados de um registrador para outro. 

* **MOV** - Move dados para os registradores

**Empilhamento e Desempilhamento:** manipulam a pilha, uma estrutura de dados na memória usada para armazenar temporariamente dados e endereços de retorno durante chamadas de função.

* **POP** - Desempilhamento
* **PUSH** - Empilhamento

**Chamadas de Sistema:** São usadas para requisitar serviços do sistema operacional. Isso inclui operações como leitura e escrita em arquivos, alocação de memória e outras funcionalidades do sistema operacional.

* **SVC** - Chamada de Sistema

**Diretivas e Constantes:** São instruções especiais no código assembly que não são executadas como instruções de máquina.

* **.EQ** - Definição de uma constante
* **.word** - Definição de Palavra na Memória
* **.data** - Início da Seção de Dados
* **.asciz** - String com Terminação Nula

**Condições de Ramificação:** Instruções de ramificação condicional alteram o fluxo do programa com base nas condições estabelecidas pelas flags de status.

* **NE** - Diferente
* **EQ** - Igual
* **GE** - Maior ou Igual
* **LT** - Menor que


</p>
</div>
<div id="map"> 
<h2> Mapeamento de memória</h2>
<p align="justify"> 

O mapeamento de memória é uma técnica que visa organizar e gerenciar o espaço de endereçamento na memória física. Neste contexto, explora-se como esse conceito é aplicado no desenvolvimento do projeto, abrangendo tanto o âmbito do software quanto o hardware.

<h3> Mapeamento a nível de Software</h3>

O gerenciamento de memória física é uma função desempenhada pelo sistema operacional, utilizando a técnica de abstração de memória virtual. Para acessar um endereço físico de memória, é necessário fornecer não apenas o endereço a ser acessado, mas também dados que descrevam as características desse acesso. Esses dados são cruciais, pois o sistema operacional adota o conceito de tratamento de dados como arquivos. Ao "abrir" um endereço de memória, é preciso especificar como esse "arquivo" será manipulado. Essas autorizações abrangem permissões fundamentais, como leitura, escrita, a capacidade de escolher o endereço virtual correspondente ao valor endereçado e a habilidade de compartilhar dados com outros "arquivos".

Para acessar a memória física, o processo inicia-se ao entrar no diretório /dev/mem, onde as seções desejadas da memória estão localizadas. Em seguida, é necessário fornecer ao sistema operacional um endereço de memória física. A execução de uma *system call* ocorre após a passagem do endereço e suas informações de abertura, momento em que o sistema operacional verifica se o endereço está presente na tabela de páginas ou no buffer *Translation Lookaside Buffer* (TLB). Se não estiver, o sistema operacional acessa diretamente a memória, recuperando o dado armazenado na posição endereçada. A página e o TLB são atualizados, e ao usuário é concedida uma referência virtual para acessar a memória física.

Segue em anexo o fluxograma que ilustra os passos utilizados.

<p align="center">
  <img src="Imagens/Map-MemSO.png" width = "600" />
</p>
<p align="center"><strong> Fluxograma do mapeamento de memória em nível de software </strong> </p>

Para o desenvolvimento do projeto, foram empregadas três chamadas de sistema (*syscall*), sendo que duas delas são destinadas à manipulação da memória:

* **sys_open**: Esta chamada é utilizada para abrir o arquivo cujo caminho foi especificado (dev/mem), permitindo o acesso e manipulação das áreas desejadas da memória;

* **sys_map2**: Essa chamada de sistema é responsável por mapear um endereço físico, juntamente com as informações de permissões do arquivo, e retorna a referência de memória virtual associada;

* **sys_nanosleep**: Essa chamada de sistema proporciona uma pausa no processador por um período de tempo especificado (n), contribuindo para a gestão temporal e sincronização de operações no projeto.

<h3> Mapeamento a nível de Hardware</h3>

Ao buscar os dados armazenados na memória física através do barramento de sistema requisitado pela CPU, os dados passam por um decodificador/controlador de endereços que sinaliza a localização dos dados. O decodificador envia um sinal de controle para o local solicitado, podendo ser a memória principal, um registrador da *General Purpose Input/Output* (GPIO) ou até um registrador de dados de alguns sistemas digitais, como a *Universal Asynchronous Receiver-Transmitter* (UART). Mesmo tendo um endereço de memória física, os dados obtidos do mapeamento não estão presentes na memória principal ou no disco, mas sim em locais separados e específicos para suas funções.

Segue em anexo um diagrama de uma versão simplificada do processo descrito. 

</p>
</div>

<div id="GPIO"> 
<h2> GPIO</h2>
<p align="justify"> 

A Entrada/Saída de Propósito Geral (GPIO) representa uma interface com pinos que podem ser configurados tanto como entrada quanto como saída de dados, conferindo flexibilidade para interagir com componentes externos no sistema digital da SBC. Além disso, destaca-se a presença de hardware integrado na pinagem, oferecendo opções adicionais de configuração para os pinos. No total, são disponibilizados 28 pinos, divididos em 7 tipos (PA, PC, PD, PE, PF, PG e PL). Esses pinos podem ser manipulados tanto a nível de software quanto diretamente via registrador.

Para atender aos objetivos do projeto, foram utilizados apenas 11 pinos, sendo 7 do tipo PA e 4 do tipo PG. Esses pinos foram distribuídos em diversas funcionalidades específicas: 2 pinos do tipo PA foram dedicados à comunicação via padrão UART; 6 pinos foram alocados para o controle do LCD, sendo 2 do tipo PA e 4 do tipo PG; e os 3 pinos restantes do tipo PA foram destinados aos botões de controle da interface do projeto.

Para visualizar a distribuição dos pinos e suas funções designadas, está anexado uma imagem apresentando o diagrama de pinagem da Orange Pi, destacando os pinos utilizados e suas respectivas funções na resolução do problema.

<p align="center">
  <img src="Imagens/Diagrama-pinos.png" />
</p>
<p align="center"><strong> Diagrama da pinagem da Orange Pi e as respectivos funções de cada pino no projeto</strong> </p>

<h3>Configuração da Direção do Pino</h3>	

Para empregar cada pino com suas funções designadas, é essencial configurar a direção de cada pino individualmente. A definição da direção do pino é realizada por meio da manipulação de registradores. Nesse contexto, cada pino tem 3 bits reservados nos registradores para indicar seu comportamento. Importante notar que nem todos os pinos oferecem as mesmas opções de seleção, pois alguns estão reservados para funções específicas, como no caso da UART.

Na solução adotada para o projeto, optou-se por configurar os pinos de acordo com as seguintes definições:

* **Entrada:** identificada pela sequência de bits 000; 
* **Saída:** representada pela sequência de bits 001;
* **UART:** caracterizada pela sequência de bits 011.

A atribuição desses valores foi realizada seguindo uma sequência lógica de 4 passos. Nesse sentido, segue em anexo um fluxograma que ilustra a lógica utilizada, bem como a explicação dos passos:

<p align="center">
  <img src="Imagens/Diracao-do-pino.png" />
</p>
<p align="center"><strong> Fluxograma da configuração da direção do pino </strong> </p>

O processo de atribuição desses valores segue uma lógica em quatro passos. Inicialmente, o fluxograma inicia-se com uma solicitação ao sistema operacional por meio de uma *syscall*, buscando a referência virtual do endereço base da GPIO. Uma vez obtido esse endereço, realiza-se um deslocamento dentro da página da GPIO para encontrar o *offset* onde está localizado o registrador da direção. Dado que existem múltiplas referências de direção nesse registrador, é necessário um deslocamento adicional para localizar os 3 bits correspondentes ao pino desejado. Por fim, esses 3 bits são adicionados ao local apropriado e salvos no registrador, configurando assim a direção desejada para o pino.


<h3>Leitura/Escrita do Valor Lógico do Pino</h3>	

O processo de leitura ou escrita de um pino na GPIO segue uma abordagem semelhante à configuração da direção do pino. Nesse contexto, o valor lógico do pino é representado por um único bit, armazenado em um registrador na memória física, exclusivamente designado para os dados dos pinos. Cabe ressaltar que esse registrador de dados é organizado por tipos de pinos, com os tipos PA sendo alocados em um registrador diferente dos pinos PG. Além disso, dentro do registrador, os dados são organizados tendo a referência do pino. Por exemplo, o pino PA0 é guardado na posição 0 do registrador.

Para compreender melhor o fluxo de escrita ou leitura dos valores dos pinos na Orange Pi, segue um fluxograma explicativo:

<p align="center">
  <img src="Imagens/Leitura-escrita-pino.png" />
</p>
<p align="center"><strong> Fluxograma da leitura/escrita do valor lógico do pino</strong> </p>
 
O fluxograma inicia-se com uma solicitação ao sistema operacional por meio de uma *syscall*, buscando a referência virtual do endereço base da GPIO. Após adquirir o endereço, há um deslocamento dentro da página para encontrar o *offset* do registrador de dados. Considerando que existem múltiplas referências desse registrador, um deslocamento adicional é necessário para localizar o bit correspondente ao pino desejado. Uma vez identificado o local correto, o valor lógico do pino é escrito ou lido, dependendo da operação desejada. Este processo é concluído ao salvar ou recuperar o valor no registrador, ajustando assim o estado lógico do pino conforme necessário.

<h3>Inicialização da GPIO no Projeto</h3>	

Na fase inicial do projeto, o processo de inicialização segue a atribuição de direção para os 11 pinos essenciais. Para fornecer uma visão clara dessa configuração, apresenta-se a seguir uma tabela detalhando a relação entre a pinagem utilizada e suas respectivas direções:

<p align="center">

| Pino  	| Modo     | Correspondente	|
| ------------- | ------------- | ------------- |
| PA7  	  | Input    |  Botão (Voltar)	|
| PA10    | Input    |  Botão (OK)	    |
| PA20	  | Input    |  Botão (Próximo) |
| PA13 	  | UART3_TX |  RX (FPGA)	|
| PA14    | UART3_RX |  TX (FPGA)	|
| PA2	    | Output   |  RS (LCD) |
| PA18 	  | Output   |  E (LCD) |
| PG8  	  | Output   | 	D4 (LCD)|
| PG9	    | Output   |  D5 (LCD)|
| PG6 	  | Output   |  D6 (LCD)|
| PG7  	  | Output   |  D7 (LCD)|
</p>

<p align="center">
<strong> Tabela com as direções e funções de cada pino</strong> </p>
 
</p>
</div>

<div id="UART"> 
<h2> UART</h2>

<p align="justify"> 

A Orange Pi PC Plus possui um sistema que possibilita realizar comunicação serial, seguindo o protocolo UART para troca de dados. Existe mais de uma UART que pode ser utilizada, cada uma possuindo suas próprias portas de entrada e de saída de dados. A que foi usada no sistema foi a UART 3.

<h3>Habilitação da UART</h3>	

Antes de setar as configurações específicas de troca de dados da UART 3, deve-se habilitar a utilização e alteração dos espaços dela. Seguindo esse processo, são realizados os seguites passos:

1. É mapeado o endereço base da CCU (0x01C20000). Esse endereço base é usado para modificar os espaços citados abaixo;
2. No endereço do registrador APB2_CFG_REG (0x0058), é setado qual sinal de clock será usado no sistema. O bit 25 do registrador é setado para 1, indicando o sinal de clock PLL_PERIPH0, que possui frequência de 624 MHz. Esse é o sinal indicado pelo processador para ser usado na comunicação serial;
3. No endereço do regitrador BUS_CLK_GATING_REG3 (0x006C), é habilitado o sinal de clock da UART utilizada. O bit 19 é setado para 1, habilitando o sinal de clock da UART 3;
4. No endereço do registrador BUS_SOFT_RST_REG4 (0x02D8), é habilitado ou desabilitado o reset da UART utilizada. O bit 19 é setado para 0, setando o reset da UART 3. Isto é feito para evitar que configurações feitas anteriormente por outros aparelhos possam atrapalhar o andamento do sistema;
5. Depois que a UART 3 é resetada, o reset é desativado para que os dados de configuração possam ser especificados e mantidos. Assim, o bit 19 do registrador BUS_SOFT_RST_REG4, é setado para 1.

<h3>Configuração da UART</h3>	

Com o sinal de clock correto habilitado e o reset desativado, os dados de configuração podem ser indicados. As alterações feitas se resumem a: indicar o valor do divisor de sinal de clock, que resulta no baud rate desejado; indicar quantos bits serão transmitidos e recebidos em cada troca de dados; e habilitar os FIFOs de transmissão e recebimento, que funcionam como espaços de intermédio no caminho dos dados. Sendo assim, o processo de configuração segue os seguintes passos:

1. É mapeado o endereço base da UART 3 (0x01C28C00). O resultado do mapeamento é guardado no R9, para que as configurações sejam setadas e, posteriormente, os dados possam ser transmitidos e lidos;
2. O bit 7 do registrador LCR (0x000C) indica se os endereços que serão utilizados serão os de transmissão/recebimento de dados ou os do valor do divisor de sinal de clock. É preciso diferenciar quais serão usados pelo fato do endereço 0x0000 ser utilizado para acessar os FIFOs e também para indicar os 8 bits inferiores do valor do divisor. Dessa forma, o bit 7 do LCR é setado para 1, indicando que será setado o valor do divisor;
3. O bit 1 do registrador HALT (0x00A4) habilita alterações no valor do divisor e no endereço LCR (exceto o bit 7). Assim, o bit 1 do HALT é setado para 1, habilitando as alterações;
4. Os 8 bits menos significativos do DLL (0x0000) e do DLH (0x0004) indicam os 8 bits inferiores e os 8 bits superiores, respectivamente, do valor do divisor. Neste passo, os bits que indicam o valor do divisor são setados;
5. Os bits 1 e 0 do LCR indicam quantos bits serão lidos e transmitidos a cada troca de dados. Os dois bits são setados para 1, indicando que a comunicação será de 8 bits por vez;
6. O bit 2 do HALT indica o carregamento das alterações feitas no valor do divisor e no registrador LCR. Assim, o bit 2 é setado para 1, para carregar as alterações. Depois que o carregamento é concluído, o bit é limpo automaticamente;
7. O bit 7 do LCR é setado para 0, indicando que os espaços utilizados serão para a transmissão e recebimento de dados;
8. O bit 1 do HALT é setado para 0, para desabilitar alterações no valor do divisor e no registrador LCR;
9. O bit 0 do registrador FCR habilita ou desabilita os FIFOs de transmissão e recebimento de dados. Assim, o bit 0 do FCR é setado para 1, habilitando os FIFOs.

Seguindo os passos de habilitação e configuração da UART, os bytes podem ser lidos e recebidos normalmente. Abaixo, está o fluxograma que apresenta, de forma resumida, o processo explicado.

<p align="center">
  <img src="Imagens/Habilitacao-configuracao-UART.jpg" width = "600" />
</p>
<p align="center"><strong>Fluxograma da Habilitação e configuração da UART</strong></p>

<h3>Cálculo do baud rate</h3>	

A fórmula usada para calcular o baud rate é:

  * Baud rate = frequência do sinal de clock / (divisor * 16)

Como a frequência do sinal de clock é de 624 MHz, foi setado o valor do divisor para 4062. Isso resulta em um baud rate de 9600, que é a taxa utilizada na comunicação serial do código inserido na FPGA na Fase 1 do projeto. Dessa forma, os valores binários setados nos registradores DLL e DLH foram:

  * Registrador DLL: 11011110.
  * Registrador DLH: 1111.

<h3>Funções da UART</h3>	

Foram utilizadas 3 funções para acessar a UART. Elas são explicadas a seguir:

  * TX_UART: recebe como parâmetros o endereço base da UART 3 em R9, e o byte a ser transmitido em R0. Essa função insere o byte de R0 no endereço THR (0x0000) da UART 3, que tem a função de colocar o byte no FIFO de transmissão para ser passado pela porta da comunicação serial.
  * RX_UART: recebe como parâmetro o R9 com o endereço base da UART 3. Essa função lê um byte do endereço RBR (0x0000) da UART 3, que tem a função de acessar o FIFO de recebimento da comunicação serial. O byte lido é retornado em R0.
  * CHECK_EMPTY_RX_UART: essa função checa a situação do FIFO de recebimento de dados. Recebe como parâmetro o endereço base da UART 3 em R9. Lê o regitrador USR (0x007C), que contém os status da UART. O bit 3 indica se o FIFO de recebimento está vazio ou não. Esse bit é colocado no LSB do R0 e é retornado. Se esse bit for 0, o FIFO está vazio, se for 1, não está.

</p>
</div>

<!-- DISPLAY LCD -->

<div id="displayLCD"> 
<h2> Display LCD</h2>

<p align="justify"> 

O display LCD utilizado pode ser configurado para ser acionado sob o controle de um microprocessador de 4 ou 8 bits. No modo de 8 bits, os oito pinos de dados são usados para escrever informações de maneira paralela, enquanto no modo de 4 bits, os dados são processados em duas etapas: primeiramente, é transmitido um conjunto de 4 bits de informações, e depois os 4 bits restantes. 

<h3>Inicialização do LCD</h3>	

Quanto à inicialização do LCD, é primordial configurar o controlador no modo de 4 bits, uma vez que ele inicia automaticamente no modo de 8 bits, independentemente do número de linhas de dados conectadas entre o controlador e o módulo LCD. O procedimento de inicialização é delineado da seguinte forma:

- Ao aplicar a energia pela primeira vez, é necessário aguardar 100 ms, pois a ativação requer um atraso significativo;

- Os quatro passos subsequentes são semelhantes e constituem a configuração do modo de 4 bits. No primeiro passo, envia-se o comando SET **(0x03)** para reiniciar efetivamente o controlador do LCD, sendo os 4 bits inferiores irrelevantes. Após o envio da função, é necessário um atraso de 5 ms;

- Na segunda instância do comando SET **(0x03)**, é exigido um atraso de 150 µs;

- Na terceira instância, o tempo de atraso é o mesmo, mas o controlador já reconhece que se trata de uma função de *reset* e está pronto para receber a instrução SET "real";

- Por fim, é enviado o comando SET **(0x02)** para entrar no modo de 4 bits, indicando que o controlador LCD lerá apenas os quatro pinos de dados superiores a cada uso do Enable. O atraso necessário nesse envio é de 150 µs;

- Em seguida, envia-se o comando para habilitar as duas linhas **(0x28)**;

- Posteriormente, o comando de controle liga/desliga do display é utilizado para fazer o seu desligamento **(0x08)**;

- Após isso, procede-se à limpeza do display **(0x01)**;

- A instrução subsequente configura o modo de entrada, determinando que o cursor e/ou display deve mover-se à direita ao inserir uma sequência de caracteres **(0x06)**;

- A sequência de inicialização então é concluída, sendo crucial notar que o display permanece desligado. Dessa forma, como último passo, envia-se a instrução para ligar o display e apagar o cursor **(0x0C)**.

Abaixo, apresenta-se o fluxograma da inicialização do LCD, resumindo de maneira clara o passo a passo desse processo e seu fluxo.

<p align="center">
  <img src="Imagens/Inicializacao-LCD.jpg" alt=Fluxograma da inicialização do LCD="300" height="300">
</p>
<p align="center"><strong>Fluxograma da inicialização do Display LCD</strong></p>


<h3>Escrita no LCD</h3>

No que refere-se à fase de escrita, o procedimento inicial é a posição do cursor na primeira linha, através do envio do comando **(0x80)**. Posteriormente, utiliza-se uma função específica para transmitir a frase ao LCD. Se a extensão da frase for inferior a 17 caracteres, a escrita é efetuada diretamente no LCD. No entanto, caso a frase exceda esse limite, realiza-se um deslocamento dos caracteres até que a totalidade da mensagem seja visível, e o retorno ao ponto inicial ocorre ao término da escrita da frase. Se um botão for pressionado, essa visualização é interrompida e a mudança de tela é realizada.

O fluxograma abaixo apresenta de maneira visual o processo de escrita em uma linha do LCD.

<p align="center">
  <img src="Imagens/Escrita-LCD-Uma-Linha.jpg" alt=Fluxograma escrita em uma linha="300" height="300">
</p>
<p align="center"><strong>Fluxograma da escrita de uma linha no Display LCD</strong></p>

Para a escrita na segunda linha, o cursor é posicionado ao enviar o comando **(0xC0)**. Em seguida, realiza-se uma comparação do tamanho da frase e segue-se a mesma verificação descrita anteriormente, para o caso da primeira linha. Este processo está exemplificado no fluxograma a seguir, o qual trata-se da escrita nas duas linhas do display. Após o envio de ambas as frases, uma verificação é realizada para determinar se a escrita foi concluída ou não. Em caso afirmativo, o procedimento é encerrado. Caso contrário, ocorre o deslocamento dos caracteres da frase em questão.

<p align="center">
  <img src="Imagens/Escrita-LCD-Duas-Linhas.jpg" alt=Fluxograma da escrita em duas linhas="300" height="300">
</p>
<p align="center"><strong>Fluxograma da escrita em duas linhas no Display LCD</strong></p>

</p>
</div>


<div id="interfaceUsuario"> 
<h2> Interface do Usuário </h2>

A interface do usuário é projetada visando demonstrar de maneira abrangente o fluxo do sistema, destacando como ele pode ser utilizado e os diferentes caminhos que podem ser percorridos com base nas escolhas do usuário. O sistema oferece duas opções principais: o fluxo normal e o fluxo contínuo.

O fluxo normal representa a operação padrão do sistema, proporcionando ao usuário a navegação por diferentes telas e funcionalidades. Por outro lado, o fluxo contínuo é acionado quando o sistema entra em modo de sensoriamento contínuo de temperatura ou umidade. Nesse modo, o sistema retorna periodicamente, em intervalos predefinidos, os valores atuais de temperatura e umidade, desde que esteja operando corretamente. 

Para proporcionar uma compreensão mais aprofundada, a explicação do fluxo normal e do fluxo contínuo foi segmentada, delineando os caminhos específicos que podem ser seguidos em ambas as opções.

<p align="justify"> 

<h3>Fluxo Normal</h3>

Dentro do contexto do fluxo normal, a interação começa na tela inicial. A partir dela, ao acionar o botão central, ocorre a transição para a tela de comando. Nessa interface, o usuário tem a opção de retornar à tela inicial ao pressionar o botão de retorno (botão esquerdo), caso esteja no comando 01. Outra alternativa é utilizar o botão de avançar (botão direito), possibilitando a progressão entre os comandos disponíveis, numerados de 01 a 07. O botão de confirmar (botão do meio) permite o avanço para a próxima ela, que é a de endereço. 

Na tela subsequente, dedicada à seleção de um endereço, o usuário tem a opção de retornar ao menu de comandos, se estiver no endereço 00, ou percorrer os endereços disponíveis, numerados de 00 a 31, utilizando os botões de retornar e avançar, respectivamente. Ao escolher um endereço e pressionar o botão "ok", a transição direciona-se para a tela de processamento das informações recebidas. As três telas mencionadas — a tela inicial, a de comando e a de endereço — podem ser observadas na imagem abaixo, juntamente com o fluxo de voltar e avançar, destacado pelas setas interligando-as.

<p align="center">
  <img src="Imagens/Interface-Usuario-Fluxo-Normal.jpg" alt=Fluxo normal="300" height="300">
</p>
<p align="center"><strong>Tela inicial, de comando e de endereço do fluxo normal</strong></p>

Após a conclusão do processamento dos dados obtidos, a tela de resposta é apresentada, podendo exibir a resposta correspondente ao comando escolhido. As respostas disponíveis, como podem ser visualizadas na imagem abaixo, são a do caso o sensor esteja com problema, com funcionamento normal ou desconectado. As outras duas, referem-se as medidas de temperatura e umidade atuais. Ao pressionar o botão central, o usuário retorna à tela de comandos.

<p align="center">
  <img src="Imagens/Interface-Usuario-Fluxo-Normal-Respostas.jpg" alt=Fluxo normal respostas="300" height="300">
</p>
<p align="center"><strong>Tela de processamento e as telas de respostas disponíveis</strong></p>

Essa abordagem visa fornecer ao usuário uma visualização clara dos resultados obtidos após a execução de um comando específico, permitindo uma rápida compreensão do estado atual do sistema. 


<h3>Fluxo Contínuo</h3>

Ao escolher o comando para iniciar o sensoriamento contínuo e selecionar o endereço do sensor, a transição ocorre para a tela de processamento e logo após, a tela de comando do contínuo. Nessa tela, a escolha do comando é destacada na primeira linha, enquanto a segunda exibe a resposta, indicando a medida da temperatura, umidade ou uma resposta específica. 

Após a seleção do comando, a navegação prossegue para a tela de endereço, mantendo a mesma lógica do fluxo normal. As respostas permanecem sendo exibidas na segunda linha dessa tela. As telas de comando e de endereço do modo contínuo para temperatura e umidade podem ser observadas na imagem abaixo.

<p align="center">
  <img src="Imagens/Interface-Usuario-Fluxo-Continuo.jpg" alt=Fluxo continuo="300" height="300">
</p>
<p align="center"><strong>Telas de comando e de endereço do fluxo contínuo, no sensoriamento de temperatura e umidade, respectivamente</strong></p>

Posteriormente, o fluxo progride para a tela de processamento e, em seguida, para a tela de resposta. Nesta última, são apresentadas as opções de comando incorreto, endereço incorreto ou confirmação da desativação do sensoriamento contínuo. Se a escolha recair sobre as duas primeiras opções, ao pressionar o botão "ok", permanece-se na tela contínua. Caso a opção seja a última, ocorre o retorno à tela de comandos do fluxo normal. As respostas disponíveis no sensoriamento contínuo estão exibidas na imagem abaixo.

<p align="center">
  <img src="Imagens/Interface-Usuario-Fluxo-Continuo-Respostas.jpg" alt=Fluxo continuo respostas="300" height="300">
</p>
<p align="center"><strong>Telas das respostas disponíveis no fluxo contínuo</strong></p>

O fluxo abrangente do sistema é apresentado na imagem abaixo, delineando todos os caminhos possíveis de acordo com cada fluxo disponível. É relevante observar que, a partir da tela inicial, é possível transitar para a tela de processamento e, posteriormente, adentrar no modo contínuo. Esse caminho é visto ao desligar o sistema no modo contínuo, retendo o estado anterior ao desligamento e retornando ao mesmo ao ser ligado.

<p align="center">
  <img src="Imagens/Interface-Usuario-Fluxograma.jpg" alt=Fluxo da interface do usuario="500" height="500">
</p>
<p align="center"><strong>Fluxograma da interface do usuário</strong></p>

</p>
</div>

<!-- SOLUÇÃO GERAL DO PROJETO -->

<div id="solucao-geral"> 
<h2> Solução Geral do projeto</h2>

<p align="justify"> 

A solução integral implementada neste sistema evidencia sua completa capacidade em atender a todas as demandas específicas. Antes de ingressar no loop principal, são atribuídos valores iniciais aos três registradores que representam a tela atual, o comando selecionado e o endereço selecionado. Adicionalmente, o software inicia o processo inicializando a GPIO, atribuindo direções aos 11 pinos utilizados, configurando a UART para comunicação serial, e ajustando o LCD para a configuração de 4 bits, abrangendo as duas linhas de exibição.

No interior do loop principal, o sistema inicia buscando e exibindo a tela correspondente ao registrador de tela atual. Após a exibição, passa para a fase de verificação para determinar se é necessária uma troca de tela. Nesse contexto, são inicialmente avaliados os casos de troca de tela que não envolvem o clique dos botões: a transição para o modo contínuo em caso de dados inesperados (indicando que o modo contínuo está ativo) e a espera dos dados serem recebidos (por 2,5 segundos). No último caso, além da troca para a tela de resposta, ocorre a transmissão e recebimento de dados.

Antes de fazer a verificação dos botões, é verificado se o sistema está na tela de modo contínuo (seja de temperatura ou umidade). Se estiver, ele aguarda por 2,5 segundos, e durante essa contagem, verifica se houve algum clique de botão, realizando as trocas necessárias.

Após essas verificações, são analisados os casos de troca de tela associados aos botões, possibilitando avançar, retroceder ou trocar de opção. Após a execução ou não da troca de tela, o sistema retorna ao início do loop principal.

Para uma compreensão mais clara da explicação, apresentamos abaixo um fluxograma detalhando o algoritmo utilizado na solução geral.

<p align="center">
  <img src="Imagens/Solucao-Geral.png">
</p>
<p align="center"><strong> Fluxograma da solução geral do problema </strong></p>
</p>
</div>

<div id=""> 
<h2> Testes Realizados</h2>

<p align="justify"> 

</p>
</div>

<div id=""> 
<h2> Conclusão</h2>

<p align="justify"> 

</p>
</div>

<div id=""> 
<h2> Execução do Projeto</h2>
 
<p align="justify"> 

Para iniciar o projeto, siga os passos abaixo para obter o código-fonte, compilar o código Assembly e configurar a parte da FPGA para o controle do sensor em um dispositivo SBC Orange Pi PC Plus.

**Passo 1: Clonar o Repositório**
Abra o terminal e execute o seguinte comando para obter o código do repositório:

    git clone https://github.com/TAlmeida003/PBL-Sistemas-Digitais-Interface-de-Entrada-e-Saida.git

**Passo 2: Acessar o Diretório e Compilar o Código Assembly**

    cd PBL-Sistemas-Digitais-Interface-de-Entrada-e-Saida\Fase 2 - Interface de Teste em Assembly\Assembly

Compile o código usando o comando:

    make all
  
**Passo 3: Configurar a FPGA para o Controle do Sensor**

Para realizar a configuração da FPGA visando o controle do sensor, consulte o arquivo README para obter instruções detalhadas. . O README está disponível no seguinte link:

    https://github.com/TAlmeida003/PBL-Sistemas-Digitais-Interface-de-Entrada-e-Saida/blob/main/README.md    
</p>
</div>

<div id=""> 
<h2> Referências</h2>

<p align="justify"> 

</p>
</div>






