`timescale 1ns / 1ns

module vga_timing(
    input  wire        clk,           
    input  wire        reset,         
    output reg         h_sync,        
    output reg         v_sync,        
    output reg  [9:0]  x_pos,         
    output reg  [9:0]  y_pos,         
    output reg         display_enable 
);

    
    parameter H_DISPLAY     = 640;   
    parameter H_FRONT_PORCH = 16;   
    parameter H_SYNC_PULSE  = 96;   
    parameter H_BACK_PORCH  = 48;   
    parameter H_TOTAL       = 800;  
    
    parameter V_DISPLAY     = 480;   
    parameter V_FRONT_PORCH = 10;   
    parameter V_SYNC_PULSE  = 2;    
    parameter V_BACK_PORCH  = 33;   
    parameter V_TOTAL       = 525;  
    
    
    reg pixel_clk;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_clk <= 1'b0;
        end else begin
            pixel_clk <= ~pixel_clk;
        end
    end
    
    
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            x_pos <= 10'd0;
        end else begin
            if (x_pos == H_TOTAL - 1) begin
                x_pos <= 10'd0;
            end else begin
                x_pos <= x_pos + 1'b1;
            end
        end
    end
    
    
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            y_pos <= 10'd0;
        end else if (x_pos == H_TOTAL - 1) begin
            if (y_pos == V_TOTAL - 1) begin
                y_pos <= 10'd0;
            end else begin
                y_pos <= y_pos + 1'b1;
            end
        end
    end
    
    
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_sync <= 1'b1;
        end else begin
            if (x_pos >= (H_DISPLAY + H_FRONT_PORCH) && 
                x_pos < (H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) begin
                h_sync <= 1'b0;  
            end else begin
                h_sync <= 1'b1;
            end
        end
    end
    
    
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            v_sync <= 1'b1;
        end else begin
            if (y_pos >= (V_DISPLAY + V_FRONT_PORCH) && 
                y_pos < (V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) begin
                v_sync <= 1'b0;  
            end else begin
                v_sync <= 1'b1;
            end
        end
    end
    
    
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            display_enable <= 1'b0;
        end else begin
            display_enable <= (x_pos < H_DISPLAY) && (y_pos < V_DISPLAY);
        end
    end

endmodule