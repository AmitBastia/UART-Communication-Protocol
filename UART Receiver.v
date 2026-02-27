module uart_receiver(
    input clk, 
    input rst, 
    input rx, 
    input rdy_clr, 
    input clk_en,          
    output reg rdy, 
    output reg [7:0] data_out
);

    parameter idle_state  = 2'b00;
    parameter start_state = 2'b01;
    parameter data_state  = 2'b10;
    parameter stop_state  = 2'b11;
    
    reg [1:0] state;
    reg [3:0] sample;          // 0-15 counter (16x)
    reg [2:0] index;           // 0-7 bit index
    reg [7:0] temp_register;
    reg rx_sync;
    
    // Synchronize RX to clock
    always @(posedge clk)
        rx_sync <= rx;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state <= idle_state;
            rdy <= 0;
            data_out <= 0;
            sample <= 0;
            index <= 0;
            temp_register <= 0;
        end
        else
        begin
            if(rdy_clr)
                rdy <= 0;

            if(clk_en)  // Only advance logic at oversampling tick
            begin
                case(state)

                    //--------------------------------------------------
                    // IDLE: Wait for falling edge (start bit)
                    //--------------------------------------------------
                    idle_state:
                    begin
                        sample <= 0;
                        index <= 0;

                        if(rx_sync == 0)  // Start bit detected
                            state <= start_state;
                    end

                    //--------------------------------------------------
                    // START: Move to middle of start bit
                    //--------------------------------------------------
                    start_state:
                    begin
                        if(sample == 4'd7)   // Middle of start bit
                        begin
                            sample <= 0;
                            state <= data_state;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    //--------------------------------------------------
                    // DATA: Sample 8 data bits
                    //--------------------------------------------------
                    data_state:
                    begin
                        if(sample == 4'd15)  // One full bit time
                        begin
                            sample <= 0;

                            // Sample bit at end of bit period
                            temp_register[index] <= rx_sync;

                            if(index == 3'd7)
                                state <= stop_state;
                            else
                                index <= index + 1'b1;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    //--------------------------------------------------
                    // STOP: Verify stop bit
                    //--------------------------------------------------
                    stop_state:
                    begin
                        if(sample == 4'd15)
                        begin
                            sample <= 0;

                            if(rx_sync == 1)  // Valid stop bit
                            begin
                                data_out <= temp_register;
                                rdy <= 1'b1;
                            end

                            state <= idle_state;
                        end
                        else
                            sample <= sample + 1'b1;
                    end

                    default:
                        state <= idle_state;

                endcase
            end
        end
    end

endmodule
