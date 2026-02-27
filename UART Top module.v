module uart_top(
    input rst, 
    input [7:0] data_in, 
    input wr_en, 
    input clk, 
    input rdy_clr, 
    output rdy, 
    output busy, 
    output[7:0] data_out
);
                
    wire rx_clk_en;
    wire tx_clk_en;
    wire tx_temp;
    
    
    baud_rate_generator bg(
        .clk(clk), 
        .rst(rst), 
        .rx_enb(rx_clk_en),   
        .tx_enb(tx_clk_en)    
    );
    
    
    uart_transmitter tx(
        .clk(clk), 
        .wr_en(wr_en), 
        .rst(rst),           
        .enb(tx_clk_en),     
        .data_in(data_in), 
        .tx(tx_temp), 
        .busy(busy)
    );
    
    uart_receiver rcv(
        .clk(clk), 
        .rst(rst), 
        .rx(tx_temp), 
        .rdy_clr(rdy_clr), 
        .clk_en(rx_clk_en), 
        .rdy(rdy), 
        .data_out(data_out)
    );
                    
endmodule
