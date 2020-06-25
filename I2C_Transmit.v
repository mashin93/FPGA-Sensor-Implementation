`timescale 1ns / 1ps

module I2C_Transmit(
    input [3:0] button,
    input sys_clkn,
    input sys_clkp,
    output I2C_SCL_1,
    inout  I2C_SDA_1,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg Motor_Clk_reg,
    output reg Image_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,  
    output reg [7:0] x_neg_a,
    output reg [7:0] x_pos_a, 
    output reg [7:0] y_neg_a,
    output reg [7:0] y_pos_a,
    output reg [7:0] z_neg_a,
    output reg [7:0] z_pos_a,
    output reg [7:0] x_neg_m,
    output reg [7:0] x_pos_m,
    output reg [7:0] y_neg_m,
    output reg [7:0] y_pos_m,
    output reg [7:0] z_neg_m,
    output reg [7:0] z_pos_m,
    output reg [8:0] State,
    input Trigger,
    input [31:0] pwm_frequency
    );
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100;   
    wire FSM_Clk, ILA_Clk, Motor_Clk, Image_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk),
                                      .Image_Clk(Image_Clk),
                                      .Motor_Clk(Motor_Clk),
                                      .pwm_frequency(pwm_frequency)
                                       );
                                        
    reg [7:0] write_a;
    reg [7:0] read_a;
    reg [7:0] address_a;
    reg [7:0] ctrl_reg1;
    reg [7:0] ctrl_1;
    reg [7:0] data_temp = 8'b00000000;
    reg error_bit = 1'b1;   
    reg Status;   
    reg Mode; // 0 = accel, 1 = magnetic
       
    localparam STATE_INIT       = 8'd0;    
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA; 
    
    initial  begin
        SCL = 1'b1;
        State = 9'b0;
        SDA = 1'b1;
        ACK_bit = 1'b1; 
        Status = 1'b0; 
        Mode = 1'b0;
        write_a <= 8'b00110010; 
        read_a <= 8'b00110011; 
        address_a <= 8'h28; 
        ctrl_reg1 <= 8'b00100000;
        ctrl_1 <= 8'b01010111;  
    end
    
    
    always @(*) begin
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;
        Image_Clk_reg = Image_Clk;
        Motor_Clk_reg = Motor_Clk;
          
    end   
                               
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (Trigger == 1'b1 && Status == 1'b0) begin
                      if (Mode == 0) 
                      begin    
                        write_a <= 8'b00110010; 
                        read_a <= 8'b00110011; 
                        address_a <= 8'h28; 
                        ctrl_reg1 <= 8'b00100000;
                        ctrl_1 <= 8'b01010111;                        
                        SCL <= 1'b1;
                        SDA <= 1'b1;
                        State <= 9'd160;
                      end
                      else if (Mode == 1)
                      begin
                        write_a <= 8'b00111100;
                        read_a <= 8'b00111101;
                        address_a <= 8'h03;
                        ctrl_reg1 <= 8'b00000000;
                        ctrl_1 = 8'b00010100;
                        SCL <= 1'b1;
                        SDA <= 1'b1;
                        State <= 9'd160;
                      end
                      end                    
                 else if (Trigger == 1'b1 && Status == 1'b1) begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd1;
                      end
                 else begin
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                      end
                  end
                        
             // This is the Start sequence            
            8'd1 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[7];
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[6];  
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[5]; 
                  State <= State + 1'b1;                
            end   

            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[4]; 
                  State <= State + 1'b1;                
            end   

            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[3]; 
                  State <= State + 1'b1;                
            end   

            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[2]; 
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[1];  
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[0];      
                  State <= State + 1'b1;           
            end   

            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd36 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;                 
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
            end  
            
            8'd39 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[7];                
                  State <= State + 1'b1;
            end   

            8'd40 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd41 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd42 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd43 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[6];  
                  State <= State + 1'b1;               
            end   

            8'd44 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd45 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd46 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd47 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[5]; 
                  State <= State + 1'b1;                
            end   

            8'd48 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd49 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd50 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd51 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[4]; 
                  State <= State + 1'b1;                
            end   

            8'd52 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd53 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd54 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd55 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[3]; 
                  State <= State + 1'b1;                
            end   

            8'd56 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd57 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd58 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd59 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[2]; 
                  State <= State + 1'b1;                
            end   

            8'd60 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd61 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd62 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd63 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[1];  
                  State <= State + 1'b1;               
            end   

            8'd64 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd65 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd66 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd67 : begin
                  SCL <= 1'b0;
                  SDA <= address_a[0];      
                  State <= State + 1'b1;           
            end   

            8'd68 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd69 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd70 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd71 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd72 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;
                  State <= State + 1'b1;
            end   

            8'd73 : begin
                  SCL <= 1'b1;                 
                  State <= State + 1'b1;
            end   

            8'd74 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= 9'd280;
             end
            
            8'd75 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[7];
                  State <= State + 1'b1;                 
            end   

            8'd76 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd77 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd78 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd79 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[6];  
                  State <= State + 1'b1;               
            end   

            8'd80 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd81 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd82 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd83 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[5]; 
                  State <= State + 1'b1;                
            end   

            8'd84 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd85 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd86 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd87 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[4]; 
                  State <= State + 1'b1;                
            end   

            8'd88 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd89 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd90 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd91 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[3]; 
                  State <= State + 1'b1;                
            end   

            8'd92 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd93 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd94 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd95 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[2]; 
                  State <= State + 1'b1;                
            end   

            8'd96 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd97 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd98 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd99 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[1];  
                  State <= State + 1'b1;               
            end   

            8'd100 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd101 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd102 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd103 : begin
                  SCL <= 1'b0;
                  SDA <= read_a[0];      
                  State <= State + 1'b1;           
            end   

            8'd104 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd105 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd107 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd108 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;
                  State <= State + 1'b1;
            end   

            8'd109 : begin
                  SCL <= 1'b1;                 
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
             end
            
            8'd111 : begin
                  SCL <= 1'b0;
                  data_temp[7] <= SDA;
                  State <= State + 1'b1;
            end
                       

            8'd112 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd113 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd114 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd115 : begin
                  SCL <= 1'b0;
                  data_temp[6] <= SDA;  
                  State <= State + 1'b1;               
            end   

            8'd116 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd117 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd118 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd119 : begin
                  SCL <= 1'b0;
                  data_temp[5] <= SDA; 
                  State <= State + 1'b1;                
            end   

            8'd120 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd121 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd122 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd123 : begin
                  SCL <= 1'b0;
                  data_temp[4] <= SDA; 
                  State <= State + 1'b1;                
            end   

            8'd124 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd126 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd127 : begin
                  SCL <= 1'b0;
                  data_temp[3] <= SDA; 
                  State <= State + 1'b1;                
            end   

            8'd128 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd129 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd130 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd131 : begin
                  SCL <= 1'b0;
                  data_temp[2] <= SDA; 
                  State <= State + 1'b1;                
            end   

            8'd132 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd133 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd134 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd135 : begin
                  SCL <= 1'b0;
                  data_temp[1] <= SDA;  
                  State <= State + 1'b1;               
            end   

            8'd136 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd137 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd138 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd139 : begin
                  SCL <= 1'b0;
                  data_temp[0] <= SDA;      
                  State <= State + 1'b1;           
            end   

            8'd140 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd141 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd142 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // NMAK!!!!!!!!!!
            8'd143: begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;  
                  State <= State + 1'b1;               
            end   

            8'd144: begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd145: begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd146 : begin
                  SCL <= 1'b0;
                  if(Mode == 0) begin
                      if(address_a == 8'h28) x_neg_a <= data_temp;
                      else if(address_a == 8'h29) x_pos_a <= data_temp;
                      else if(address_a == 8'h2A) y_neg_a <= data_temp;
                      else if(address_a == 8'h2B) y_pos_a <= data_temp;
                      else if(address_a == 8'h2C) z_neg_a <= data_temp;
                      else if(address_a == 8'h2D) z_pos_a <= data_temp;  
                  State <= State + 1'b1;
                  end
                  
                  else if(Mode == 1) begin
                      if(address_a == 8'h03) x_pos_m <= data_temp;
                      else if(address_a == 8'h04) x_neg_m <= data_temp;
                      else if(address_a == 8'h05) z_pos_m <= data_temp;
                      else if(address_a == 8'h06) z_neg_m <= data_temp;
                      else if(address_a == 8'h07) y_pos_m <= data_temp;
                      else if(address_a == 8'h08) y_neg_m <= data_temp;  
                  State <= State + 1'b1;
                  end
            end
            
            8'd147 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;                
                  State <= State + 1'b1;
            end   

            8'd148 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd149 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  if (Mode == 0)
                  begin
                      if(address_a == 8'h2D) begin
                        Status <= 1'b0;
                        Mode <= 1'b1;
                      end
                      else begin
                        address_a <= address_a +1;
                      end
                  end
                  
                  else if (Mode == 1)
                  begin
                      if(address_a == 8'h08) begin
                        Status <= 1'b0;
                        Mode <= 1'b0;
                      end
                      else begin
                        address_a <= address_a +1;
                      end
                  end
                  
                 State <= STATE_INIT;                   
            end
            
//======================================================================================== 
                            
            9'd160 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            9'd161 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            9'd162 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[7];
                  State <= State + 1'b1;                 
            end   

            9'd163 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd164 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd165 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            9'd166 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[6];  
                  State <= State + 1'b1;               
            end   

            9'd167 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd168 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd169 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            9'd170 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[5]; 
                  State <= State + 1'b1;                
            end   

            9'd171 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd172 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd173 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            9'd174 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[4]; 
                  State <= State + 1'b1;                
            end   

            9'd175 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd176 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd177 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            9'd178 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[3]; 
                  State <= State + 1'b1;                
            end   

            9'd179 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd180 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd181 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            9'd182 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[2]; 
                  State <= State + 1'b1;                
            end   

            9'd183 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd184 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd185 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            9'd186 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[1];  
                  State <= State + 1'b1;               
            end   

            9'd187 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd188 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd189 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            9'd190 : begin
                  SCL <= 1'b0;
                  SDA <= write_a[0];      
                  State <= State + 1'b1;           
            end   

            9'd191 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd192 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd193 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            9'd194 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            9'd195 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;       
                  State <= State + 1'b1;
            end   

            9'd196 : begin
                  SCL <= 1'b1;          
                  State <= State + 1'b1;
            end   

            9'd197 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
             end  
            
            9'd198 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[7];                
                  State <= State + 1'b1;
            end   

            9'd199 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd200 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd201 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            9'd202 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[6];  
                  State <= State + 1'b1;               
            end   

            9'd203 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd204 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd205 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            9'd206 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[5]; 
                  State <= State + 1'b1;                
            end   

            9'd207 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd208 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd209 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            9'd210 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[4]; 
                  State <= State + 1'b1;                
            end   

            9'd211 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd212 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd213 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            9'd214 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[3]; 
                  State <= State + 1'b1;                
            end   

            9'd215 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd216 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd217 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            9'd218 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[2]; 
                  State <= State + 1'b1;                
            end   

            9'd219 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd220 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd221 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            9'd222 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[1];  
                  State <= State + 1'b1;               
            end   

            9'd223 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd224 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd225 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            9'd226 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_reg1[0];      
                  State <= State + 1'b1;           
            end   

            9'd227 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd228 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd229 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            9'd230 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            9'd231 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;       
                  State <= State + 1'b1;
            end   

            9'd232 : begin
                  SCL <= 1'b1;          
                  State <= State + 1'b1;
            end   

            9'd233 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
             end
            
            9'd234 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[7];                
                  State <= State + 1'b1;
            end   

            9'd235 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd236 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd237 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            9'd238 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[6];  
                  State <= State + 1'b1;               
            end   

            9'd239 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd240 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd241 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            9'd242 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[5]; 
                  State <= State + 1'b1;                
            end   

            9'd243 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd244 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd245 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            9'd246 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[4]; 
                  State <= State + 1'b1;                
            end   

            9'd247 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd248 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd249 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            9'd250 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[3]; 
                  State <= State + 1'b1;                
            end   

            9'd251 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd252 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd253 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            9'd254 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[2]; 
                  State <= State + 1'b1;                
            end   

            9'd255 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd256 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd257 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            9'd258 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[1];  
                  State <= State + 1'b1;               
            end   

            9'd259 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd260 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd261 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            9'd262 : begin
                  SCL <= 1'b0;
                  SDA <= ctrl_1[0];      
                  State <= State + 1'b1;           
            end   

            9'd263 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd264 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            9'd265 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            9'd266 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            9'd267 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;       
                  State <= State + 1'b1;
            end   

            9'd268 : begin
                  SCL <= 1'b1;          
                  State <= State + 1'b1;
            end   

            9'd269 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;
             end
             
            9'd270 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;                
                  State <= State + 1'b1;
            end   

            9'd271 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            9'd272 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  Status <= 1'b1;
                  State <= STATE_INIT;
                  end
                  
            9'd280 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= State + 1'b1;
                  end 
                  
            9'd281 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
                  end 
            
            9'd282 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= 8'd75;
                  end
            
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end                              
        endcase 
                                       
    end                     
endmodule
