`timescale 1ns / 1ns

module tb_vga_timing;

    // Inputs
    reg clk;
    reg reset;
    
    // Outputs
    wire h_sync;
    wire v_sync;
    wire [9:0] x_pos;
    wire [9:0] y_pos;
    wire display_enable;
    
    // Testbench internal signals
    reg h_sync_start;
    reg v_sync_start;
    integer frame_count;
    real frame_start_time;
    
    // Instantiate the Unit Under Test (UUT)
    vga_timing uut (
        .clk(clk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .x_pos(x_pos),
        .display_enable(display_enable),
        .y_pos(y_pos)
    );
    
    // Clock generation (50MHz)
    always #10 clk = ~clk; // 20ns period = 50MHz
    
    // Initialize signals
    initial begin
        clk = 0;
        reset = 1;
        h_sync_start = 0;
        v_sync_start = 0;
        frame_count = 0;
        frame_start_time = 0;
        
        $display("=== VGA Timing Module Simulation Started ===");
        $display("Time: %t, Initializing with reset active", $time);
        
        // Apply reset
        #100;
        reset = 0;
        $display("Time: %t, Reset released", $time);
        
        // Run for 2 complete frames to observe behavior
        #40000000; // 40ms - approximately 2 frames at 60Hz
        
        $display("Time: %t, Simulation completed", $time);
        $finish;
    end
    
    // Monitor important events
    always @(posedge clk) begin
        // Monitor frame start
        if (x_pos == 0 && y_pos == 0) begin
            $display("Time: %t, New frame started", $time);
        end
        
        // Monitor line completion
        if (x_pos == 799) begin
            $display("Time: %t, Line %0d completed", $time, y_pos);
        end
        
        // Monitor display region boundaries
        if (x_pos == 639 && display_enable) begin
            $display("Time: %t, End of visible line %0d", $time, y_pos);
        end
    end
    
    // Real-time signal monitoring for waveform analysis
    always @(posedge uut.pixel_clk) begin
        // Monitor sync pulse timing
        if (h_sync == 1'b0 && $time > 1000) begin
            if (!h_sync_start) begin
                h_sync_start = 1;
                $display("Time: %t, H_SYNC pulse started at X=%0d", $time, x_pos);
            end
        end else begin
            h_sync_start = 0;
        end
        
        if (v_sync == 1'b0 && $time > 1000) begin
            if (!v_sync_start) begin
                v_sync_start = 1;
                $display("Time: %t, V_SYNC pulse started at Y=%0d", $time, y_pos);
            end
        end else begin
            v_sync_start = 0;
        end
    end
    
    // Performance analysis - frame rate calculation
    always @(posedge clk) begin
        if (x_pos == 0 && y_pos == 0 && $time > 1000) begin
            if (frame_count > 0) begin
                frame_start_time = ($time - frame_start_time) / 1000000.0; // in ms
                frame_start_time = 1000.0 / frame_start_time;
                $display("Frame %0d: Period = %0.3f ms, Rate = %0.2f Hz", 
                         frame_count, ($time - frame_start_time) / 1000000.0, 
                         frame_start_time);
            end
            frame_count = frame_count + 1;
            frame_start_time = $time;
        end
    end
    
    // Generate waveform file
    initial begin
        $dumpfile("vga_timing_waveform.vcd");
        $dumpvars(0, tb_vga_timing);
    end

endmodule