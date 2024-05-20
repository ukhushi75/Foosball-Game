module display_timing_controller #(
    parameter integer H_active_size = 128,
    parameter integer H_blank_size = 192,
    parameter integer H_sync_size = 1024,
    parameter integer V_active_size = 1080,
    parameter integer V_blank_size = 3,
    parameter integer V_sync_size = 45,
    parameter integer Pixel_vertical_size = 600,
    parameter integer Pixel_horizontal_size = 630
)(
    input logic pixel_clk,
    input logic reset,
    output logic Hsync, Vsync,
    output logic Hactive, Vactive,
    output logic dena

);

    logic [($clog2(V_active_size+1)-1):0] Hcount; // Adjusted for SystemVerilog
    logic [($clog2(Pixel_horizontal_size+1)-1):0] Vcount; // Adjusted for SystemVerilog

    // Horizontal signal generator
    always_ff @(posedge pixel_clk or negedge reset) begin
        if (!reset) begin
            Hcount <= 0;
        end else begin
            Hcount <= Hcount + 1;
            if (Hcount == H_active_size) Hsync <= 1;
            else if (Hcount == H_blank_size) Hactive <= 1;
            else if (Hcount == H_sync_size) Hactive <= 0;
            else if (Hcount == V_active_size) begin
                Hsync <= 0;
                Hcount <= 0;
            end
        end
    end

    // Vertical signal generator
    always_ff @(posedge Hsync or negedge reset) begin
        if (!reset) begin
            Vcount <= 0;
        end else begin
            Vcount <= Vcount + 1;
            if (Vcount == V_blank_size) Vsync <= 1;
            else if (Vcount == V_sync_size) Vactive <= 1;
            else if (Vcount == Pixel_vertical_size) Vactive <= 0;
            else if (Vcount == Pixel_horizontal_size) begin
                Vsync <= 0;
                Vcount <= 0;
            end
        end
    end

    // Dena generator
    assign dena = Hactive && Vactive;

endmodule