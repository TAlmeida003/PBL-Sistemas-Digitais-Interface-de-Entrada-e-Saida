<h1 align="center"> Projetos de Interface de Entrada e Saída - TEC499 Sistemas Digitais </h1>

<div align="justify"> 
<div id="sobre-o-projeto"> 
<h2> Sobre o Repositório </h2>


Este repositório contém dois projetos relacionados à interface de entrada e saída, desenvolvidos como parte da disciplina TEC499 Sistemas Digitais. Cada projeto aborda aspectos específicos de comunicação e processamento de dados, Os projetos são:

* Projeto de Leitura de Sensor Digital em FPGA via Comunicação Serial;
* Sistema de Temperatura e Umidade com Interface Homem-Máquina.

</div>

</div>

<h2>  Equipe: <br></h2>
<uL> 
  <li><a href="https://github.com/Samara-Ferreira">Samara dos Santos Ferreira</a></li>
  <li><a href="https://github.com/Silviozv">Silvio Azevedo de Oliveira</a></li>
  <li><a href="https://github.com/SivalLeao">Sival Leão de Jesus</a></li>
  <li><a href="https://github.com/TAlmeida003">Thiago Neri dos Santos Almeida</a></li>
</ul>

<h1 align="center"> Sumário </h1>
<div id="sumario">
	<ul>
		<li><a href="#proj1"> Projeto 1: Leitura de Sensor Digital em FPGA via Comunicação Serial</li>
		<li><a href="#proj2"> Projeto 2: Sistema de Temperatura e Umidade com Interface Homem-Máquina </a></li>
    <li><a href="#conclusao"> Conclusão</a></li>
	</ul>	
</div>

<div id="proj1"> 
<h2> Projeto 1: Leitura de Sensor Digital em FPGA via Comunicação Serial</h2>
<div align="justify"> 

<h3>Sobre o Projeto</h3>

Neste projeto, um dispositivo FPGA Cyclone IV é utilizado para processar os dados de umidade e temperatura provenientes do sensor DHT11. A comunicação entre o sensor e o FPGA é realizada através de comunicação serial do tipo UART. O código implementado em linguagem C no computador permite o envio de comandos para a placa FPGA e a visualização dos dados obtidos.

<h3>Requisitos</h3>

* Implementação do código no computador em linguagem C;

* Capacidade de conexão até 32 endereços;

* Capacidade de configurar os sensores;

* Iniciação da comunicação pelo computador, exceto em casos de sensoriamento contínuo;

* Implementação do código da placa FPGA em linguagem Verilog, capaz de ler, interpretar e executar comandos enviados pelo computador;

* Comandos compostos por 1 byte cada, enquanto as requisições enviadas e respostas recebidas são compostas por 2 bytes.

[Leia a README do Projeto 1](<Fase 1 - Interface de Teste em C e codigo verilog/README.md>)
</div>
</div>

<div id="proj2"> 
<h2> Projeto 2: Sistema de Temperatura e Umidade com Interface Homem-Máquina</h2>
<div align="justify"> 

<h3>Sobre o Projeto</h3>

Este projeto tem como objetivo desenvolver uma interface homem-máquina (IHM) para o projeto da Fase 1. Utiliza-se o código em Verilog carregado na placa FPGA Cyclone IV para envio de comandos e processamento de dados do sensor DHT11. Um display LCD é empregado para apresentar a interface do sistema ao usuário. O processamento lógico é realizado em uma Orange Pi PC Plus, um computador de placa única.

<h3>Requisitos</h3>

* Implementação do código na Orange Pi PC Plus em linguagem Assembly.

* Utilização do display LCD para a interface do sistema.

* Restrição ao uso de dispositivos já presentes no protótipo montado.

* Utilização do mesmo código em Verilog carregado na placa FPGA Cyclone IV desenvolvido na Fase 1.

* Utilização do mesmo protocolo de comunicação entre a Orange Pi e a FPGA desenvolvido na Fase 1.

[Leia a README do Projeto 2](<Fase 2 - Interface de Teste em Assembly/README.md>)
</div>
</div>

<div id="conclusao"> 
<h2> Conclusão</h2>
<div align="justify"> 

Os projetos apresentados neste repositório demonstram um alto nível de desempenho e integração entre hardware e software. No Projeto 1, a comunicação serial entre o computador e o dispositivo FPGA foi eficiente, possibilitando a coleta estável de dados do sensor DHT11. Já no Projeto 2, a implementação da Interface Homem-Máquina (IHM) proporcionou uma solução intuitiva e robusta para monitoramento de temperatura e umidade. Ambos os projetos superaram as expectativas, destacando-se pela capacidade de operar em diversas condições e estabelecendo uma base sólida para futuros desenvolvimentos em sistemas digitais.

</div>
</div>
