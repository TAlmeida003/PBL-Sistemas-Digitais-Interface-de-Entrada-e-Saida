module reg_2bytes_UART_tx (
    input clk,
    input enable,
    input [7:0]  byte_one,
    input [7:0]  byte_two,
    input        done_tx,
    output [7:0] data,
    output       done
);
    
    localparam IDLE     = 2'b00,   
               BYTE_ONE = 2'b01,
               TEMPO    = 2'b10,
               BYTE_TWO = 2'b11;
    
    reg [1:0] state = 0;
    reg [7:0] data_aux = 0;
    reg byte_sent = 0;
    reg [15:0] buffer;

    assign done = byte_sent;
    assign data = data_aux;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                byte_sent <= 0;

                if (enable) begin
                    state <= BYTE_ONE;

                    buffer[15:8] <= byte_one;
                    buffer[7:0] <= byte_two;
					 end
                else begin
                    state <= IDLE;
					 end
            end
            BYTE_ONE: begin
                byte_sent <= 1;
                data_aux <= buffer[7:0];

                if (done_tx) begin
                    state <= TEMPO;
                end
                else
                    state <= BYTE_ONE;
            end
            TEMPO : begin
                byte_sent <= 0;
                if (!done_tx) begin
                    state <= BYTE_TWO;
                end
                else
                    state <= TEMPO;
            end
            BYTE_TWO:begin
                byte_sent <= 1;
                data_aux <= buffer[15:8];
                if (done_tx) begin
                    state <= IDLE;
                end
                else
                    state <= BYTE_TWO;
            end
            default: state <= IDLE;
        endcase
    end  

endmodule