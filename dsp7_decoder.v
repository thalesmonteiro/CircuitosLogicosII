module dsp7_decoder (digit, seg);
input [3:0] digit;
output[6:0] seg;
reg   [6:0] seg;

always @ (digit)
case (digit)
    4'h0: seg = 7'b1000000;  //gfedcba
    4'h1: seg = 7'b1111001;
    4'h2: seg = 7'b0100100;
    4'h3: seg = 7'b0110000;
    4'h4: seg = 7'b0011001;
    4'h5: seg = 7'b0010010;
    4'h6: seg = 7'b0000010;
    4'h7: seg = 7'b1111000;
    4'h8: seg = 7'b0000000;
    4'h9: seg = 7'b0011000;
    
	default
	 seg = 7'b1000000;
endcase

endmodule
