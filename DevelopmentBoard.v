`timescale 1ns / 1ns

module DevelopmentBoard(
    input  wire        clk,        
    input  wire        reset,      
    input  wire        button,     
    input  wire        B3,         
    input  wire        B4,        
    input  wire        B5,         
    
    output wire        h_sync,     
    output wire        v_sync,     
    output wire [15:0] rgb,        
    
    output wire        led1,       
    output wire        led2,       
    output wire        led3,      
    output wire        led4,       
    output wire        led5        
);

    // 内部信号
    wire [9:0] x_pos, y_pos;
    wire display_enable;
    wire [7:0] vga_red, vga_green, vga_blue;
    wire [1:0] current_state;
    
    // VGA时序生成器
    vga_timing vga_timing_inst(
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .display_enable(display_enable)
    );
    
    // 显示控制器（状态机+显示逻辑）
    display_controller display_controller_inst(
        .clk(clk),
        .reset(reset),
        .button(button),
        .state(current_state),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .display_enable(display_enable)
    );
    
    // RGB输出转换 (8位 -> 16位 RGB565)
    assign rgb = {vga_red[7:3], vga_green[7:2], vga_blue[7:3]};
    
    // LED状态指示
    assign led1 = 1'b1;                    
    assign led2 = ~button;                 
    assign led3 = (current_state == 2'b00); 
    assign led4 = (current_state == 2'b01); 
    assign led5 = (current_state == 2'b10); 

endmodule
