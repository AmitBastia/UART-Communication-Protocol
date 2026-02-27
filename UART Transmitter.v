module uart_transmitter(
    input clk, 
    input wr_en, 
    input rst, 
    input enb, 
    input[7:0] data_in, 
    output reg tx, 
    output busy
);
    
    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;
    
    reg [7:0] data;
    reg [2:0] index;
    reg [1:0] state;
    reg transmitting;
    
    assign busy = transmitting;
    
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                begin
                    tx <= 1'b1;
                    state <= idle_state;
                    index <= 3'h0;
                    data <= 8'h0;
                    transmitting <= 1'b0;
                end
            else
                begin
                    case(state)
                        idle_state:
                            begin
                                tx <= 1'b1;
                                index <= 3'h0;
                                transmitting <= 1'b0;
                                if(wr_en)
                                    begin
                                        data <= data_in;
                                        state <= start_state;
                                        transmitting <= 1'b1;
                                    end
                            end
                            
                        start_state:
                            begin 
                                if(enb)
                                    begin
                                        tx <= 1'b0;
                                        state <= data_state;
                                    end
                            end
                            
                        data_state:
                            begin
                                if(enb) 
                                    begin
                                        tx <= data[index];  // Send current bit FIRST
                                        if(index == 3'h7)
                                            state <= stop_state;
                                        else
                                            index <= index + 1'b1;
                                    end
                            end
                            
                         stop_state:
                            begin
                                if(enb)
                                    begin
                                        tx <= 1'b1;
                                        state <= idle_state;
                                    end
                            end
                         
                         default:
                            begin
                                tx <= 1'b1;
                                state <= idle_state;
                            end
                    endcase
               end
       end
endmodule
