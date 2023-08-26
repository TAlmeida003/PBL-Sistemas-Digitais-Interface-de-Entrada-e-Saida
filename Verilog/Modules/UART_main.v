module UART_main(
    input        clk,
    input        input_rx,
	output       tx_active,
    output       out_tx,
    output       done
);

	wire        done_rx;
	wire [7:0]  data;
	
	reg  [7:0]  aux;
	
    UART_RX rx(clk, input_rx, done_rx, data);
    UART_TX tx(clk, done_rx, data, tx_active, out_tx, done);
	
    
endmodule