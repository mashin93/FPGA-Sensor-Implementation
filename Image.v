`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 07:35:23 PM
// Design Name: 
// Module Name: Image
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


module Image(
    input sys_clkn,
    input sys_clkp,
    input wire Control,
    input wire Trigger,
    input wire Image_Clk,
    output reg SPI_EN,
    output reg SPI_IN,
    output reg SPI_CLK,
    input SPI_OUT,
    output reg [7:0] Final_1,
    output reg [7:0] Final_2,
    output reg [15:0] Final_3,   
    input wire [6:0] Address_1,
    input wire [6:0] Address_2,
    input wire [7:0] Data_1,
    input wire [7:0] Data_2
    );
    
    wire [23:0] ClkDivThreshold = 100;   
                                        
    reg [7:0] State = 8'd0;
    reg error_bit = 1'b1; 
       
    localparam STATE_INIT       = 8'd0;    
    
    initial  begin
        SPI_EN = 1'b0;
        SPI_IN = 1'b0;
        SPI_CLK = 1'b0; 
    end
                               
    always @(posedge Image_Clk) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (Trigger == 1'b1 &&  Control == 1'b0) 
                 begin
                 State <= 8'd1;  
                 end
                 else if (Trigger == 1'b1 && Control == 1'b1) 
                 begin
                 State <= 8'd66;
                 end                              
                 else 
                 begin                 
                    SPI_EN <= 1'b0;
                    SPI_CLK <= 1'b0; 
                    SPI_IN <= 1'b0; 
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Control;
                  State <= State + 1'b1;                   
            end   
            
            8'd2 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Control; 
                  State <= State + 1'b1;                  
            end
            
            8'd3 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[6];
                  State <= State + 1'b1;                   
            end   
            
            8'd4 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[6];    
                  State <= State + 1'b1;               
            end   
            
            8'd5 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[5];  
                  State <= State + 1'b1;                 
            end   
            
            8'd6 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[5];   
                  State <= State + 1'b1;                
            end   
            
            8'd7 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd8 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd9 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd10 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd11 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[2];     
                  State <= State + 1'b1;              
            end   
            
            8'd12 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[2];    
                  State <= State + 1'b1;               
            end   
            
            8'd13 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd14 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd15 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[0];     
                  State <= State + 1'b1;              
            end   
            
            8'd16 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[0];      
                  State <= State + 1'b1;             
            end      
            
            8'd17 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[7] <= SPI_OUT;
                  Final_3[7] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd18 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[7] <= SPI_OUT;
                  Final_3[7] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd19 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[6] <= SPI_OUT;
                  Final_3[6] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd20 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[6] <= SPI_OUT;
                  Final_3[6] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd21 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[5] <= SPI_OUT;
                  Final_3[5] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd22 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[5] <= SPI_OUT;
                  Final_3[5] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd23 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[4] <= SPI_OUT;
                  Final_3[4] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd24 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[4] <= SPI_OUT;
                  Final_3[4] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd25 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[3] <= SPI_OUT;
                  Final_3[3] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd26 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[3] <= SPI_OUT;
                  Final_3[3] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd27 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[2] <= SPI_OUT;
                  Final_3[2] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd28 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[2] <= SPI_OUT;
                  Final_3[2] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd29 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[1] <= SPI_OUT;
                  Final_3[1] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd30 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[1] <= SPI_OUT;
                  Final_3[1] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd31 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_1[0] <= SPI_OUT;
                  Final_3[0] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd32 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_1[0] <= SPI_OUT;
                  Final_3[0] <= SPI_OUT;
                  State <= State + 1'b1;                
            end
            
            8'd33 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Control;
                  State <= State + 1'b1;                   
            end   
            
            8'd34 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Control; 
                  State <= State + 1'b1;                  
            end
            
            8'd35 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[6];
                  State <= State + 1'b1;                   
            end   
            
            8'd36 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[6];    
                  State <= State + 1'b1;               
            end   
            
            8'd37 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[5];  
                  State <= State + 1'b1;                 
            end   
            
            8'd38 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[5];   
                  State <= State + 1'b1;                
            end   
            
            8'd39 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd40 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd41 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd42 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd43 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[2];     
                  State <= State + 1'b1;              
            end   
            
            8'd44 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[2];    
                  State <= State + 1'b1;               
            end   
            
            8'd45 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd46 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd47 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[0];     
                  State <= State + 1'b1;              
            end   
            
            8'd48 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[0];      
                  State <= State + 1'b1;             
            end      
            
            8'd49 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[7] <= SPI_OUT;
                  Final_3[15] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd50 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[7] <= SPI_OUT;
                  Final_3[15] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd51 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[6] <= SPI_OUT;
                  Final_3[14] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd52 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[6] <= SPI_OUT;
                  Final_3[14] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd53 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[5] <= SPI_OUT;
                  Final_3[13] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd54 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[5] <= SPI_OUT;
                  Final_3[13] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd55 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[4] <= SPI_OUT;
                  Final_3[12] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd56 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[4] <= SPI_OUT;
                  Final_3[12] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd57 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[3] <= SPI_OUT;
                  Final_3[11] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd58 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[3] <= SPI_OUT;
                  Final_3[11] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd59 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[2] <= SPI_OUT;
                  Final_3[10] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd60 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[2] <= SPI_OUT;
                  Final_3[10] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd61 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[1] <= SPI_OUT;
                  Final_3[9] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd62 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[1] <= SPI_OUT;
                  Final_3[9] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd63 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  Final_2[0] <= SPI_OUT;
                  Final_3[8] <= SPI_OUT;
                  State <= State + 1'b1;
            end
            
            8'd64 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  Final_2[0] <= SPI_OUT;
                  Final_3[8] <= SPI_OUT;
                  State <= State + 1'b1;                
            end
            
            8'd65 : begin
                  SPI_EN <= 1'b0;
                  SPI_CLK <= 1'b0; 
                  State <= STATE_INIT;                
            end

            // transmit bit 7               
            8'd66 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Control;
                  State <= State + 1'b1;                   
            end   
            
            8'd67 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Control; 
                  State <= State + 1'b1;                  
            end
            
            8'd68 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[6];
                  State <= State + 1'b1;                   
            end   
            
            8'd69 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[6];    
                  State <= State + 1'b1;               
            end   
            
            8'd70 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[5];  
                  State <= State + 1'b1;                 
            end   
            
            8'd71 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[5];   
                  State <= State + 1'b1;                
            end   
            
            8'd72 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd73 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd74 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd75 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd76 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[2];     
                  State <= State + 1'b1;              
            end   
            
            8'd77 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[2];    
                  State <= State + 1'b1;               
            end   
            
            8'd78 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd79 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd80 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_1[0];     
                  State <= State + 1'b1;              
            end   
            
            8'd81 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_1[0];      
                  State <= State + 1'b1;             
            end      
            
            8'd82 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[7]; 
                  State <= State + 1'b1;
            end
            
            8'd83 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[7]; 
                  State <= State + 1'b1;
            end
            
            8'd84 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[6]; 
                  State <= State + 1'b1;
            end
            
            8'd85 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[6]; 
                  State <= State + 1'b1;
            end
            
            8'd86 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[5]; 
                  State <= State + 1'b1;
            end
            
            8'd87 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[5]; 
                  State <= State + 1'b1;
            end
            
            8'd88 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[4]; 
                  State <= State + 1'b1;
            end
            
            8'd89 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[4]; 
                  State <= State + 1'b1;
            end
            
            8'd90 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[3]; 
                  State <= State + 1'b1;
            end
            
            8'd91 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[3]; 
                  State <= State + 1'b1;
            end
            
            8'd92 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[2]; 
                  State <= State + 1'b1;
            end
            
            8'd93 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[2]; 
                  State <= State + 1'b1;
            end
            
            8'd94 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[1]; 
                  State <= State + 1'b1;
            end
            
            8'd95 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[1]; 
                  State <= State + 1'b1;
            end
            
            8'd96 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_1[0]; 
                  State <= State + 1'b1;
            end
            
            8'd97 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_1[0]; 
                  State <= State + 1'b1;             
            end
            
            8'd98 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Control;
                  State <= State + 1'b1;                   
            end   
            
            8'd99 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Control; 
                  State <= State + 1'b1;                  
            end
            
            8'd100 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[6];
                  State <= State + 1'b1;                   
            end   
            
            8'd101 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[6];    
                  State <= State + 1'b1;               
            end   
            
            8'd102 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[5];  
                  State <= State + 1'b1;                 
            end   
            
            8'd103 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[5];   
                  State <= State + 1'b1;                
            end   
            
            8'd104 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd105 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[4];   
                  State <= State + 1'b1;                
            end   
            
            8'd106 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd107 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[3];   
                  State <= State + 1'b1;                
            end   
            
            8'd108 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[2];     
                  State <= State + 1'b1;              
            end   
            
            8'd109 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[2];    
                  State <= State + 1'b1;               
            end   
            
            8'd110 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd111 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[1];      
                  State <= State + 1'b1;             
            end   
            
            8'd112 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Address_2[0];     
                  State <= State + 1'b1;              
            end   
            
            8'd113 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Address_2[0];      
                  State <= State + 1'b1;             
            end      
            
            8'd114 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[7]; 
                  State <= State + 1'b1;
            end
            
            8'd115 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[7]; 
                  State <= State + 1'b1;
            end
            
            8'd116 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[6]; 
                  State <= State + 1'b1;
            end
            
            8'd117 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[6]; 
                  State <= State + 1'b1;
            end
            
            8'd118 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[5]; 
                  State <= State + 1'b1;
            end
            
            8'd119 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[5]; 
                  State <= State + 1'b1;
            end
            
            8'd120 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[4]; 
                  State <= State + 1'b1;
            end
            
            8'd121 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[4]; 
                  State <= State + 1'b1;
            end
            
            8'd122 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[3]; 
                  State <= State + 1'b1;
            end
            
            8'd123 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[3]; 
                  State <= State + 1'b1;
            end
            
            8'd124 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[2]; 
                  State <= State + 1'b1;
            end
            
            8'd125 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[2]; 
                  State <= State + 1'b1;
            end
            
            8'd126 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[1]; 
                  State <= State + 1'b1;
            end
            
            8'd127 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[1]; 
                  State <= State + 1'b1;
            end
            
            8'd128 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0; 
                  SPI_IN <= Data_2[0]; 
                  State <= State + 1'b1;
            end
            
            8'd129 : begin
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b1; 
                  SPI_IN <= Data_2[0]; 
                  State <= State + 1'b1;             
            end
            
            8'd130 : begin
                  SPI_EN <= 1'b0;
                  SPI_CLK <= 1'b0; 
                  State <= STATE_INIT;                
            end                              
    
            default : begin
                error_bit <= 0;
            end            
        endcase
    end
endmodule
