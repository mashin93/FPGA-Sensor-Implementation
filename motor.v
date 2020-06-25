`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2019 01:32:05 PM
// Design Name: 
// Module Name: motor
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


module motor(   
    output PMOD_A1,
    output PMOD_A2,
    input wire Motor_Clk,
    input direction,
    input [31:0] pulse_num,
    input [31:0] pwm,
    output [31:0] pulse_count_out
    );
    
    reg [7:0] Motor_FSM = 8'd0 ;
    reg [31:0] pulse_counter = 32'd0;
    reg EN;
    reg DIR;
    reg [31:0] count = 32'd0;
    reg [2:0] loop;

    assign PMOD_A1 = EN;
    assign PMOD_A2 = DIR;
    assign pulse_count_out = pulse_counter;


    initial begin
        EN = 1'b0;
        DIR = 1'b0;
    end
    
    always @(posedge Motor_Clk) begin
        case(Motor_FSM)
            8'd0 : begin
                if (pwm != 32'd0) begin
                    count <= pwm;
                    DIR <= direction;
                    EN <= 1'b0;
                    Motor_FSM <= 8'd1;
                end 
                
                else begin
                    Motor_FSM <= 8'd0;
                    EN <= 1'b0;
                end
            end
               
                
            8'd1 : begin
                if (count == 1'b0) begin
                    EN <= 1'b1;
                    Motor_FSM <= 8'd0;
                end
                
                else begin
                    EN <= 1'b0;
                    count <= count - 1'b1;
                end
           end
           
           8'd2 : begin
                EN <= 1'b0;
            end
           
        endcase
    end


    
    
endmodule
