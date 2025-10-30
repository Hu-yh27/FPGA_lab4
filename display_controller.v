`timescale 1ns / 1ns

module display_controller(
    input  wire        clk,           // 时钟信号
    input  wire        reset,         // 复位信号
    input  wire        button,        // 按钮输入（状态切换）
    output reg  [1:0]  state,         // 当前状态输出
    
    output reg  [7:0]  vga_red,       // VGA红色分量
    output reg  [7:0]  vga_green,     // VGA绿色分量
    output reg  [7:0]  vga_blue,      // VGA蓝色分量
    
    input  wire [9:0]  x_pos,         // 当前像素X坐标
    input  wire [9:0]  y_pos,         // 当前像素Y坐标
    input  wire        display_enable // 显示使能信号
);

    // 状态定义
    parameter STATE_COLOR_BAR = 2'b00;
    parameter STATE_MUST      = 2'b01;
    parameter STATE_END       = 2'b10;
    
    // 内部信号
    reg [1:0] next_state;
    reg button_prev;
    wire button_pressed;
    
    // 按钮边沿检测（检测上升沿）
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_prev <= 1'b0;
        end else begin
            button_prev <= button;
        end
    end
    
    assign button_pressed = button & ~button_prev;
    
    // 状态寄存器
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_COLOR_BAR;
        end else begin
            state <= next_state;
        end
    end
    
    // 状态转换逻辑
    always @(*) begin
        next_state = state; // 默认保持当前状态
        
        if (button_pressed) begin
            case (state)
                STATE_COLOR_BAR: next_state = STATE_MUST;
                STATE_MUST:      next_state = STATE_END;
                STATE_END:       next_state = STATE_COLOR_BAR;
                default:         next_state = STATE_COLOR_BAR;
            endcase
        end
    end
    
    // 显示输出逻辑
    always @(*) begin
        // 默认黑色背景
        vga_red   = 8'h00;
        vga_green = 8'h00;
        vga_blue  = 8'h00;
        
        if (display_enable) begin
            case (state)
                STATE_COLOR_BAR: begin
                    // 彩条显示 - 四个垂直条
                    if (x_pos < 160) begin
                        // 红色条
                        vga_red   = 8'hFF;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 320) begin
                        // 绿色条
                        vga_red   = 8'h00;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end else if (x_pos < 480) begin
                        // 蓝色条
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'hFF;
                    end else begin
                        // 黄色条
                        vga_red   = 8'hFF;
                        vga_green = 8'hFF;
                        vga_blue  = 8'h00;
                    end
                end
                
                STATE_MUST: begin
                    // MUST字符显示 - 在屏幕中央显示白色"MUST"
                    if (is_in_must_area(x_pos, y_pos)) begin
                        if (is_must_pixel(x_pos, y_pos)) begin
                            // MUST字符像素 - 白色
                            vga_red   = 8'hFF;
                            vga_green = 8'hFF;
                            vga_blue  = 8'hFF;
                        end else begin
                            // MUST字符背景 - 黑色
                            vga_red   = 8'h00;
                            vga_green = 8'h00;
                            vga_blue  = 8'h00;
                        end
                    end else begin
                        // 屏幕其他区域 - 黑色
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end
                end
                
                STATE_END: begin
                    // END字符显示 - 在屏幕中央显示青色"END"
                    if (is_in_end_area(x_pos, y_pos)) begin
                        if (is_end_pixel(x_pos, y_pos)) begin
                            // END字符像素 - 青色
                            vga_red   = 8'h00;
                            vga_green = 8'hFF;
                            vga_blue  = 8'hFF;
                        end else begin
                            // END字符背景 - 黑色
                            vga_red   = 8'h00;
                            vga_green = 8'h00;
                            vga_blue  = 8'h00;
                        end
                    end else begin
                        // 屏幕其他区域 - 黑色
                        vga_red   = 8'h00;
                        vga_green = 8'h00;
                        vga_blue  = 8'h00;
                    end
                end
                
                default: begin
                    // 默认显示彩条
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
    
    // MUST字符区域和像素判断函数
    function is_in_must_area;
        input [9:0] x, y;
        begin
            // MUST字符显示区域（居中）
            is_in_must_area = (x >= 240 && x < 400) && (y >= 200 && y < 280);
        end
    endfunction
    
    function is_must_pixel;
        input [9:0] x, y;
        reg in_m, in_u, in_s, in_t;
        begin
            // 简化字符形状 - 使用矩形区域近似
            in_m = (x >= 250 && x < 290) && (y >= 200 && y < 280); // M区域
            in_u = (x >= 300 && x < 340) && (y >= 200 && y < 280); // U区域
            in_s = (x >= 350 && x < 390) && (y >= 200 && y < 280); // S区域
            in_t = (x >= 400 && x < 440) && (y >= 200 && y < 280); // T区域
            
            is_must_pixel = in_m || in_u || in_s || in_t;
        end
    endfunction
    
    // END字符区域和像素判断函数
    function is_in_end_area;
        input [9:0] x, y;
        begin
            // END字符显示区域（居中）
            is_in_end_area = (x >= 240 && x < 400) && (y >= 200 && y < 280);
        end
    endfunction
    
    function is_end_pixel;
        input [9:0] x, y;
        reg in_e, in_n, in_d;
        begin
            // 简化字符形状 - 使用矩形区域近似
            in_e = (x >= 250 && x < 290) && (y >= 200 && y < 280); // E区域
            in_n = (x >= 300 && x < 340) && (y >= 200 && y < 280); // N区域
            in_d = (x >= 350 && x < 390) && (y >= 200 && y < 280); // D区域
            
            is_end_pixel = in_e || in_n || in_d;
        end
    endfunction

endmodule