module Torradeira(KEY, HEX0, HEX1, HEX2, HEX3, HEX4C, HEX5, HEX6D, HEX7, LEDR, LEDG, reset, CLOCK_50,
LCD_ON, LCD_BLON, LCD_RW, LCD_EN, LCD_RS,GPIO_0,GPIO_1, LCD_DATA, SW0);

input  [3:0]KEY; 
output [6:0]HEX0 = 7'b1111111;
output [6:0]HEX1 = 7'b1111111;
output [6:0]HEX2 = 7'b1111111;
output [6:0]HEX3 = 7'b1111111;
output [6:0]HEX4C;
output [6:0]HEX5 = 7'b1111111;
output [6:0]HEX6D;
output [6:0]HEX7 = 7'b1111111;
output [17:0]LEDR;
output [7:0]LEDG;
input reset;
input CLOCK_50;
input SW0;

reg resetarLCD = 0;  //Resetar o LCD
reg[2:0] estado_atual; //Guarda o estado_atual da maquina de estado
reg[2:0] estado_anterior; //Guarda o estado_anterior da maquina de estado
reg[17:0] controlaLEDR; //Controla o estado dos LEDs vermelhos
reg[7:0] controlaLEDG; //Controla o estado dos LEDs verdes
wire [3:0]KEYDeb; //Chaves com valor apos o Debouncing 
reg[3:0] tempo;
reg[3:0] tempoPosPreparo;
reg controle = 0;
wire segundo; //output de delay_1s
assign LEDR[17:0] = controlaLEDR; //Atrelando os Leds a variavel controlaLED
assign LEDG[7:0] = controlaLEDG;

//---> LCD Module 16X2
output LCD_ON;       // LCD Power ON/OFF
output LCD_BLON;      // LCD Back Light ON/OFF
output LCD_RW;      // LCD Read/Write Select, 0 = Write, 1 = Read
output LCD_EN;        // LCD Enable
output LCD_RS;        // LCD Command/Data Select, 0 = Command, 1 = Data
inout [7:0] LCD_DATA;  // LCD Data bus 8 bits
inout [35:0] GPIO_0,GPIO_1;

//    All inout port turn to tri-state
assign    GPIO_0        =    36'hzzzzzzzzz;
assign    GPIO_1        =    36'hzzzzzzzzz;


// Reset delay gives some time for peripherals to initialize
wire DLY_RST;
Reset_Delay r0(.iCLK(CLOCK_50),.oRESET(DLY_RST));

// Turn LCD ON
assign LCD_ON      =    1'b1;
assign LCD_BLON    =    1'b1;

LCD_TEST u1(
// Host Side
   .iCLK(CLOCK_50),
   .iRST_N(DLY_RST),
// LCD Side
   .LCD_DATA(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_EN(LCD_EN),
   .LCD_RS(LCD_RS),
   .estado_atual(estado_atual),
   .resetarLCD(resetarLCD)
);


delay_1s contagem(segundo, CLOCK_50);
		
dsp7_decoder contador(tempo, HEX6D);
dsp7_decoder contador1(tempoPosPreparo, HEX4C);


Debouncing b0(CLOCK_50, reset , KEY[0], KEYDeb[0]); //responsaveis pelo deboucing dos botoes
Debouncing b1(CLOCK_50, reset , KEY[1], KEYDeb[1]);
Debouncing b2(CLOCK_50, reset , KEY[2], KEYDeb[2]);
Debouncing b3(CLOCK_50, reset , KEY[3], KEYDeb[3]);	

//Corresponde aos estados da maquina
parameter desligado = 0, ligado = 1, preparo = 2, pronto = 3, queimando = 4, bomApetite = 5; 


always @(*) begin //Parte combinacional, tratamento da saida.
	
	case(estado_atual)
		desligado:
			begin //Desliga LEDS vermelhos e verdes
				controlaLEDR = 18'b000000000000000000;
				controlaLEDG = 8'b00000000;
			
				
			end
		ligado:
			begin //Acende os leds verdes alternados
				controlaLEDR = 18'b000000000000000000;
				controlaLEDG = 8'b10101010;
				
			end
		preparo:
			begin //Acende os leds vermelhos
				controlaLEDR = 18'b111111111111111111;
				controlaLEDG = 8'b00000000;
				
			end
		pronto:
			begin //Acende os leds verdes
				controlaLEDR = 18'b000000000000000000;
				controlaLEDG = 8'b11111111;
			
			end
		queimando:
			begin //Acende os leds vermelhos alternados
				controlaLEDR = 18'b101010101010101010;
				controlaLEDG = 8'b00000000;
				
			end
		bomApetite:
			begin //Acende os leds verdes 
				controlaLEDR = 18'b000000000000000000;
				controlaLEDG = 8'b10101010;

			end
	endcase
end

always@(posedge CLOCK_50, negedge reset) begin
	if(~reset) begin //Reseta os estados da maquina e seta estado atual como desligado;
		estado_atual <= desligado;
		estado_anterior <= desligado;
		tempo = 0;
		controle = 0;
		tempoPosPreparo = 0;
		resetarLCD = 1;
		end
	else if(segundo == 1 && estado_atual == preparo) //Decrementa o tempo escolhido pelo usuario quando o estado for preparo e tiver passado 1 segundo;
		tempo = tempo - 1;
		
	else if(controle == 1 && estado_atual != bomApetite && segundo == 1)
				tempoPosPreparo = tempoPosPreparo + 1; 
	else
		case(estado_atual)
			desligado: 
				begin
					resetarLCD = 0;
					if(KEYDeb[3] == 0 && estado_anterior == desligado) begin
						estado_atual <= ligado;
						resetarLCD = 1;
						estado_anterior <= desligado; end
				end
			ligado:
				begin
					resetarLCD = 0;
					if(KEYDeb[0] == 0) begin 
						tempo = 2; 
						resetarLCD = 1;
						estado_atual <= preparo;
						estado_anterior <= ligado;
						
						end
					else if(KEYDeb[1] == 0) begin
						tempo = 3; 
						resetarLCD = 1;
						estado_atual <= preparo;
						estado_anterior <= ligado;
						
						end
					else if(KEYDeb[2]== 0) begin
						tempo = 5;
						resetarLCD = 1;
						estado_atual <= preparo;
						estado_anterior <= ligado;
						
						end
				end
			preparo:
				begin
					resetarLCD = 0;
					if(tempo == 0 && estado_anterior == ligado) begin
							resetarLCD = 1;
							controle = 1;	
							estado_atual <= pronto; 
							estado_anterior <= preparo;	
											
					end
				end
			pronto:
				begin
					resetarLCD = 0;
					if(KEYDeb[3] == 0 && estado_anterior == preparo)begin
						resetarLCD = 1;
						estado_atual <= bomApetite;
						estado_anterior <= pronto; end
					if(tempoPosPreparo == 3)begin
						resetarLCD = 1;
						estado_atual <= queimando;
						estado_anterior <= pronto;
						tempo = 0; 
						end
				end
			queimando:
				begin
					resetarLCD = 0;
					if(KEYDeb[3] == 0 && estado_anterior == pronto) begin
						resetarLCD = 1;
						estado_atual <= bomApetite;
						estado_anterior <= queimando;
						controle = 0;
						
					end
				end
			bomApetite:
				begin
					resetarLCD = 0;
					if(SW0 == 1) begin
						estado_atual <= desligado;
						controle = 0;
						tempo = 0;
						resetarLCD = 1;
						tempoPosPreparo = 0;
						estado_anterior <= bomApetite; 
					end
				end
				
				
		endcase
	end
endmodule
