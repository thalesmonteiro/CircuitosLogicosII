module delay_1s(delay,CLOCK_50);
	output reg delay;
	input CLOCK_50;
	reg [25:0] count;

always @(posedge CLOCK_50)
	begin
		if(count==26'd49_999_999)
			begin
				count<=26'd0;
				delay<=1;
			end
		else
			begin
				count<=count+1;
				delay<=0;
			end
	end
endmodule 