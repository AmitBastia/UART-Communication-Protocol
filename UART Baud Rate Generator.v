module baud_rate_generator(
    input clk, 
    input rst, 
    output reg rx_enb, 
    output reg tx_enb
);
    
    parameter clk_frequency = 100000000;
    parameter baud_rate = 9600;
    parameter cycles_per_bit = clk_frequency / baud_rate;  // 10416
    
    parameter rx_oversample = 16;
    parameter rx_cycles_per_bit = cycles_per_bit / rx_oversample;  // 651
    
    reg [13:0] tx_counter;
    reg [13:0] rx_counter;
    
    // TX enable - one pulse every baud period
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                begin
                    tx_counter <= 0;
                    tx_enb <= 1'b0;
                end
            else
                begin
                    if(tx_counter >= cycles_per_bit - 1)
                        begin
                            tx_counter <= 0;
                            tx_enb <= 1'b1;  // Single cycle pulse
                        end
                    else
                        begin
                            tx_counter <= tx_counter + 1'b1;
                            tx_enb <= 1'b0;
                        end
                end
        end
        
    // RX enable - 16x oversampling
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                begin
                    rx_counter <= 0;
                    rx_enb <= 1'b0;
                end
            else
                begin
                    if(rx_counter >= rx_cycles_per_bit - 1)
                        begin
                            rx_counter <= 0;
                            rx_enb <= 1'b1;  // Single cycle pulse
                        end
                    else
                        begin
                            rx_counter <= rx_counter + 1'b1;
                            rx_enb <= 1'b0;
                        end
                end
        end  
            
endmodule
