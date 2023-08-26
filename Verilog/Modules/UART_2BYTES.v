module UART_2BYTES(
    input        clk,
    input        input_rx,
	 output       tx_active,
    output       out_tx
);

	 wire        done_rx, done_2_rx, done_2_tx, done;
	 wire [7:0]  data, address, command;
	
	 wire  [7:0]  aux;
	
    UART_RX rx(clk, input_rx, done_rx, data);
    reg_2bytes_UART_rx reg_rx(clk, done_rx, data, address, command, done_2_rx);

    reg_2bytes_UART_tx reg_txkjnn(clk, done_2_rx, address, command, done, aux, done_2_tx);
    UART_TX lkm(clk, done_2_tx, aux, tx_active, out_tx, done);
    
    
endmodule