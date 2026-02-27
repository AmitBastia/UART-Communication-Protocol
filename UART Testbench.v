
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:42:50 PM
// Design Name: 
// Module Name: uart_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top_tb;

    reg clk, rst;
    reg [7:0] data_in;
    reg wr_en;
    wire rdy;
    reg rdy_clr;
    wire [7:0] dout;
    wire busy;
    uart_top dut(rst, data_in, wr_en, clk, rdy_clr, rdy, busy, dout);
    initial
        begin
            clk =0 ;
            rst = 0; 
            data_in = 0; 
            rdy_clr = 0;    
        end
        
        always #5 clk = ~clk;
        
        task send_byte(input [7:0] din);
            begin
                @(negedge clk)
                data_in = din;
                wr_en = 1'b1;
                
                @(negedge clk)
                wr_en = 0;
            end
        endtask
        
        task clear_ready;
            begin
                @(negedge clk)
                rdy_clr = 1'b1;
                @(negedge clk)
                rdy_clr = 1'b0;
            end
        endtask
        
        initial
            begin
            @(negedge clk)
            rst = 1'b1;
            @(negedge clk)
            rst = 1'b0;
            
            send_byte(8'h41);
            wait (!busy);
            wait (rdy);
            $display("Received data is %h", dout);
            clear_ready;
            
            send_byte(8'h55);
            wait (!busy);
            wait (rdy);
            $display("Received data is %h", dout);
            clear_ready;
            
            #400 $finish;
            end
    
endmodule
