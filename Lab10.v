`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2019 10:32:10 PM
// Design Name: 
// Module Name: Lab10
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


module Lab10(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output I2C_SCL_1,
    inout I2C_SDA_1,
    output PMOD_A1,
    output PMOD_A2,
    output CVM300_SPI_CLK,
    output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input CVM300_SPI_OUT,  
    output CVM300_CLK_IN,
    input CVM300_CLK_OUT,
    input CVM300_Line_valid,
    input CVM300_Data_valid,
    input [9:0] CVM300_D,
    output reg CVM300_SYS_RES_N,
    output reg CVM300_FRAME_REQ,
    output reg CVM300_Enable_LVDS,
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA
);
    
    wire clk;
    wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication    
    wire  ILA_Clk, ACK_bit, FSM_Clk, Motor_Clk, Image_Clk, TrigerEvent;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SCL, SDA; 
    wire Trigger;
    wire direction;
    wire [31:0] pwm_frequency, pulse_num, pwm;
    
    wire [7:0] x_neg_a;
    wire [7:0] x_pos_a; 
    wire [7:0] y_neg_a;
    wire [7:0] y_pos_a;
    wire [7:0] z_neg_a;
    wire [7:0] z_pos_a;
    
    wire [7:0] x_neg_m;
    wire [7:0] x_pos_m;
    wire [7:0] y_neg_m;
    wire [7:0] y_pos_m;
    wire [7:0] z_neg_m;
    wire [7:0] z_pos_m;
    
    reg [7:0] x_neg_a1;
    reg [7:0] x_pos_a1; 
    reg [7:0] y_neg_a1;
    reg [7:0] y_pos_a1;
    reg [7:0] z_neg_a1;
    reg [7:0] z_pos_a1;
    
    reg [7:0] x_neg_m1;
    reg [7:0] x_pos_m1; 
    reg [7:0] z_neg_m1;
    reg [7:0] z_pos_m1;
    reg [7:0] y_neg_m1;
    reg [7:0] y_pos_m1;
    
    wire [31:0] pulse_count_out;
    reg [31:0] pusle_count_data;
    
    reg Motor_Clk_reg;
    reg Image_Clk_reg;
    
    wire [8:0] State;
    
    wire [7:0] Final_1;
    wire [7:0] Final_2;
    wire [15:0] Final_3;
    wire [6:0] Address_1;
    wire [6:0] Address_2;
    wire [7:0] Data_1;
    wire [7:0] Data_2;
    wire Trigger_img;
    wire Control;

    
    always @ (*) begin
        
        Motor_Clk_reg = Motor_Clk;
        Image_Clk_reg = Image_Clk;
        pusle_count_data = pulse_count_out;
        
        x_neg_a1 = x_neg_a;
        x_pos_a1 = x_pos_a;
        y_neg_a1 = y_neg_a;
        y_pos_a1 = y_pos_a;
        z_neg_a1 = z_neg_a;
        z_pos_a1 = z_pos_a;
        
        x_neg_m1 = x_neg_m;
        x_pos_m1 = x_pos_m;
        z_neg_m1 = z_neg_m;
        z_pos_m1 = z_pos_m;
        y_neg_m1 = y_neg_m;
        y_pos_m1 = y_pos_m;
    end    
 
    assign TrigerEvent = button[3];

    //Instantiate the module that we like to test
    I2C_Transmit I2C_Test1 (
        .button(button),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .I2C_SCL_1(I2C_SCL_1),
        .I2C_SDA_1(I2C_SDA_1),             
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .ACK_bit(ACK_bit),
        .SCL(SCL),
        .SDA(SDA),
        .x_neg_a(x_neg_a),
        .x_pos_a(x_pos_a),
        .y_neg_a(y_neg_a),
        .y_pos_a(y_pos_a),
        .z_neg_a(z_neg_a),
        .z_pos_a(z_pos_a),
        .x_neg_m(x_neg_m),
        .x_pos_m(x_pos_m),
        .y_neg_m(y_neg_m),
        .y_pos_m(y_pos_m),
        .z_neg_m(z_neg_m),
        .z_pos_m(z_pos_m),
        .State(State),
        .Trigger(Trigger),
        .Motor_Clk_reg(Motor_Clk),
        .Image_Clk_reg(Image_Clk),
        .pwm_frequency(pwm_frequency)
        );
        
    motor motor(
        .PMOD_A1(PMOD_A1),
        .PMOD_A2(PMOD_A2),
        .Motor_Clk(Motor_Clk_reg),
        .direction(direction),
        .pulse_num(pulse_num),
        .pwm(pwm),
        .pulse_count_out(pulse_count_out)
        );
    
    Image image(
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .Trigger(Trigger_img),
        .Control(Control),
        .Image_Clk(Image_Clk_reg),
        .SPI_EN(CVM300_SPI_EN),
        .SPI_IN(CVM300_SPI_IN),
        .SPI_CLK(CVM300_SPI_CLK),
        .SPI_OUT(CVM300_SPI_OUT),
        .Address_1(Address_1),
        .Address_2(Address_2),
        .Data_1(Data_1),
        .Data_2(Data_2),
        .Final_1(Final_1),
        .Final_2(Final_2),
        .Final_3(Final_3)
        );

    //Instantiate the ILA module
    ila_1 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({State, SDA, SCL, ACK_bit}),                             
        .probe1({ILA_Clk, Trigger})
        );    
        
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );    
    
    localparam  endPt_count = 10;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx); 
    
        okWireIn wire10 (   .okHE(okHE), 
                        .ep_addr(8'h00), 
                        .ep_dataout(Trigger));
                        
        okWireIn wire11 (   .okHE(okHE), 
                        .ep_addr(8'h01), 
                        .ep_dataout(direction));
                        
        okWireIn wire12 (   .okHE(okHE), 
                        .ep_addr(8'h02), 
                        .ep_dataout(pwm_frequency));
                        
        okWireIn wire13 (   .okHE(okHE), 
                        .ep_addr(8'h03), 
                        .ep_dataout(pulse_num));
                        
        okWireIn wire14 (   .okHE(okHE), 
                        .ep_addr(8'h04), 
                        .ep_dataout(pwm));   
                        
        okWireIn wire15 (   .okHE(okHE), 
                        .ep_addr(8'h05), 
                        .ep_dataout(Trigger_img)); 
                        
        okWireIn wire16 (   .okHE(okHE), 
                        .ep_addr(8'h06), 
                        .ep_dataout(Control));   
    
        okWireIn wire17 (   .okHE(okHE), 
                        .ep_addr(8'h07), 
                        .ep_dataout(Address_1));
    
        okWireIn wire18 (   .okHE(okHE), 
                        .ep_addr(8'h08), 
                        .ep_dataout(Address_2));
                        
        okWireIn wire19 (   .okHE(okHE), 
                        .ep_addr(8'h09), 
                        .ep_dataout(Data_1));
    
        okWireIn wire1A (   .okHE(okHE), 
                        .ep_addr(8'h10), 
                        .ep_dataout(Data_2));                
                        
                                                                                       
    
        okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain({x_pos_a1, x_neg_a1}));
                        
        okWireOut wire21 (  .okHE(okHE), 
                        .okEH(okEHx[ 1*65 +: 65 ]),
                        .ep_addr(8'h21), 
                        .ep_datain({y_pos_a1, y_neg_a1}));
                        
        okWireOut wire22 (  .okHE(okHE), 
                        .okEH(okEHx[ 2*65 +: 65 ]),
                        .ep_addr(8'h22), 
                        .ep_datain({z_pos_a1, z_neg_a1}));
                        
        okWireOut wire23 (  .okHE(okHE), 
                        .okEH(okEHx[ 3*65 +: 65 ]),
                        .ep_addr(8'h23), 
                        .ep_datain({x_pos_m1, x_neg_m1}));
                        
        okWireOut wire24 (  .okHE(okHE), 
                        .okEH(okEHx[ 4*65 +: 65 ]),
                        .ep_addr(8'h24), 
                        .ep_datain({y_pos_m1, y_neg_m1}));
                        
        okWireOut wire25 (  .okHE(okHE), 
                        .okEH(okEHx[ 5*65 +: 65 ]),
                        .ep_addr(8'h25), 
                        .ep_datain({z_pos_m1, z_neg_m1}));                
        
        okWireOut wire26 (  .okHE(okHE), 
                        .okEH(okEHx[ 6*65 +: 65 ]),
                        .ep_addr(8'h26), 
                        .ep_datain({pusle_count_data}));
                        
        
        
        localparam STATE_INIT                = 8'd0;
        localparam STATE_RESET               = 8'd1;   
        localparam STATE_DELAY               = 8'd2;
        localparam STATE_RESET_FINISHED      = 8'd3;
        localparam STATE_ENABLE_WRITING      = 8'd4;
        localparam STATE_COUNT               = 8'd5;
        localparam STATE_FINISH              = 8'd6;
        localparam STATE_FRAME_REQ           = 8'd7;
        localparam STATE_FRAME_REQ_FINISH    = 8'd8;
        localparam STATE_RESET_2             = 8'd9;   
        localparam STATE_DELAY_2             = 8'd10;
        localparam STATE_RESET_FINISHED_2    = 8'd11;
   
    
    reg [31:0] counter = 32'd0;
    reg [15:0] counter_delay = 16'd0;
    reg [7:0] State_img = STATE_INIT;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg;
    reg [31:0] write_enable_counter;  
    reg write_reset, read_reset, write_enable;
    wire [31:0] Reset_Counter;
    wire Frame_req_flag;
    wire [31:0] DATA_Counter;    
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    wire [31:0] FIFO_data_out;
    reg [11:0] loop;
    reg [1:0] loop2;
    reg [2:0] loop3;
    
    assign led[0] = ~FIFO_empty; 
    assign led[1] = ~FIFO_full;
    assign led[2] = ~FIFO_BT_BlockSize_Full;
    assign led[3] = ~FIFO_read_enable;  
    assign led[7] = ~read_reset;
    assign led[6] = ~write_reset;
    assign led[4] = CVM300_Data_valid;
    assign led[5] = CVM300_Line_valid;
    
    
    initial begin
        write_reset <= 1'b0;
        read_reset <= 1'b0;
        write_enable <= 1'b1;
        CVM300_FRAME_REQ <= 1'b0;  
        CVM300_Enable_LVDS <= 1'b0; 
        CVM300_SYS_RES_N <= 1'b1;
        loop <= 12'b0;
        loop2 <= 1'b0;
        loop3 <= 1'b0; 
    end
    
                                         
    always @(posedge ~CVM300_CLK_OUT) begin     
        if (Reset_Counter[0] == 1'b1) State_img <= STATE_RESET;
        
        case (State_img)
            STATE_INIT:   begin                              
                write_reset <= 1'b1;
                read_reset <= 1'b1;
                write_enable <= 1'b0;
                if (Reset_Counter[0] == 1'b1) State_img <= STATE_RESET;                
            end
            
            STATE_RESET:   begin
                counter <= 0;
                counter_delay <= 0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;
                write_enable <= 1'b0;                
                if (Reset_Counter[0] == 1'b0) State_img <= STATE_RESET_FINISHED;             
            end                                     
 
           STATE_RESET_FINISHED:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;                 
                State_img <= STATE_DELAY;                                   
            end   
                          
            STATE_DELAY:   begin
                if (counter_delay == 16'b0000_0000_0000_1111)  State_img <= STATE_FRAME_REQ;
                else counter_delay <= counter_delay + 1;
            end
            
            STATE_FRAME_REQ: begin
                if (Frame_req_flag == 1'b1) 
                
                begin
                CVM300_FRAME_REQ <= 1'b1;
                State_img <= STATE_FRAME_REQ_FINISH;
                
                end
            
            end
            
            STATE_FRAME_REQ_FINISH: begin
                if (Frame_req_flag == 1'b0) 
                
                begin
                CVM300_FRAME_REQ <= 1'b0;
                State_img <= STATE_ENABLE_WRITING;
                
                end
            
            end
            
             STATE_ENABLE_WRITING:   begin
                write_enable <= 1'b1;
                write_enable_counter <= 32'b0;
                State_img <= STATE_COUNT;
             end
                                  
             STATE_COUNT:   begin
             
                    counter[0] <= CVM300_D[0];
                    counter[1] <= CVM300_D[1];
                    counter[2] <= CVM300_D[2];
                    counter[3] <= CVM300_D[3];
                    counter[4] <= CVM300_D[4];
                    counter[5] <= CVM300_D[5];
                    counter[6] <= CVM300_D[6];
                    counter[7] <= CVM300_D[7];
//                if (loop3 == 0) begin
//                    counter[0] <= CVM300_D[0];
//                    counter[1] <= CVM300_D[1];
//                    counter[2] <= CVM300_D[2];
//                    counter[3] <= CVM300_D[3];
//                    counter[4] <= CVM300_D[4];
//                    counter[5] <= CVM300_D[5];
//                    counter[6] <= CVM300_D[6];
//                    counter[7] <= CVM300_D[7];
//                    loop3 <= loop3 + 1'b1;
//                    write_enable_counter <= write_enable_counter + 1'b1;
//                    end
                    
//                else if (loop3 == 1) begin
                
//                    counter[8] <= CVM300_D[0];
//                    counter[9] <= CVM300_D[1];
//                    counter[10] <= CVM300_D[2];
//                    counter[11] <= CVM300_D[3];
//                    counter[12] <= CVM300_D[4];
//                    counter[13] <= CVM300_D[5];
//                    counter[14] <= CVM300_D[6];
//                    counter[15] <= CVM300_D[7];
//                    loop3 <= loop3 + 1'b1;
//                    write_enable_counter <= write_enable_counter + 1'b1;
//                    end
                    
//                else if (loop3 == 2) begin
                
//                    counter[16] <= CVM300_D[0];
//                    counter[17] <= CVM300_D[1];
//                    counter[18] <= CVM300_D[2];
//                    counter[19] <= CVM300_D[3];
//                    counter[20] <= CVM300_D[4];
//                    counter[21] <= CVM300_D[5];
//                    counter[22] <= CVM300_D[6];
//                    counter[23] <= CVM300_D[7];
//                    loop3 <= loop3 + 1'b1;
//                    write_enable_counter <= write_enable_counter + 1'b1;
//                    end
             
//                else if (loop3 == 3) begin
                
//                    counter[24] <= CVM300_D[0];
//                    counter[25] <= CVM300_D[1];
//                    counter[26] <= CVM300_D[2];
//                    counter[27] <= CVM300_D[3];
//                    counter[28] <= CVM300_D[4];
//                    counter[29] <= CVM300_D[5];
//                    counter[30] <= CVM300_D[6];
//                    counter[31] <= CVM300_D[7];
//                    loop3 <= loop3 + 1'b1;
//                    write_enable_counter <= write_enable_counter + 1'b1;
//                    end
                
                if (CVM300_Data_valid == 1'b1) begin
                    write_enable <= 1'b1;
                    write_enable_counter <= write_enable_counter + 1'b1;
                    //loop3 <= 1'b0;
                    end 

                    
                else if (CVM300_Data_valid == 1'b0) begin
                    write_enable <= 1'b0;
                end      
                

                                                                         
                if (write_enable_counter == 488*648)  
                begin
                State_img <= STATE_INIT;         
                end
               end
               
               
//             STATE_RESET_2:   begin
//                counter <= 0;
//                counter_delay <= 0;
//                write_reset <= 1'b1;
//                read_reset <= 1'b1;
//                write_enable <= 1'b0;                
//                State <= STATE_RESET_FINISHED_2;             
//            end                                     
 
//           STATE_RESET_FINISHED_2:   begin
//                write_reset <= 1'b0;
//                read_reset <= 1'b0;                 
//                State <= STATE_COUNT;                                   
//            end   

               
             STATE_FINISH:   begin                         
                 write_enable <= 1'b0;                                                           
            end

        endcase
    end    
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(~CVM300_CLK_OUT),
        .wr_rst(write_reset),
        .rd_clk(okClk),
        .rd_rst(read_reset),
        .din(counter),
        .wr_en(write_enable),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full),
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
      
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 9*65 +: 65 ]),
        .ep_addr(8'ha0), 
        .ep_datain(FIFO_data_out), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );                                      
    
    okWireIn wire1B (   .okHE(okHE), 
                        .ep_addr(8'h11), 
                        .ep_dataout(Reset_Counter));
                        
    okWireIn wire1C (   .okHE(okHE), 
                        .ep_addr(8'h12), 
                        .ep_dataout(Frame_req_flag));
                                         
                        
                        
    okWireOut wire27 (  .okHE(okHE), 
                        .okEH(okEHx[ 7*65 +: 65 ]),
                        .ep_addr(8'h27), 
                        .ep_datain(Final_1));
                        
    okWireOut wire28 (  .okHE(okHE), 
                        .okEH(okEHx[ 8*65 +: 65 ]),
                        .ep_addr(8'h28), 
                        .ep_datain(Final_2));   
                                                           
                        
endmodule                
                                       
                         