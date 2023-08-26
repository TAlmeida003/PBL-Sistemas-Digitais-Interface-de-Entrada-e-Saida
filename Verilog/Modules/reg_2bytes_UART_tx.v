module reg_2bytes_UART_tx (
    input clk,
    input enable,
    input [7:0]  byte_one,
    input [7:0]  byte_two,
    input        done_tx,
    output [7:0] data,
    output       done
);
    
    localparam IDLE     = 3'b000,   
               BYTE_ONE = 3'b001,
               START_ONE    = 3'b010,
               BYTE_TWO = 3'b011,
               START_TWO = 3'b100;
    
    reg [2:0] state = 0;
    reg [7:0] data_aux = 0;
    reg byte_sent = 0;
    reg [15:0] buffer = 0;

    assign done = byte_sent;
    assign data = data_aux;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                byte_sent <= 0;

                if (enable) begin
                    state <= BYTE_ONE;
                    data_aux <= buffer[7:0];
                    buffer <= {byte_two, byte_one};
				end
                else begin
                    state <= IDLE;
					buffer <= 16'd0;
				end
            end
            BYTE_ONE: begin
                data_aux <= buffer[7:0];
                state <= START_ONE;
                byte_sent <= 1;
            end
            START_ONE : begin
                byte_sent <= 0;
                if (done_tx) begin
                    state <= BYTE_TWO;
                end
                else begin
                    state <= START_ONE;
				end
            end
            BYTE_TWO:begin
                byte_sent <= 1;
                 data_aux <= buffer[15:8];
                state <= START_TWO;
            end
            START_TWO : begin
                byte_sent <= 0;
                if (done_tx) begin
                    state <= IDLE;
                end
                else begin
                    state <= START_TWO;
				end
            end
            default: state <= IDLE;
        endcase
    end  

endmodule