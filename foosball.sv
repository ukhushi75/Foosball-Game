module foosball #(
    parameter int division_factor = 2,
    parameter int paddle_division_factor = 415000,
    parameter int ball_division_factor_1 = 415000,
    parameter int ball_division_factor_2 = 370000,
    parameter int ball_division_factor_3 = 310000,
    parameter int ball_division_factor_4 = 250000,
    parameter int H_active_size = 128,
    parameter int H_blank_size = 192,
    parameter int H_sync_size = 1024,
    parameter int V_active_size = 1080,
    parameter int V_blank_size = 3,
    parameter int V_sync_size = 45,
    parameter int Pixel_vertical_size = 600,
    parameter int Pixel_horizontal_size = 630,
    parameter int Paddle_horizontal_size = 15,
    parameter int Paddle_vertical_size = 60
) (
    input logic clk,
    input logic reset,
    output logic Hsync,
    output logic Vsync,
    input logic [3:0] direction_switch,
    input logic start_game,
    output logic [6:0] seg1,
    output logic [6:0] seg2,
    output logic bar,
    input logic [1:0] ball_speed,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);

    logic pixel_clk, paddle_clk, ball_clk;
    logic [3:0] ball_clk_sel;
    logic Hactive, Vactive, dena;
    int score1, score2;

    // Instantiate div_gen for pixel clock
    clock_divider #(.DIV(division_factor)) pixel_clk_gen (
        .clk_in(clk),
        .reset(reset),
        .clk_out(pixel_clk)
    );

    // Instantiate sync_generator
    display_timing_controller sync_gen_inst (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .Hactive(Hactive),
        .Vactive(Vactive),
        .dena(dena),
        // Pass through parameters
//        .Ha(Ha), .Hb(Hb), .Hc(Hc), .Hd(Hd),
//        .Va(Va), .Vb(Vb), .Vc(Vc), .Vd(Vd)
    );

    // Instantiate image_generator
    graphics_generator img_gen_inst (
        .pixel_clk(pixel_clk),
        .paddle_clk(paddle_clk),
        .ball_clk(ball_clk),
        .reset(reset),
        .Hactive(Hactive),
        .Vactive(Vactive),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .dena(dena),
        .direction_switch(direction_switch),
        .start_game(start_game),
        .score1(score1),
        .score2(score2),
        .R(R),
        .G(G),
        .B(B),
        // Pass through parameters for size
       // .PVsize(paddlesizeV), .PHsize(paddlesizeH)
    );

    // Instantiate div_gen for paddle clock
    clock_divider #(.DIV(paddle_division_factor)) paddle_clk_gen (
        .clk_in(clk),
        .reset(reset),
        .clk_out(paddle_clk)
    );


// Instantiate div_gen for each ball speed
clock_divider #(.DIV(ball_division_factor_1)) ball_clk_gen1 (.clk_in(clk), .reset(reset), .clk_out(ball_clk1));
clock_divider #(.DIV(ball_division_factor_2)) ball_clk_gen2 (.clk_in(clk), .reset(reset), .clk_out(ball_clk2));
clock_divider #(.DIV(ball_division_factor_3)) ball_clk_gen3 (.clk_in(clk), .reset(reset), .clk_out(ball_clk3));
clock_divider #(.DIV(ball_division_factor_4)) ball_clk_gen4 (.clk_in(clk), .reset(reset), .clk_out(ball_clk4));

// Logic to select among ball_clk{1,2,3,4} based on ball_speed
always_comb begin
    case(ball_speed)
        2'b00: ball_clk = ball_clk1;
        2'b01: ball_clk = ball_clk2;
        2'b10: ball_clk = ball_clk3;
        default: ball_clk = ball_clk4;
    endcase
end



    // Instantiate score_display
    score score_disp_inst (
        .score1(score1),
        .score2(score2),
        .seg1(seg1),
        .seg2(seg2),
        .bar(bar)
    );

endmodule