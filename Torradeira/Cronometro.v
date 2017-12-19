module Cronometro(CLOCK_50, HEX4C, HEX6D, reset);
	reg delay;
	input CLOCK_50;
	input reset;
	reg [25:0] count;
	reg [3:0]tempo = 5;
	reg [3:0] tempoCres = 0;
	reg controle;
	output [6:0]HEX4C;
	output [6:0]HEX6D;
	
	dsp7_decoder decrescente(tempo, HEX6D);
	dsp7_decoder crescente(tempoCres, HEX4C);
	
always @(posedge CLOCK_50, negedge reset)
	begin //1
	if(~reset)begin //2
		tempo <= 5; //reset do tempo para 5 seg
		tempoCres <= 0; end //2 
	
	else if(count==26'd49_999_999) //Se tiver passado 1 segundo
		begin //3
			count<=26'd0;
			delay<=1;
			if(tempo == 0) begin //4
				tempo <= 0;
				controle <= 0;end //4
			if(controle == 0 && tempo == 0) begin //6
					tempoCres <= tempoCres + 1; end //6
			else begin //5
				tempo <= tempo - 1; end //5
		
			
	    end //3
	else
		begin//7
			count<=count+1;
			delay<=0;
		end	//7
	end //1

endmodule 