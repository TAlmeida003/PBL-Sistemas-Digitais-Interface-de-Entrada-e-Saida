<h1 align="center"> Sistema de Temperatura e Umidade </h1>
<h3 align="center"> Projeto de interface homem-máquina em Orange Pi PC Plus usando linguagem Assembly  </h3>

<div id="sobre-o-projeto"> 
<h2> Sobre o Projeto</h2>

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
        <li><a href="#"> UART </a></li>
        <li><a href="#displayLCD"> Display LCD </a></li>
        <li><a href="#"> Solução Geral do projeto </a></li>
        <li><a href="#"> Testes Realizados </a></li>
        <li><a href="#"> Conclusão </a></li>
        <li><a href="#"> execução do projeto </a></li>
        <li><a href="#"> Referências </a></li>
	</ul>	
</div>

<div id=""> 
<h2> Descrição dos equipamentos e software utilizados</h2>
<p align="justify"> 

</p>
</div>

<div id=""> 
<h2> Mapeamento de memória</h2>
<p align="justify"> 

</p>
</div>

<div id="GPIO"> 
<h2> GPIO</h2>
<p align="justify"> 

A Entrada/Saída de Propósito Geral (GPIO) representa uma interface com pinos que podem ser configurados tanto como entrada quanto como saída de dados, conferindo flexibilidade para interagir com componentes externos no sistema digital da SBC Orange Pi PC Plus. Além disso, destaca-se a presença de hardware integrado na pinagem, oferecendo opções adicionais de configuração para os pinos. No total, são disponibilizados 28 pinos, divididos em 7 tipos (PA, PC, PD, PE, PF, PG e PL). Esses pinos podem ser manipulados tanto a nível de software quanto diretamente via registrado.

Para atender aos objetivos do projeto, foram utilizados apenas 11 pinos, sendo 7 do tipo PA e 4 do tipo PG. Esses pinos foram distribuídos em diversas funcionalidades específicas: 2 pinos do tipo PA foram dedicados à comunicação via padrão Universal Asynchronous Receiver/Transmitter (UART); 6 pinos foram alocados para o controle do LCD, sendo 2 do tipo PA e 4 do tipo PG; e os 3 pinos restantes do tipo PA foram destinados aos botões de controle da interface do projeto.

Para visualizar a distribuição dos pinos e suas funções designadas, está anexado uma imagem apresentando o diagrama de pinagem da Orange Pi, destacando os pinos utilizados e suas respectivas funções na resolução do problema.

![Alt text](Imagens/Diagrama-pinos.png)
<p align="center"><strong> Diagrama da pinagem da Orange Pi e as respectivos funções de cada pino no projeto</strong> </p>

<h3>Configuração da Direção do Pino</h3>	

Para empregar cada pino com suas funções designadas, é essencial configurar a direção de cada pino individualmente. A definição da direção do pino é realizada por meio da manipulação de registradores. Nesse contexto, cada pino tem 3 bits reservados nos registradores para indicar seu comportamento. Importante notar que nem todos os pinos oferecem as mesmas opções de seleção, pois alguns estão reservados para funções específicas, como no caso da UART.

Na solução adotada para o projeto, optou-se por configurar os pinos de acordo com as seguintes definições:

* **Entrada:** identificada pela sequência de bits 000; 
* **Saída:** representada pela sequência de bits 001;
* **UART:** caracterizada pela sequência de bits 011.

A atribuição desses valores foi realizada seguindo uma sequência lógica de 4 passos. Nesse sentido, segue em anexo um fluxograma que ilustra a lógica utilizada, bem como a explicação dos passos:

![Alt text](Imagens/Diracao-do-pino.png)
<p align="center"><strong> Fluxograma da configuração da direção do pino </strong> </p>

O processo de atribuição desses valores segue uma lógica em quatro passos. Inicialmente, o fluxograma inicia-se com uma solicitação ao Sistema Operacional por meio de uma *syscall*, buscando a referência virtual do endereço base da GPIO. Uma vez obtido esse endereço, realiza-se um deslocamento dentro da página da GPIO para encontrar o *offset* onde está localizado o registrador da direção. Dado que existem múltiplas referências de direção nesse registrador, é necessário um deslocamento adicional para localizar os 3 bits correspondentes ao pino desejado. Por fim, esses 3 bits são adicionados ao local apropriado e salvos no registrador, configurando assim a direção desejada para o pino.


<h3>Leitura/Escrita do Valor Lógico do Pino</h3>	

O processo de leitura ou escrita de um pino na GPIO segue uma abordagem semelhante à configuração da direção do pino. Nesse contexto, o valor lógico do pino é representado por um único bit, armazenado em um registrador na memória física, exclusivamente designado para os dados dos pinos. Cabe ressaltar que esse registrador de dados é organizado por tipos de pinos, com os tipos PA sendo alocados em um registrador diferente dos pinos PG. Além disso, dentro do registrador, os dados são organizados tendo a referência do pino, por exemplo, o pino PA0 é guardado na posição 0 do registrador.

Para compreender melhor o fluxo de escrita ou leitura dos valores dos pinos na Orange Pi, segue um fluxograma explicativo:

![Alt text](Imagens/Leitura-escrita-pino.png)
<p align="center"><strong> Fluxograma da leitura/escrita do valor lógico do pino</strong> </p>
 
O fluxograma inicia-se com uma solicitação ao Sistema Operacional por meio de uma *syscall*, buscando a referência virtual do endereço base da GPIO. Após adquirir o endereço, há um deslocamento dentro da página para encontrar o *offset* do registrador de dados. Considerando que existem múltiplas referências desse registrador, um deslocamento adicional é necessário para localizar o bit correspondente ao pino desejado. Uma vez identificado o local correto, o valor lógico do pino é escrito ou lido, dependendo da operação desejada. Este processo é concluído ao salvar ou recuperar o valor no registrador, ajustando assim o estado lógico do pino conforme necessário.

<h3>Inicialização da GPIO no Projeto</h3>	

Na fase inicial do projeto, o processo de inicialização segue a atribuição de direção para os 11 pinos essenciais. Para fornecer uma visão clara dessa configuração, apresenta-se a seguir uma tabela detalhando a relação entre a pinagem utilizada e suas respectivas direções:

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

<p align="center">
<strong> Tabela com as direções e funções de cada pino</strong> </p>
 
</p>
</div>

<div id=""> 
<h2> UART</h2>

<p align="justify"> 

</p>
</div>

<!-- DISPLAY LCD -->

<div id="displayLCD"> 
<h2> Display LCD</h2>

<p align="justify"> 

O display LCD utilizado pode ser configurado para ser acionado sob o controle de um microprocessador de 4 ou 8 bits. No modo de 8 bits, os oito pinos de dados são usados para escrever informações de maneira paralela, enquanto no modo de 4 bits os dados são processados em duas etapas: primeiramente, é transmitido um conjunto de 4 bits de informações, e depois os 4 bits restantes. 

<h3>Inicialização do LCD</h3>	

Quanto à inicialização do LCD, é primordial configurar o controlador no modo de 4 bits, uma vez que ele inicia automaticamente no modo de 8 bits, independentemente do número de linhas de dados conectadas entre o controlador e o módulo LCD. O procedimento de inicialização é delineado da seguinte forma:

1. Ao aplicar a energia pela primeira vez, é necessário aguardar 100 ms, pois a ativação requer um atraso significativo;

2. Os quatro passos subsequentes são semelhantes e constituem a configuração do modo de 4 bits. No primeiro passo, envia-se o comando SET **(0x03)** para reiniciar efetivamente o controlador do LCD, sendo os 4 bits inferiores irrelevantes no modo de 4 bits. Após o envio da função, é necessário um atraso de 5 ms;

3. Na segunda instância do comando SET **(0x03)**, é exigido um atraso de 150 µs;

4. Na terceira instância, o tempo de atraso é o mesmo, mas o controlador já reconhece que se trata de uma função de *reset* e está pronto para receber a instrução "real";

5. Por fim, é enviado o comando SET **(0x02)** para entrar no modo de 4 bits, indicando que o controlador LCD lerá apenas os quatro pinos de dados superiores a cada uso do Enable. O atraso necessário nesse envio é de 150 µs;

6. Em seguida, envia-se o comando para habilitar as duas linhas **(0x28)**;

7. Posteriormente, o comando de controle *liga/desliga* do display **(0x08)** é utilizado para desligar o display;

8. Após isso, procede-se à limpeza do display **(0x01)**;

9. A instrução subsequente configura o modo de entrada, determinando que o cursor e/ou display deve mover-se à direita ao inserir uma sequência de caracteres **(0x06)**;

10. A sequência de inicialização é concluída, sendo crucial notar que o display permanece ligado. Como último passo, envia-se a instrução para ligar o display e apagar o cursor **(0x0C)**.

Abaixo, apresenta-se o fluxograma da inicialização do LCD, resumindo de maneira clara o passo a passo desse processo e seu fluxo.

<p align="center">
  <img src="Imagens/Inicializacao-LCD.jpg" alt=Fluxograma da inicialização do LCD="300" height="300">
</p>
<p align="center"><strong>Fluxograma da inicialização do Display LCD</strong></p>


<h3>Escrita no LCD</h3>

No que refere-se à fase de escrita, o procedimento inicial é a posição do cursor na primeira linha, através do envio do comando **(0x80)**. Posteriormente, utiliza-se uma função específica para transmitir a frase ao LCD. Se a extensão da frase for inferior a 17 caracteres, a escrita é efetuada diretamente no LCD. No entanto, caso a frase exceda esse limite, realiza-se um deslocamento dos caracteres até que a totalidade da mensagem seja visível. O retorno ao ponto inicial ocorre ao término da escrita da frase. Caso um botão seja pressionado, essa visualização é interrompida e a mudança de tela é realizada.

O fluxograma abaixo apresenta de maneira visual o processo de escrita em uma linha do LCD.

<p align="center">
  <img src="Imagens/Escrita-LCD-Uma-Linha.jpg" alt=Fluxograma escrita em uma linha="300" height="300">
</p>
<p align="center"><strong>Fluxograma da escrita de uma linha no Display LCD</strong></p>

Para a escrita na segunda linha, o cursor é posicionado ao enviar o comando **(0xC0)**. Em seguida, realiza-se uma comparação do tamanho da frase e segue-se a mesma verificação descrita anteriormente, para o caso da primeira linha. Este processo está exemplificado no fluxograma a seguir, que trata-se da escrita nas duas linhas do Display. Após o envio de ambas as frases, uma verificação é realizada para determinar se a escrita foi concluída. Em caso afirmativo, o procedimento é encerrado. Caso contrário, ocorre o deslocamento dos caracteres da frase em questão.

<p align="center">
  <img src="Imagens/Escrita-LCD-Duas-Linhas.jpg" alt=Fluxograma da escrita em duas linhas="300" height="300">
</p>
<p align="center"><strong>Fluxograma da escrita em duas linhas no Display LCD</strong></p>

</p>
</div>


<div id="interfaceUsuario"> 
<h2> Interface do Usuário </h2>

<p align="justify"> 

<h2>Fluxo Normal</h2>

No contexto do fluxo normal, a interação tem início na tela inicial, visualizável abaixo.

Ao acionar o botão do meio, a transição ocorre para a tela de comando. Nessa interface, o usuário possui a opção de retornar à tela inicial, caso esteja no comando 01 e pressionar o botão de retorno (botão esquerdo). Ao utilizar o botão de avançar (botão direito), a progressão entre os comandos disponíveis, numerados de 01 a 07, é possibilitada. O botão de confirmar permite o avanço para a próxima tela com o comando escolhido.

Na tela seguinte, destinada à escolha de um endereço, o usuário tem a alternativa de retornar ao menu de comandos, caso esteja no endereço 00, ou percorrer os endereços disponíveis, numerados de 00 a 31, utilizando os botões de avançar e retornar, respectivamente. Ao selecionar um endereço e pressionar o botão "ok", a transição direciona-se para a tela de processamento das informações recebidas.

Após a conclusão do processamento, a tela de resposta é apresentada, exibindo a resposta correspondente ao comando escolhido. Ao pressionar o botão "ok", o usuário retorna à tela de comandos.


<h2>Fluxo Contínuo</h2>

Por outro lado, no cenário do fluxo contínuo, ao optar pelo comando de iniciar o sensoriamento contínuo e selecionar o endereço do sensor, a transição ocorre diretamente da tela de processamento para a tela de comando contínuo. Nessa interface, a escolha do comando é apresentada na primeira linha, enquanto a segunda linha exibe a resposta, indicando a medida de temperatura, umidade, ou uma resposta específica.

Após a seleção do comando, a navegação prossegue para a tela de endereço, mantendo a mesma lógica do fluxo normal. As respostas continuam a ser exibidas na segunda linha dessa tela. Em seguida, o fluxo avança para a tela de processamento, que oferece as opções de comando incorreto, endereço incorreto ou desativação do sensoriamento contínuo. Caso a escolha seja uma das duas primeiras opções, ao pressionar o botão "ok", permanece na tela de contínuo. Se a opção for a última, retorna à tela de comandos do fluxo normal.

</p>
</div>

<!-- SOLUÇÃO GERAL DO PROJETO -->

<div id=""> 
<h2> Solução Geral do projeto</h2>

<p align="justify"> 

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






