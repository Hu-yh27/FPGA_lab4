`timescale 1ns / 1ns

module display_controller(
    input  wire        clk,           
    input  wire        reset,         
    input  wire        button,        
    output reg  [1:0]  state,         
    
    output reg  [7:0]  vga_red,       
    output reg  [7:0]  vga_green,     
    output reg  [7:0]  vga_blue,      
    
    input  wire [9:0]  x_pos,         
    input  wire [9:0]  y_pos,         
    input  wire        display_enable 
);

    
    parameter STATE_COLOR_BAR = 2'b00;
    parameter STATE_MUST      = 2'b01;
    parameter STATE_END       = 2'b10;
    
    
    reg [1:0] next_state;
    reg button_prev;
    wire button_pressed;
    
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_prev <= 1'b0;
        end else begin
            button_prev <= button;
        end
    end
    
    assign button_pressed = button & ~button_prev;
    
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_COLOR_BAR;
        end else begin
            state <= next_state;
        end
    end
    
    
    always @(*) begin
        next_state = state; 
        
        if (button_pressed) begin
            case (state)
                STATE_COLOR_BAR: next_state = STATE_MUST;
                STATE_MUST:      next_state = STATE_END;
                STATE_END:       next_state = STATE_COLOR_BAR;
                default:         next_state = STATE_COLOR_BAR;
            endcase
        end
    end
    
    
    always @(*) begin
        
        vga_red   = 8'h00;
        vga_green = 8'h00;
        vga_blue  = 8'h00;
        
        if (display_enable) begin
            case (state)
                STATE_COLOR_BAR: begin
                    
                    if (x_pos < 160) begin
                        
                        vga_red   = 8'hFF;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 320) begin
                        
                        vga_red   = 8'h00;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 480) begin
                        
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'hFF;
                    end else begin
                        
                        vga_red   = 8'hFF;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end
                end
                
                STATE_MUST: begin
                    
                    if (is_in_must_area(x_pos, y_pos)) begin
                        if (is_must_pixel(x_pos, y_pos)) begin
                            
                            vga_red   = 8'hFF;
                            vga_green = 8'hFF;
                            vga_blue  = 8'hFF;
                        end else begin
                            
                            vga_red   = 8'h00;
                            vga_green = 8'h00;
                            vga_blue  = 8'h00;
                        end
                    end else begin
                        
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end
                end
                
                STATE_END: begin
                    
                    if (is_in_end_area(x_pos, y_pos)) begin
                        if (is_end_pixel(x_pos, y_pos)) begin
                            
                            vga_red   = 8'h00;
                            vga_green = 8'hFF;
                            vga_blue  = 8'hFF;
                        end else begin
                            
                            vga_red   = 8'h00;
                            vga_green = 8'h00;
                            vga_blue  = 8'h00;
                        end
                    end else begin
                        
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end
                end
                
                default: begin
                    
                    if (x_pos < 160) begin
                        vga_red   = 8'hFF;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 320) begin
                        vga_red   = 8'h00;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 480) begin
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'hFF;
                    end else begin
                        vga_red   = 8'hFF;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end
                end
            endcase
        end
    end
    
    
    function is_in_must_area;
        input [9:0] x, y;
        begin
            
            is_in_must_area = (x >= 240 && x < 400) && (y >= 200 && y < 280);
        end
    endfunction
    
    function is_must_pixel;
        input [9:0] x, y;
        reg in_m, in_u, in_s, in_t;
        begin
            
            in_m = (x >= 250 && x < 290) && (y >= 200 && y < 280); 
            in_u = (x >= 300 && x < 340) && (y >= 200 && y < 280); 
            in_s = (x >= 350 && x < 390) && (y >= 200 && y < 280); 
            in_t = (x >= 400 && x < 440) && (y >= 200 && y < 280); 
            
            is_must_pixel = in_m || in_u || in_s || in_t;
        end
    endfunction
    
    
    function is_in_end_area;
        input [9:0] x, y;
        begin
            
            is_in_end_area = (x >= 240 && x < 400) && (y >= 200 && y < 280);
        end
    endfunction
    
    function is_end_pixel;
        input [9:0] x, y;
        reg in_e, in_n, in_d;
        begin
            
            in_e = (x >= 250 && x < 290) && (y >= 200 && y < 280); 
            in_n = (x >= 300 && x < 340) && (y >= 200 && y < 280); 
            in_d = (x >= 350 && x < 390) && (y >= 200 && y < 280); 
            
            is_end_pixel = in_e || in_n || in_d;
        end
    endfunction

endmodule
