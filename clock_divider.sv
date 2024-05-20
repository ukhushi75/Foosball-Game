module clock_divider #(
    parameter integer DIV = 2  // Equivalent to VHDL's generic
)
(
    input logic clk_in,
    input logic reset,
    output logic clk_out
);

    logic [($clog2(DIV)-1):0] Qt; // Counter with size based on DIV
    logic temp; // Temporary storage for the output clock

    // Sequential logic to divide the clock
    always_ff @(posedge clk_in or negedge reset) begin
        if (!reset) begin
            Qt <= 0;
            temp <= 0;
        end else if (Qt == (DIV/2 - 1)) begin
            temp <= ~temp; // Toggle temp
            Qt <= 0;
        end else begin
            Qt <= Qt + 1;
        end
    end

    assign clk_out = temp; // Assign the divided clock to the output

endmodule