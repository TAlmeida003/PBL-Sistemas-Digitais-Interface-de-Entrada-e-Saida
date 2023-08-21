module reg_2bytes_UART_rx(
    input        clk,
    input        new_data,
    input  [7:0] data,
    output [7:0] out_address,
    output [7:0] out_command,
    output reg   done
);
    localparam IDLE_1BYTE  = 2'b00,
               ADD_ADDRESS = 2'b01,
               IDLE_2BYTE = 2'b10,
               ADD_COMMAND = 2'b11;
    
    reg  [15:0] registrar = 16'b0;
    reg  [1:0]  state     = 2'b00;
    reg  [7:0]  buffer_data = 8'd0;

    assign out_command = registrar[15:8];
    assign out_address = registrar[7:0];

    always @(posedge clk) begin
        
        case (state)
            IDLE_1BYTE: begin
                done <= 0;

                if (new_data) begin
                    state <= ADD_ADDRESS;
                    buffer_data <= data;
                end
                else begin
                    state <= IDLE_1BYTE;
                end
            end 
            ADD_ADDRESS: begin
                done <= 0;
                registrar[15:8] <= buffer_data;

                if (!new_data) begin
                    state <= IDLE_2BYTE;
                end
                else begin
                    state <= ADD_ADDRESS;
                end
            end
            IDLE_2BYTE: begin
                done <= 0;
                
                if (new_data) begin
                    state <= ADD_COMMAND;
						  buffer_data <= data;
                end
                else begin
                    state <= IDLE_2BYTE;
                end
            end
            ADD_COMMAND: begin
                done <= 1;
                registrar[7:0] <= buffer_data;

                if (!new_data) begin
                    state <= IDLE_1BYTE;
                end
                else begin
                    state <= ADD_COMMAND;
                end
            end
            default: begin 
                state <= IDLE_1BYTE;
                registrar <= 16'b0;
                done <= 0;
            end
        endcase

    end
    
endmodule 