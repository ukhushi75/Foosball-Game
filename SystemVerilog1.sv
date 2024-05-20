module pong #(
    parameter int div = 2,
    parameter int div_paddle = 415000,
    parameter int div_ball1 = 415000,
    parameter int div_ball2 = 370000,
    parameter int div_ball3 = 310000,
    parameter int div_ball4 = 250000,
    parameter int Ha = 96,
    parameter int Hb = 144,
    parameter int Hc = 784,
    parameter int Hd = 800,
    parameter int Va = 2,
    parameter int Vb = 35,
    parameter int Vc = 515,
    parameter int Vd = 525,
    parameter int paddlesizeH = 2,
    parameter int paddlesizeV = 30
)(
    input logic clk,
    input logic reset,
    inout logic Hsync,
    inout logic Vsync,
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


endmodule


module div_gen #(
    parameter int div = 2
)(
    input logic clk_in,
    input logic reset,
    output logic clk_out
);


endmodule


module VGA_arch #(
    parameter int div = 2
)(
    input logic clk,
    input logic reset,
    inout logic Hsync,
    inout logic Vsync,
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


    logic pixel_clk;
    logic Hactive, Vactive, dena;
    logic paddle_clk, ball_clk, ball_clk1, ball_clk2, ball_clk3, ball_clk4;
    int score1, score2;


    div_gen #(
        .div(div)
    ) div_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(pixel_clk)
    );


endmodule


//4
module sync_generator #(
    parameter int Ha = 96,
    parameter int Hb = 144,
    parameter int Hc = 784,
    parameter int Hd = 800,
    parameter int Va = 2,
    parameter int Vb = 35,
    parameter int Vc = 515,
    parameter int Vd = 525
)(
    input logic pixel_clk,
    input logic reset,
    inout logic Hsync,
    inout logic Vsync,
    inout logic Hactive,
    inout logic Vactive,
    output logic dena
);


endmodule


//5
module image_generator #(
    parameter int Ha = 96,
    parameter int Hb = 144,
    parameter int Hc = 784,
    parameter int Hd = 800,
    parameter int Va = 2,
    parameter int Vb = 35,
    parameter int Vc = 515,
    parameter int Vd = 525,
    parameter int PVsize = 50,
    parameter int PHsize = 10,
    parameter int BallSize = 3
)(
    input logic pixel_clk,
    input logic paddle_clk,
    input logic ball_clk,
    input logic reset,
    input logic Hactive,
    input logic Vactive,
    input logic Hsync,
    input logic Vsync,
    input logic dena,
    input logic [3:0] direction_switch,
    input logic start_game,
    output int score1,
    output int score2,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B
);


endmodule


module score_display #(
)(
    input int score1,
    input int score2,
    output logic [6:0] seg1,
    output logic [6:0] seg2,
    output logic bar
);


endmodule


module pin_assignments #(
    parameter int div = 2,
    parameter int div_paddle = 415000,
    parameter int div_ball1 = 415000,
    parameter int div_ball2 = 370000,
    parameter int div_ball3 = 310000,
    parameter int div_ball4 = 250000,
    parameter int Ha = 96,
    parameter int Hb = 144,
    parameter int Hc = 784,
    parameter int Hd = 800,
    parameter int Va = 2,
    parameter int Vb = 35,
    parameter int Vc = 515,
    parameter int Vd = 525,
    parameter int paddlesizeH = 2,
    parameter int paddlesizeV = 30
)(
    input logic clk,
    input logic reset,
    inout logic Hsync,
    inout logic Vsync,
    inout logic Hactive,
    inout logic Vactive,
    output logic dena,
    input logic [3:0] direction_switch,
    input logic start_game,
    output int score1,
    output int score2,
    output logic [3:0] R,
    output logic [3:0] G,
    output logic [3:0] B,
    output logic [6:0] seg1,
    output logic [6:0] seg2,
    output logic bar,
    input logic [1:0] ball_speed
);


    logic pixel_clk;
    logic paddle_clk, ball_clk, ball_clk1, ball_clk2, ball_clk3, ball_clk4;


    div_gen #(
        .div(div)
    ) u0_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(pixel_clk)
    );


    sync_generator #(
        .Ha(Ha),
        .Hb(Hb),
        .Hc(Hc),
        .Hd(Hd),
        .Va(Va),
        .Vb(Vb),
        .Vc(Vc),
        .Vd(Vd)
    ) u1_inst (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .Hsync(Hsync),
        .Vsync(Vsync),
        .Hactive(Hactive),
        .Vactive(Vactive),
        .dena(dena)
    );


    image_generator #(
        .Ha(Ha),
        .Hb(Hb),
        .Hc(Hc),
        .Hd(Hd),
        .Va(Va),
        .Vb(Vb),
        .Vc(Vc),
        .Vd(Vd),
        .PVsize(paddlesizeV),
        .PHsize(paddlesizeH)
    ) u2_inst (
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
        .B(B)
    );


    div_gen #(
        .div(div_paddle)
    ) u3_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(paddle_clk)
    );


    div_gen #(
        .div(div_ball1)
    ) u5_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(ball_clk1)
    );


    div_gen #(
        .div(div_ball2)
    ) u6_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(ball_clk2)
    );


    div_gen #(
        .div(div_ball3)
    ) u7_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(ball_clk3)
    );


    div_gen #(
        .div(div_ball4)
    ) u8_inst (
        .clk_in(clk),
        .reset(reset),
        .clk_out(ball_clk4)
    );


    score_display u4_inst (
        .score1(score1),
        .score2(score2),
        .seg1(seg1),
        .seg2(seg2),
        .bar(bar)
    );


endmodule


always_comb begin
    case (ball_speed)
        2'b00: ball_clk = ball_clk1;
        2'b01: ball_clk = ball_clk2;
        2'b10: ball_clk = ball_clk3;
        default: ball_clk = ball_clk4;
    endcase
end