module graphics_generator #(
	 parameter int H_active_size = 128,
	 parameter int H_blank_size  = 192,
	 parameter int H_sync_size  = 1024,
	 parameter int V_active_size  = 1080,
	 parameter int V_blank_size  = 3,
	 parameter int V_sync_size  = 45,
	 parameter int Pixel_vertical_size  = 600,
	 parameter int Pixel_horizontal_size  = 630,
	 parameter int Paddle_vertical_size = 60,
	 parameter int Paddle_horizontal_size = 15,
	 parameter int BallSize = 50
)(
	 input logic pixel_clk,
	 input logic paddle_clk,
	 input logic ball_clk,
	 input logic reset,
	 input logic Hactive, Vactive,
	 input logic Hsync, Vsync,
	 input logic dena,
	 input logic [3:0] direction_switch,
	 input logic start_game,
	 output int score1,
	 output int score2,
	 output [3:0] R, G, B
);

// Constants as localparam
localparam int CircleCenterX = 320;
localparam int CircleCenterY = 240;
localparam int CircleRadius = 100;
localparam int CircleThickness = 5;
localparam int GoalBoxWidth = 75;
localparam int GoalBoxHeight = 200;
localparam int GoalBoxYStart = 240 - (GoalBoxHeight / 2);
localparam int LeftGoalBoxXStart = 10;
localparam int RightGoalBoxXStart = 640 - GoalBoxWidth - 10;
localparam int LineThickness = 5;

// Signals as variables
int row_counter = 0;
int col_counter = 0;
int paddle1_pos_x, paddle2_pos_x, paddle1_pos_y, paddle2_pos_y;
int paddle3_pos_x, paddle3_pos_y, paddle4_pos_x, paddle4_pos_y;
int paddle5_pos_x, paddle5_pos_y, paddle6_pos_x, paddle6_pos_y;
int Ball_pos_x, Ball_pos_y;
int Ball_direction;
//enum {S0, S1} state;
logic move;


always_ff @(posedge paddle_clk or negedge reset) begin
 if (!reset) begin
	  // Initial positions when reset
	  paddle1_pos_x = 150; paddle1_pos_y = 120;
	  paddle2_pos_x = 490; paddle2_pos_y = 120;
	  paddle3_pos_x = 150; paddle3_pos_y = paddle1_pos_y + 240;
	  paddle4_pos_x = 490; paddle4_pos_y = paddle2_pos_y + 240;
	  paddle5_pos_x = 50;  paddle5_pos_y = paddle1_pos_y + 120;
	  paddle6_pos_x = 590; paddle6_pos_y = paddle2_pos_y + 120;
 end else begin
	  // Direction switch for paddle 1 movement
	  if (direction_switch[0]) begin
			if (paddle1_pos_y == Pixel_vertical_size - V_sync_size || paddle3_pos_y == Pixel_vertical_size - V_sync_size || paddle5_pos_y == Pixel_vertical_size - V_sync_size) begin
				 paddle1_pos_y = 0; paddle3_pos_y = 0; paddle5_pos_y = 0;
			end else begin
				 paddle1_pos_y = paddle1_pos_y + 1;
				 paddle3_pos_y = paddle3_pos_y + 1;
				 paddle5_pos_y = paddle5_pos_y + 1;
			end
	  end
	  if (direction_switch[1]) begin
			if (paddle1_pos_y == 0 || paddle3_pos_y == 0 || paddle5_pos_y == 0) begin
				 paddle1_pos_y = Pixel_vertical_size - V_sync_size; paddle3_pos_y = Pixel_vertical_size - V_sync_size; paddle5_pos_y = Pixel_vertical_size - V_sync_size;
			end else begin
				 paddle1_pos_y = paddle1_pos_y - 1;
				 paddle3_pos_y = paddle3_pos_y - 1;
				 paddle5_pos_y = paddle5_pos_y - 1;
			end
	  end
	  
	  // Direction switch for paddle 2 movement
	  if (direction_switch[2]) begin
			if (paddle2_pos_y == Pixel_vertical_size - V_sync_size || paddle4_pos_y == Pixel_vertical_size - V_sync_size || paddle6_pos_y == Pixel_vertical_size - V_sync_size) begin
				 paddle2_pos_y = 0; paddle4_pos_y = 0; paddle6_pos_y = 0;
			end else begin
				 paddle2_pos_y = paddle2_pos_y + 1;
				 paddle4_pos_y = paddle4_pos_y + 1;
				 paddle6_pos_y = paddle6_pos_y + 1;
			end
	  end
	  if (direction_switch[3]) begin
			if (paddle2_pos_y == 0 || paddle4_pos_y == 0 || paddle6_pos_y == 0) begin
				 paddle2_pos_y = Pixel_vertical_size - V_sync_size; paddle4_pos_y = Pixel_vertical_size - V_sync_size; paddle6_pos_y = Pixel_vertical_size - V_sync_size;
			end else begin
				 paddle2_pos_y = paddle2_pos_y - 1;
				 paddle4_pos_y = paddle4_pos_y - 1;
				 paddle6_pos_y = paddle6_pos_y - 1;
			end
	  end
 end
end



// Declare 'impact_diff' at a broader scope if it's used across different always blocks or does not need re-initialization
int impact_diff;

// Use a separate signal to enable/disable logic based on 'move' and include it in the sensitivity list of 'always_ff'
logic enable_ball_logic;


// Update 'enable_ball_logic' based on 'move' and 'reset' signals
always_comb begin
    enable_ball_logic = !reset || !move; // Logic to enable/disable ball updates based on 'move' and 'reset'.
end



always_ff @(posedge ball_clk or negedge reset) begin
 int impact_diff; // Variable declaration


if (!reset) begin
        Ball_pos_x <= 320;
        Ball_pos_y <= 240;
        Ball_direction <= Ball_direction + 1;
        if (Ball_direction > 5) Ball_direction <= 0;
    end else if (enable_ball_logic) begin



	  // Movement based on current Ball_direction
	  case (Ball_direction)
			0: begin Ball_pos_x <= Ball_pos_x + 1; Ball_pos_y <= Ball_pos_y - 1; end
			1: begin Ball_pos_x <= Ball_pos_x - 1; Ball_pos_y <= Ball_pos_y - 1; end
			2: begin Ball_pos_x <= Ball_pos_x - 1; Ball_pos_y <= Ball_pos_y + 1; end
			3: begin Ball_pos_x <= Ball_pos_x + 1; Ball_pos_y <= Ball_pos_y + 1; end
			4: Ball_pos_x <= Ball_pos_x + 1;
			5: Ball_pos_x <= Ball_pos_x - 1;
	  endcase

	  // Bounce with the board edges
	  if (Ball_pos_y == 0) begin
			if (Ball_direction == 0) Ball_direction <= 3;
			else if (Ball_direction == 1) Ball_direction <= 2;
	  end
	  if (Ball_pos_y == 480) begin
			if (Ball_direction == 2) Ball_direction <= 1;
			else if (Ball_direction == 3) Ball_direction <= 0;
	  end
	  if (Ball_pos_x == 20) begin
			if (Ball_direction == 1) Ball_direction <= 0;
			else if (Ball_direction == 2) Ball_direction <= 3;
			else if (Ball_direction == 5) Ball_direction <= 4;
	  end
	  if (Ball_pos_x == 620) begin
			if (Ball_direction == 0) Ball_direction <= 1;
			else if (Ball_direction == 3) Ball_direction <= 2;
			else if (Ball_direction == 4) Ball_direction <= 5;
	  end

	  // Paddle2 front collision
	  if ((Ball_pos_x + BallSize > paddle2_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle2_pos_x) &&
			(Ball_pos_y + BallSize > paddle2_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle2_pos_y + Paddle_vertical_size)) begin

			impact_diff = Ball_pos_y - paddle2_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the middle, go straight back
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Move ball to prevent sticking
	  end

	  // Paddle2 back collision
	  if ((Ball_pos_x - BallSize < paddle2_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle2_pos_x) &&
			(Ball_pos_y + BallSize > paddle2_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle2_pos_y + Paddle_vertical_size)) begin

			impact_diff = Ball_pos_y - paddle2_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent it from "sticking"
	  end


	  // Paddle3 front collision
	  if ((Ball_pos_x + BallSize > paddle3_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle3_pos_x) &&
			(Ball_pos_y + BallSize > paddle3_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle3_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle3_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Adjust ball position to prevent sticking
	  end

	  // Paddle3 back collision
	  if ((Ball_pos_x - BallSize < paddle3_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle3_pos_x) &&
			(Ball_pos_y + BallSize > paddle3_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle3_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle3_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent sticking
	  end



	  // Paddle1 front collision
	  if ((Ball_pos_x + BallSize > paddle1_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle1_pos_x) &&
			(Ball_pos_y + BallSize > paddle1_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle1_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle1_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Adjust ball position to prevent sticking
	  end

	  // Paddle1 back collision
	  if ((Ball_pos_x - BallSize < paddle1_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle1_pos_x) &&
			(Ball_pos_y + BallSize > paddle1_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle1_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle1_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent sticking
	  end


	  // Paddle4 front collision
	  if ((Ball_pos_x + BallSize > paddle4_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle4_pos_x) &&
			(Ball_pos_y + BallSize > paddle4_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle4_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle4_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Adjust ball position to prevent sticking
	  end

	  // Paddle4 back collision
	  if ((Ball_pos_x - BallSize < paddle4_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle4_pos_x) &&
			(Ball_pos_y + BallSize > paddle4_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle4_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle4_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent sticking
	  end


	  // Paddle5 front collision
	  if ((Ball_pos_x + BallSize > paddle5_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle5_pos_x) &&
			(Ball_pos_y + BallSize > paddle5_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle5_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle5_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Adjust ball position to prevent sticking
	  end

	  // Paddle5 back collision
	  if ((Ball_pos_x - BallSize < paddle5_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle5_pos_x) &&
			(Ball_pos_y + BallSize > paddle5_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle5_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle5_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent sticking
	  end

	  // Paddle6 front collision
	  if ((Ball_pos_x + BallSize > paddle6_pos_x - Paddle_horizontal_size) &&
			(Ball_pos_x < paddle6_pos_x) &&
			(Ball_pos_y + BallSize > paddle6_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle6_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle6_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top of the paddle, deflect upwards
				 Ball_direction <= 1;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom of the paddle, deflect downwards
				 Ball_direction <= 3;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 5;
			end

			Ball_pos_x <= Ball_pos_x - 5; // Adjust ball position to prevent sticking
	  end

	  // Paddle6 back collision
	  if ((Ball_pos_x - BallSize < paddle6_pos_x + Paddle_horizontal_size) &&
			(Ball_pos_x > paddle6_pos_x) &&
			(Ball_pos_y + BallSize > paddle6_pos_y - Paddle_vertical_size) &&
			(Ball_pos_y - BallSize < paddle6_pos_y + Paddle_vertical_size)) begin

			 impact_diff = Ball_pos_y - paddle6_pos_y; // Calculate the difference in impact point

			if (impact_diff > 0 && impact_diff < Paddle_vertical_size/3) begin
				 // Hit near the top edge of the paddle, deflect upwards
				 Ball_direction <= 0;
			end else if (impact_diff < 0 && impact_diff > -Paddle_vertical_size/3) begin
				 // Hit near the bottom edge of the paddle, deflect downwards
				 Ball_direction <= 2;
			end else begin
				 // Hit near the center, go straight
				 Ball_direction <= 4;
			end

			Ball_pos_x <= Ball_pos_x + 5; // Move the ball slightly away from the paddle to prevent sticking
	  end


	  // Repeat collision logic for other paddles and directions as needed
 end
end

// Define the state type
typedef enum {S0, S1} state_t;
state_t state, next_state; // Current and next state

//// Variables for scores (assuming they are integers)
//int score1 = 0;
//int score2 = 0;

// Move signal declaration
//logic move;

// Reset and State Transition Logic
always_ff @(posedge pixel_clk or negedge reset) begin
 if (!reset) begin
	  state <= S0; // Initial state
	  score1 <= 0; // Reset scores
	  score2 <= 0;
	  move <= 0; // Initially, no movement
 end else begin
	  // State transition logic here
	  state <= next_state; // Update state at each clock cycle
 end
end


// Combinational block for next state logic
always_comb begin
    next_state = state; // Default behavior
    case (state)
        S0: if (!start_game) next_state = S1; // Transition condition
        S1: if ((Ball_pos_y > 140 && Ball_pos_y < 340 && (Ball_pos_x < 21 || Ball_pos_x > 619))) next_state = S0;
        default: next_state = state;
    endcase
end



always_comb begin
if (dena == 1'b1) begin
 // Paddle 1 detection and color setting
 if ((col_counter >= paddle1_pos_x && col_counter < paddle1_pos_x + Paddle_horizontal_size) &&
	  (row_counter >= paddle1_pos_y && row_counter < paddle1_pos_y + Paddle_vertical_size)) begin
	R = 4'hF; // Full intensity Red
	G = 4'h0;
	B = 4'h0;
 end
 // Paddle 2 detection and color setting
 else if ((col_counter >= paddle2_pos_x && col_counter < paddle2_pos_x + Paddle_horizontal_size) &&
			 (row_counter >= paddle2_pos_y && row_counter < paddle2_pos_y + Paddle_vertical_size)) begin
	R = 4'h0;
	G = 4'h0;
	B = 4'hF; // Full intensity Blue
 end
 // Paddle 3 detection and color setting
 else if ((col_counter >= paddle3_pos_x && col_counter < paddle3_pos_x + Paddle_horizontal_size) &&
			 (row_counter >= paddle3_pos_y && row_counter < paddle3_pos_y + Paddle_vertical_size)) begin
	R = 4'hF; // Full intensity Red
	G = 4'h0;
	B = 4'h0;
 end
 // Paddle 4 detection and color setting
 else if ((col_counter >= paddle4_pos_x && col_counter < paddle4_pos_x + Paddle_horizontal_size) &&
			 (row_counter >= paddle4_pos_y && row_counter < paddle4_pos_y + Paddle_vertical_size)) begin
	R = 4'h0;
	G = 4'h0;
	B = 4'hF; // Full intensity Blue
 end
 // Paddle 5 detection and color setting
 else if ((col_counter >= paddle5_pos_x && col_counter < paddle5_pos_x + Paddle_horizontal_size) &&
			 (row_counter >= paddle5_pos_y && row_counter < paddle5_pos_y + Paddle_vertical_size)) begin
	R = 4'hF; // Full intensity Red
	G = 4'h0;
	B = 4'h0;
 end
 // Paddle 6 detection and color setting
 else if ((col_counter >= paddle6_pos_x && col_counter < paddle6_pos_x + Paddle_horizontal_size) &&
			 (row_counter >= paddle6_pos_y && row_counter < paddle6_pos_y + Paddle_vertical_size)) begin
	R = 4'h0;
	G = 4'h0;
	B = 4'hF; // Full intensity Blue
 end
 // Ball detection and color setting
 else if ((col_counter >= Ball_pos_x && col_counter < Ball_pos_x + BallSize) &&
			 (row_counter >= Ball_pos_y && row_counter < Ball_pos_y + BallSize)) begin
	R = 4'h0; // Assuming Ball is black
	G = 4'h0;
	B = 4'h0;
 end
 // White line on the screen
 else if ((col_counter >= 315 && col_counter <= 325) || 
			 (row_counter >= 0 && row_counter <= 10) || 
			 (row_counter >= 470 && row_counter <= 480) || 
			 // Goal boxes outlines
			 (((col_counter >= LeftGoalBoxXStart && col_counter <= LeftGoalBoxXStart + GoalBoxWidth) || 
				(col_counter >= RightGoalBoxXStart && col_counter <= RightGoalBoxXStart + GoalBoxWidth)) && 
			  ((row_counter >= GoalBoxYStart && row_counter <= GoalBoxYStart + LineThickness) || 
				(row_counter >= GoalBoxYStart + GoalBoxHeight - LineThickness && row_counter <= GoalBoxYStart + GoalBoxHeight))) || 
			 (((row_counter >= GoalBoxYStart && row_counter <= GoalBoxYStart + GoalBoxHeight) && 
				((col_counter >= LeftGoalBoxXStart && col_counter <= LeftGoalBoxXStart + LineThickness) || 
				 (col_counter >= RightGoalBoxXStart + GoalBoxWidth - LineThickness && col_counter <= RightGoalBoxXStart + GoalBoxWidth))))) begin
	R = 4'hF; // White
	G = 4'hF;
	B = 4'hF;
 end
 // Circle in the middle of the screen
 else if (((col_counter - CircleCenterX) * 2 + (row_counter - CircleCenterY) * 2 <= (CircleRadius + CircleThickness) ** 2) && 
			 ((col_counter - CircleCenterX) * 2 + (row_counter - CircleCenterY) * 2 >= (CircleRadius - CircleThickness) ** 2)) begin
	R = 4'hF; // White
	G = 4'hF;
	B = 4'hF;
 end
 // Default background color
 else begin
	R = 4'h0; // Green background
	G = 4'hF;
	B = 4'h0;
 end
end else begin
 // Screen is off or dena is low
 R = 4'hF;
 G = 4'h0;
 B = 4'hF;
 
 
 
end
end
endmodule