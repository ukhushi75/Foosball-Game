module score(
    input int score1,
    input int score2,
    output logic [6:0] seg1,
    output logic [6:0] seg2,
    output logic bar
);
    assign bar = 0;

    // Score to 7-segment display logic for score1
    always_comb begin
        case (score1)
            0: seg1 = 7'b1000000;
            1: seg1 = 7'b1111001;
            2: seg1 = 7'b0100100;
            3: seg1 = 7'b0110000;
            4: seg1 = 7'b0011001;
            default: seg1 = 7'b0010010; 
        endcase
    end

    // Score to 7-segment display logic for score2
    always_comb begin
        case (score2)
            0: seg2 = 7'b1000000;
            1: seg2 = 7'b1111001;
            2: seg2 = 7'b0100100;
            3: seg2 = 7'b0110000;
            4: seg2 = 7'b0011001;
            default: seg2 = 7'b0010010; 
        endcase
    end

endmodule