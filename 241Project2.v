// Animation

module toplevel (
	SW,
	CLOCK_50,
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK,						//	VGA BLANK
	VGA_SYNC,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B,
	LEDG,
	PS2_CLK,
	PS2_DAT,
	HEX0,
	HEX1,
	HEX2,
	LEDR,
);

input [17:0] SW;
input CLOCK_50;
output VGA_CLK;   				//	VGA Clock
output VGA_HS;					//	VGA H_SYNC
output VGA_VS;					//	VGA V_SYNC
output VGA_BLANK;				//	VGA BLANK
output VGA_SYNC;				//	VGA SYNC
output [9:0]	VGA_R;   				//	VGA Red[9:0]
output [9:0]	VGA_G;	 				//	VGA Green[9:0]
output [9:0]	VGA_B;   				//	VGA Blue[9:0]
output [8:0] LEDG;
output [17:0] LEDR;

wire is_0;
wire [3:0]stateW,stateG,stateG2;
wire [7:0]xpositionW,xpositionG,xpositionG2;
wire [6:0]ypositionW,ypositionG,ypositionG2;
wire [0:0]enable,enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5;

wire is_0g;
wire [2:0]direction_reg;
wire keyleft,keyright,keyup,keydown;
wire leftghost,rightghost,upghost,downghost;
wire leftghost2,rightghost2,upghost2,downghost2;
wire cherry;

wire ghostleft,ghostright,ghostup,ghostdown;
wire ghostleft2,ghostright2,ghostup2,ghostdown2;

wire [2:0]levelreg;

gameovermod m1 (CLOCK_50,xpositionW,xpositionG,ypositionW,ypositionG,xpositionG2,ypositionG2,gameover,ghostover1,ghostover2,eatghost);

wire gameover;
wire resetwire;

wire ghostover1;
wire ghostover2;
wire levelreset;

wire [6:0]HEX0w,HEX1w,HEX2w;
assign resetwire = ~gameover && SW[13];

assign resetwireg1 = ~gameover && SW[13] && ~ghostover1 && ~levelreset;
assign resetwireg2 = ~gameover && SW[13] && ~ghostover2 && ~levelreset;
assign resetwirepac = ~gameover && SW[13] && ~levelreset;
assign resetlevgame = ~gameover && SW[13] && ~levelreset;
xycounter U0 (keyleft,keyright,keyup,keydown,CLOCK_50,enable,resetwirepac,xpositionW,ypositionW,stateW,is_0,direction_reg,enabledelay1,enabledelay2,enabledelay3,enabledelay4);
xycounterG GHOST (ghostleft,ghostright,ghostup,ghostdown,CLOCK_50,enable,resetwireg1,xpositionG,ypositionG,stateG,is_0g,direction_regG,enabledelay1,enabledelay2,enabledelay3,enabledelay4);
xycounterG2 GHOST2 (ghostleft2,ghostright2,ghostup2,ghostdown2,CLOCK_50,enable,resetwireg2,xpositionG2,ypositionG2,stateG2,is_0g2,direction_regG2,enabledelay1,enabledelay2,enabledelay3,enabledelay4);

statecollision U1 (xpositionW,ypositionW,CLOCK_50,enable,resetwirepac,stateW);

statecollisionG GHOST1 (xpositionG,ypositionG,CLOCK_50,enable,resetwireg1,stateG);

statecollisionG2 GHOST23 (xpositionG2,ypositionG2,CLOCK_50,enable,resetwireg2,stateG2);

enablercount U2 (CLOCK_50,resetwire,enable,levelreg,enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5);

keyboard U3 (CLOCK_50,HEX01,resetwire,keyleft,keyright,keyup,keydown);

ghostai U9 (keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,xpositionW,ypositionW,xpositionG,ypositionG,ghostleft,ghostright,ghostup,ghostdown,SW[0],stateG,SW[17:14],eatghost);

ghostai2 U9a (keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,xpositionW,ypositionW,xpositionG2,ypositionG2,ghostleft2,ghostright2,ghostup2,ghostdown2,SW[0],stateG2,SW[17:14],eatghost);

scorecounter sc (CLOCK_50,resetwire,HEX0,HEX1,HEX2,score_w);

cherrypacpillLight CCPPL(resetlevgame,CLOCK_50,LEDR,LEDG,~cherry,eatghost);

wire [6:0]HEX01;
wire [6:0]HEX11;
wire [6:0]HEX21;
wire [6:0]HEX31;
wire [6:0]HEX41;
wire [6:0]HEX51;
wire [6:0]HEX61;
wire [6:0]HEX71;

wire [9:0] score_w;

output [6:0]HEX0;
output [6:0]HEX1;
output [6:0]HEX2;

wire [1:0]pacpill;
wire eat_ghost;
update_food_reg U29 (CLOCK_50,enable_out,food_not_eaten,xpositionW,ypositionW,resetwire,score_w,levelreset,cherry,pacpill,levelreg);
eatghosts EG (CLOCK_50,resetlevgame,pacpill,eatghost);
wire [93:0] food_not_eaten;
wire enableout;

 PS2_Demo U5 (
	// Inputs
	CLOCK_50,
	resetwire,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX01,
	HEX11,
	HEX21,
	HEX31,
	HEX41,
	HEX51,
	HEX61,
	HEX71
);

wire [7:0] receivedata;
inout				PS2_CLK;
inout				PS2_DAT;

animation ANIM (
		CLOCK_50,						//	On Board 50 MHz
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		xpositionW, 
		ypositionW,
		xpositionG,
		ypositionG,
		xpositionG2,
		ypositionG2,
		enabledelay5,
		direction_reg,
		food_not_eaten,
		eatghost, // eatpill
		cherry,
		pacpill
);

endmodule


module eatghosts (CLOCK_50,resetwire,pacpill,eatghost);

input CLOCK_50,resetwire;
input [1:0]pacpill;
output reg eatghost;
reg [31:0]counter1,counter2;

always@(posedge CLOCK_50)
begin
	if (~resetwire)
		begin
			counter1=0;
			counter2=0;
		end
	else 
		begin
			if ((counter1!=500000000 && counter1!=0) | (counter2!=500000000 && counter2!=0))
				begin
					eatghost=1'b1;
				end
			else
				begin
					eatghost=1'b0;
				end
			if (pacpill[0]==0 && counter1!=500000000)
				begin
					counter1=counter1+1;
				end
			if (pacpill[1]==0 && counter2!= 500000000)
				begin
					counter2=counter2+1;
				end
		end	
end



endmodule

//pacpill lights

module cherrypacpillLight(reset,CLOCK_50,LEDR,LEDG,cherry,pacpill);
reg [31:0]counter;
input reset,CLOCK_50,cherry,pacpill;
output reg [17:0]LEDR;
output reg [8:0]LEDG;

reg [31:0]counter2;

always@(posedge CLOCK_50)

begin
	if (~reset)
		counter2=0;
	else
		begin
			if (counter2==99999999)
				counter2=0;
		else
			counter2=counter2+1;
		end
end




always@(posedge CLOCK_50)

begin

if (reset&& pacpill)

begin

if (counter2==0)

begin

LEDG[0]=1'b1;

LEDG[1]=1'b1;

LEDG[2]=1'b1;

LEDG[3]=1'b1;

LEDG[4]=1'b1;

LEDG[5]=1'b1;

LEDG[6]=1'b1;

LEDG[7]=1'b1;

LEDG[8]=1'b1;

end

if (counter2==49999999)

begin

LEDG[0]=1'b0;

LEDG[1]=1'b0;

LEDG[2]=1'b0;

LEDG[3]=1'b0;

LEDG[4]=1'b0;

LEDG[5]=1'b0;

LEDG[6]=1'b0;

LEDG[7]=1'b0;

LEDG[8]=1'b0;

end

// else LEDG=LEDG;

end

else 

begin

LEDG[0]=1'b0;

LEDG[1]=1'b0;

LEDG[2]=1'b0;

LEDG[3]=1'b0;

LEDG[4]=1'b0;

LEDG[5]=1'b0;

LEDG[6]=1'b0;

LEDG[7]=1'b0;

LEDG[8]=1'b0;

end

end







//cherry lights

always@(posedge CLOCK_50)

begin

if (~reset)

counter=0;

else

if (cherry)

begin

if (counter==27'b110011011111111001100000001)

counter=27'b110011011111111001100000001;

else

counter=counter+1;

end

end




always@(posedge CLOCK_50)

if (reset&& cherry)

begin

if (counter==25'b1000100101010100010000000)

begin

LEDR[0] = 1'b1;

LEDR[2] = 1'b1;

LEDR[4] = 1'b1;

LEDR[6] = 1'b1;

LEDR[8] = 1'b1;

LEDR[10] = 1'b1;

LEDR[12] = 1'b1;

LEDR[14] = 1'b1;

LEDR[16] = 1'b1;

LEDR[1] = 1'b0;

LEDR[3] = 1'b0;

LEDR[5] = 1'b0;

LEDR[7] = 1'b0;

LEDR[9] = 1'b0;

LEDR[11] = 1'b0;

LEDR[13] = 1'b0;

LEDR[15] = 1'b0;

LEDR[17] = 1'b0;

end

if (counter==26'b10001001010101000100000000)

begin

LEDR[0] = 1'b0;

LEDR[2] = 1'b0;

LEDR[4] = 1'b0;

LEDR[6] = 1'b0;

LEDR[8] = 1'b0;

LEDR[10] = 1'b0;

LEDR[12] = 1'b0;

LEDR[14] = 1'b0;

LEDR[16] = 1'b0;

LEDR[1] = 1'b1;

LEDR[3] = 1'b1;

LEDR[5] = 1'b1;

LEDR[7] = 1'b1;

LEDR[9] = 1'b1;

LEDR[11] = 1'b1;

LEDR[13] = 1'b1;

LEDR[15] = 1'b1;

LEDR[17] = 1'b1;

end

if (counter==26'b11001101111111100110000000)

begin

LEDR[0] = 1'b1;

LEDR[2] = 1'b1;

LEDR[4] = 1'b1;

LEDR[6] = 1'b1;

LEDR[8] = 1'b1;

LEDR[10] = 1'b1;

LEDR[12] = 1'b1;

LEDR[14] = 1'b1;

LEDR[16] = 1'b1;

LEDR[1] = 1'b0;

LEDR[3] = 1'b0;

LEDR[5] = 1'b0;

LEDR[7] = 1'b0;

LEDR[9] = 1'b0;

LEDR[11] = 1'b0;

LEDR[13] = 1'b0;

LEDR[15] = 1'b0;

LEDR[17] = 1'b0;

end

if (counter==27'b100010010101010001000000000)

begin

LEDR[0] = 1'b0;

LEDR[2] = 1'b0;

LEDR[4] = 1'b0;

LEDR[6] = 1'b0;

LEDR[8] = 1'b0;

LEDR[10] = 1'b0;

LEDR[12] = 1'b0;

LEDR[14] = 1'b0;

LEDR[16] = 1'b0;

LEDR[1] = 1'b1;

LEDR[3] = 1'b1;

LEDR[5] = 1'b1;

LEDR[7] = 1'b1;

LEDR[9] = 1'b1;

LEDR[11] = 1'b1;

LEDR[13] = 1'b1;

LEDR[15] = 1'b1;

LEDR[17] = 1'b1;

end

if (counter==27'b101010111010100101010000000)

begin

LEDR[0] = 1'b1;

LEDR[2] = 1'b1;

LEDR[4] = 1'b1;

LEDR[6] = 1'b1;

LEDR[8] = 1'b1;

LEDR[10] = 1'b1;

LEDR[12] = 1'b1;

LEDR[14] = 1'b1;

LEDR[16] = 1'b1;

LEDR[1] = 1'b0;

LEDR[3] = 1'b0;

LEDR[5] = 1'b0;

LEDR[7] = 1'b0;

LEDR[9] = 1'b0;

LEDR[11] = 1'b0;

LEDR[13] = 1'b0;

LEDR[15] = 1'b0;

LEDR[17] = 1'b0;

end

if (counter==27'b110011011111111001100000000)

begin

LEDR[0] = 1'b1;

LEDR[2] = 1'b1;

LEDR[4] = 1'b1;

LEDR[6] = 1'b1;

LEDR[8] = 1'b1;

LEDR[10] = 1'b1;

LEDR[12] = 1'b1;

LEDR[14] = 1'b1;

LEDR[16] = 1'b1;

LEDR[1] = 1'b1;

LEDR[3] = 1'b1;

LEDR[5] = 1'b1;

LEDR[7] = 1'b1;

LEDR[9] = 1'b1;

LEDR[11] = 1'b1;

LEDR[13] = 1'b1;

LEDR[15] = 1'b1;

LEDR[17] = 1'b1;

end

end// else LEDR=LEDR?

else

begin

LEDR[0] = 1'b0;

LEDR[2] = 1'b0;

LEDR[4] = 1'b0;

LEDR[6] = 1'b0;

LEDR[8] = 1'b0;

LEDR[10] = 1'b0;

LEDR[12] = 1'b0;

LEDR[14] = 1'b0;

LEDR[16] = 1'b0;

LEDR[1] = 1'b0;

LEDR[3] = 1'b0;

LEDR[5] = 1'b0;

LEDR[7] = 1'b0;

LEDR[9] = 1'b0;

LEDR[11] = 1'b0;

LEDR[13] = 1'b0;

LEDR[15] = 1'b0;

LEDR[17] = 1'b0;

end

endmodule

module scorecounter (clock,resetwire,HEX0,HEX1,HEX2,scorecount);
	input resetwire,clock;
	output [6:0]HEX0,HEX1,HEX2;
	reg [3:0]hexconvert0,hexconvert1,hexconvert2;
	input [9:0] scorecount;

	initial
		begin
			hexconvert0 = 0;
			hexconvert1 = 0;
			hexconvert2 = 0;
		end

	hexerpoutput H0 (HEX0,HEX1,HEX2,hexconvert0,hexconvert1,hexconvert2);

	always@(scorecount)
		begin
			hexconvert0=scorecount%10;
			if ((scorecount - hexconvert0)%100 == 10)
				hexconvert1 = 1;
			else if ((scorecount - hexconvert0)%100 == 20)
				hexconvert1 = 2;
			else if ((scorecount - hexconvert0)%100 == 30)
				hexconvert1 = 3;
			else if ((scorecount - hexconvert0)%100 == 40)
				hexconvert1 = 4;
			else if ((scorecount - hexconvert0)%100 == 50)
				hexconvert1 = 5;
			else if ((scorecount - hexconvert0)%100 == 60)
				hexconvert1 = 6;
			else if ((scorecount - hexconvert0)%100 == 70)
				hexconvert1 = 7;
			else if ((scorecount - hexconvert0)%100 == 80)
				hexconvert1 = 8;
			else if ((scorecount - hexconvert0)%100 == 90)
				hexconvert1 = 9;
			else hexconvert1 = 0;
			if ((scorecount - hexconvert0 - hexconvert1 * 10) == 100)
				hexconvert2 = 1;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 200)
				hexconvert2 = 2;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 300)
				hexconvert2 = 3;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 400)
				hexconvert2 = 4;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 500)
				hexconvert2 = 5;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 600)
				hexconvert2 = 6;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 700)
				hexconvert2 = 7;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 800)
				hexconvert2 = 8;
			else if ((scorecount - hexconvert0 - hexconvert1 * 10) == 900)
				hexconvert2 = 9;
			else hexconvert2 = 0;
		end
endmodule

module hexerpoutput (HEX0,HEX1,HEX2,HEX0w,HEX1w,HEX2w);
	output reg [6:0]HEX0,HEX1,HEX2;
	input [3:0]HEX0w,HEX1w,HEX2w;

	always@(*)
		begin
			case (HEX0w)
				4'b0000:HEX0=7'b1000000;
				4'b0001:HEX0=7'b1111001;
				4'b0010:HEX0=7'b0100100;
				4'b0011:HEX0=7'b0110000;
				4'b0100:HEX0=7'b0011001;
				4'b0101:HEX0=7'b0010010;
				4'b0110:HEX0=7'b0000010;
				4'b0111:HEX0=7'b1111000;
				4'b1000:HEX0=7'b0000000;
				4'b1001:HEX0=7'b0010000;
			endcase
			case (HEX1w)
				4'b0000:HEX1=7'b1000000;
				4'b0001:HEX1=7'b1111001;
				4'b0010:HEX1=7'b0100100;
				4'b0011:HEX1=7'b0110000;
				4'b0100:HEX1=7'b0011001;
				4'b0101:HEX1=7'b0010010;
				4'b0110:HEX1=7'b0000010;
				4'b0111:HEX1=7'b1111000;
				4'b1000:HEX1=7'b0000000;
				4'b1001:HEX1=7'b0010000;
			endcase
			case (HEX2w)
				4'b0000:HEX2=7'b1000000;
				4'b0001:HEX2=7'b1111001;
				4'b0010:HEX2=7'b0100100;
				4'b0011:HEX2=7'b0110000;
				4'b0100:HEX2=7'b0011001;
				4'b0101:HEX2=7'b0010010;
				4'b0110:HEX2=7'b0000010;
				4'b0111:HEX2=7'b1111000;
				4'b1000:HEX2=7'b0000000;
				4'b1001:HEX2=7'b0010000;
			endcase
		end
endmodule

module gameovermod (CLOCK_50,xpositionW,xpositionG,ypositionW,ypositionG,xpositionG2,ypositionG2,gameover,ghostover1,ghostover2,pacpill);

input CLOCK_50,pacpill;
input [7:0]xpositionW,xpositionG,xpositionG2;
input [6:0]ypositionW,ypositionG,ypositionG2;
output reg gameover, ghostover1, ghostover2;

always@(posedge CLOCK_50) // no posedge before
if (~pacpill)
begin

if (   (xpositionW==xpositionG)   &&((ypositionW<ypositionG)&&(ypositionG-ypositionW<4'b1010))) // pac approaches from up
gameover=1'b1;
else if (   (xpositionW==xpositionG)   &&((ypositionW>ypositionG)&&(ypositionW-ypositionG<4'b1010))) // pac approaches from down
gameover=1'b1;
else if (   (ypositionW==ypositionG)   &&((xpositionW<xpositionG)&&(xpositionG-xpositionW<4'b1010))) // pac approaches from left
gameover=1'b1;
else if (   (ypositionW==ypositionG)   &&((xpositionW>xpositionG)&&(xpositionW-xpositionG<4'b1010))) // pac approaches from right
gameover=1'b1;
else if ((xpositionW==xpositionG) && (ypositionW==ypositionG)) // same spot
gameover=1'b1;

else if (   (xpositionW==xpositionG2)   &&((ypositionW<ypositionG2)&&(ypositionG2-ypositionW<4'b1010))) // pac approaches from up
gameover=1'b1;
else if (   (xpositionW==xpositionG2)   &&((ypositionW>ypositionG2)&&(ypositionW-ypositionG2<4'b1010))) // pac approaches from down
gameover=1'b1;
else if (   (ypositionW==ypositionG2)   &&((xpositionW<xpositionG2)&&(xpositionG2-xpositionW<4'b1010))) // pac approaches from left
gameover=1'b1;
else if (   (ypositionW==ypositionG2)   &&((xpositionW>xpositionG2)&&(xpositionW-xpositionG2<4'b1010))) // pac approaches from right
gameover=1'b1;
else if ((xpositionW==xpositionG2) && (ypositionW==ypositionG2)) // same spot
gameover=1'b1;

else
gameover=1'b0;
end
else
begin

if (   (xpositionW==xpositionG)   &&((ypositionW<ypositionG)&&(ypositionG-ypositionW<4'b1010))) // pac approaches from up
ghostover1=1'b1;
else if (   (xpositionW==xpositionG)   &&((ypositionW>ypositionG)&&(ypositionW-ypositionG<4'b1010))) // pac approaches from down
ghostover1=1'b1;
else if (   (ypositionW==ypositionG)   &&((xpositionW<xpositionG)&&(xpositionG-xpositionW<4'b1010))) // pac approaches from left
ghostover1=1'b1;
else if (   (ypositionW==ypositionG)   &&((xpositionW>xpositionG)&&(xpositionW-xpositionG<4'b1010))) // pac approaches from right
ghostover1=1'b1;
else if ((xpositionW==xpositionG) && (ypositionW==ypositionG)) // same spot
ghostover1=1'b1;
else
ghostover1=1'b0;

if (   (xpositionW==xpositionG2)   &&((ypositionW<ypositionG2)&&(ypositionG2-ypositionW<4'b1010))) // pac approaches from up
ghostover2=1'b1;
else if (   (xpositionW==xpositionG2)   &&((ypositionW>ypositionG2)&&(ypositionW-ypositionG2<4'b1010))) // pac approaches from down
ghostover2=1'b1;
else if (   (ypositionW==ypositionG2)   &&((xpositionW<xpositionG2)&&(xpositionG2-xpositionW<4'b1010))) // pac approaches from left
ghostover2=1'b1;
else if (   (ypositionW==ypositionG2)   &&((xpositionW>xpositionG2)&&(xpositionW-xpositionG2<4'b1010))) // pac approaches from right
ghostover2=1'b1;
else if ((xpositionW==xpositionG2) && (ypositionW==ypositionG2)) // same spot
ghostover2=1'b1;
else
ghostover2=1'b0;

end

endmodule

module ghostai (keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,xpositionW,ypositionW,xpositionG,ypositionG,ghostleft,ghostright,ghostup,ghostdown,selectai,statein,random,pacpill);

input selectai,keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,pacpill;

parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down		

input [7:0] xpositionW;
input [7:0] xpositionG;
input [6:0] ypositionW;
input [6:0] ypositionG;
input [3:0] statein;
input [3:0] random;
output reg ghostleft,ghostright,ghostup,ghostdown;


always@(posedge enabledelay5)
begin
if (pacpill==1)
begin
if (selectai)
begin
ghostleft=keyright;
ghostright=keyleft;
ghostup=keydown;
ghostdown=keyup;
end
else
begin
if (ypositionG < ypositionW &&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b1;
ghostdown=1'b0;
end
else if (xpositionG > xpositionW &&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b1;
ghostup=1'b0;
ghostdown=1'b0;
end
else if (xpositionG < xpositionW &&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
begin
ghostleft=1'b1;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b0;
end
else if (ypositionG > ypositionW &&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b1;
end
else
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b0;
end
end
end
else
begin
if (selectai)
begin
ghostleft=keyleft;
ghostright=keyright;
ghostup=keyup;
ghostdown=keydown;
end
else
begin
if (ypositionG < ypositionW &&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b1;
end
else if (xpositionG > xpositionW &&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
begin
ghostleft=1'b1;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b0;
end
else if (xpositionG < xpositionW &&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b1;
ghostup=1'b0;
ghostdown=1'b0;
end
else if (ypositionG > ypositionW &&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b1;
ghostdown=1'b0;
end
else
begin
ghostleft=1'b0;
ghostright=1'b0;
ghostup=1'b0;
ghostdown=1'b0;
end
end
end
end
endmodule



module ghostai2 (keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,xpositionW,ypositionW,xpositionG,ypositionG,ghostleft,ghostright,ghostup,ghostdown,selectai,statein,random,pacpill);

input selectai,keyleft,keyright,keyup,keydown,CLOCK_50,enabledelay5,pacpill;

parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down		

input [7:0] xpositionW;
input [7:0] xpositionG;
input [6:0] ypositionW;
input [6:0] ypositionG;
input [3:0] statein;
output reg ghostleft,ghostright,ghostup,ghostdown;
input [3:0] random;

always@(posedge enabledelay5)
begin
	if (pacpill==1)
		begin
			if (selectai)
				begin
					ghostleft=keyright;
					ghostright=keyleft;
					ghostup=keydown;
					ghostdown=keyup;
				end
			else
				begin
					if (xpositionG > xpositionW &&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b1;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
					else if (ypositionG < ypositionW &&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b1;
						ghostdown=1'b0;
						end
					else if (ypositionG > ypositionW &&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b1;
						end
					else if (xpositionG < xpositionW &&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
						begin
						ghostleft=1'b1;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
					else
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
				end

		end
	else
		begin
			if (selectai)
				begin
					ghostleft=keyleft;
					ghostright=keyright;
					ghostup=keyup;
					ghostdown=keydown;
				end
			else
				begin
					if (xpositionG > xpositionW &&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
						begin
						ghostleft=1'b1;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
					else if (ypositionG < ypositionW &&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b1;
						end
					else if (ypositionG > ypositionW &&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b1;
						ghostdown=1'b0;
						end
					else if (xpositionG < xpositionW &&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
						begin
						ghostleft=1'b0;
						ghostright=1'b1;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
					else
						begin
						ghostleft=1'b0;
						ghostright=1'b0;
						ghostup=1'b0;
						ghostdown=1'b0;
						end
				end
		end
end
endmodule



// Not bug-proof for more than one direction pressed
// Keeps direction until new direction chosen or until it stops
// *** Make sure enable is only on for ONE cycle
module xycounter (left,
						right,
						up,
						down,
						clock,
						enable,
						reset,
						xposition,
						yposition,
						statein,
						is_0,
						direction_reg,
						enabledelay1,
						enabledelay2,
						enabledelay3,
						enabledelay4
						);

input left, // Left on Keyboard
		right, // Right on Keyboard
		up, // Up on Keyboard
		down, // Down on Keyboard
		clock, // 50 MHz Clock
		enable, // X Hz Enable
		enabledelay1,
		enabledelay2,
		enabledelay3,
		enabledelay4,
		reset; // Reset
		
		
		
// Statein is current state, decides which direction is possible
// XY positions determine next state (after posedge update), 
// decides which direction is possible in the NEXT posedge update

input [3:0]statein;

parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down							
							
output reg [7:0]xposition; // The x-position of the pacman
output reg [6:0]yposition; // The y-position of the pacman
reg [2:0]direction; // 000 is left
					//	001 is right
					// 010 is up
					// 011 is down
					// 100 is idle
output [2:0]direction_reg;
assign direction_reg=direction;			
output is_0;
wire isx0;
wire isy0;

assign is_0 = isx0;

modulox m1531 (xposition,isx0,enabledelay4,clock);
moduloy m1596 (yposition,isy0,enabledelay4,clock);
//ymodule U0

// Will only allow direction to be changed at 10 pixel intervals
// Can split up conditions for the direction to let it switch at any interval from left/right to right/left or up/down to down/up					

always@(*) // Choose Direction
begin
	if (reset==1'b0)
		direction=3'b100;
	else
	if (enabledelay2==1'b1)
		begin
		
		if ((left&&right)||(down&&up))
		direction<=direction;
		
		else if (isx0&&isy0&&left&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (isx0&&isy0&&right&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (isx0&&isy0&&up&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (isx0&&isy0&&down&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else if (direction==3'b000&&isx0&&isy0&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&isx0&&isy0&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&isx0&&isy0&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&isx0&&isy0&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else if (direction==3'b001&&left&&(statein==LR))
		direction<=3'b000;
		else if (direction==3'b000&&right&&(statein==LR))
		direction<=3'b001;
		else if (direction==3'b010&&down&&(statein==UD))
		direction<=3'b011;
		else if (direction==3'b011&&up&&(statein==UD))
		direction<=3'b010;
		
		else if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else
		direction <= direction;
		
		/*
		else if (direction==3'b100&&left&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&down&&(statein==LR))
		direction<=direction;
		else if (direction==3'b100&&right&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&up&&(statein==LR))
		direction<=direction;
		
		// add more conditions
		*/
		//else direction <= 3'b100;
		
		end
end

always@(posedge clock or negedge reset) // Update x/y positions
begin
	if (reset==1'b0)
		begin
		xposition<=10;
		yposition<=100;
		end
	else if (enabledelay3==1'b1)
		begin
		if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition-1;
		yposition<=yposition;
		end
		if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition+1;
		yposition<=yposition;
		end
		if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition-1;
		end
		if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition+1;
		end // else?
		if (direction==3'b100)
		begin
		xposition<=xposition;
		yposition<=yposition;
		end
	end
end
endmodule
		

		
		
		

module xycounterG (left,
						right,
						up,
						down,
						clock,
						enable,
						reset,
						xposition,
						yposition,
						statein,
						is_0,
						direction_reg,
						enabledelay1,
						enabledelay2,
						enabledelay3,
						enabledelay4);

input left, // Left on Keyboard
		right, // Right on Keyboard
		up, // Up on Keyboard
		down, // Down on Keyboard
		clock, // 50 MHz Clock
		enable, // X Hz Enable
		enabledelay1,
		enabledelay2,
		enabledelay3,
		enabledelay4,
		reset; // Reset
		
// Statein is current state, decides which direction is possible
// XY positions determine next state (after posedge update), 
// decides which direction is possible in the NEXT posedge update

input [3:0]statein;

parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down							
							
output reg [7:0]xposition; // The x-position of the pacman
output reg [6:0]yposition; // The y-position of the pacman
reg [2:0]direction; // 000 is left
					//	001 is right
					// 010 is up
					// 011 is down
					// 100 is idle
output [2:0]direction_reg;
assign direction_reg=direction;			
output is_0;
wire isx0;
wire isy0;

assign is_0 = isx0;

modulox Ulaa (xposition,isx0,enabledelay4,clock);
moduloy Unaa (yposition,isy0,enabledelay4,clock);
//ymodule U0

// Will only allow direction to be changed at 10 pixel intervals
// Can split up conditions for the direction to let it switch at any interval from left/right to right/left or up/down to down/up					

always@(*) // Choose Direction
begin
	if (reset==1'b0)
		direction=3'b100;
	else
	if (enabledelay2==1'b1)
		begin
		
		if ((left&&right)||(down&&up))
		direction<=direction;
		
		else if (isx0&&isy0&&left&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (isx0&&isy0&&right&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (isx0&&isy0&&up&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (isx0&&isy0&&down&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else if (direction==3'b000&&isx0&&isy0&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&isx0&&isy0&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&isx0&&isy0&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&isx0&&isy0&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		// change these conditions?
		else if (direction==3'b001&&left&&(statein==LR))
		direction<=3'b000;
		else if (direction==3'b000&&right&&(statein==LR))
		direction<=3'b001;
		else if (direction==3'b010&&down&&(statein==UD))
		direction<=3'b011;
		else if (direction==3'b011&&up&&(statein==UD))
		direction<=3'b010;
		
		else if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else
		direction <= direction;
		
		/*
		else if (direction==3'b100&&left&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&down&&(statein==LR))
		direction<=direction;
		else if (direction==3'b100&&right&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&up&&(statein==LR))
		direction<=direction;
		*/
		// add more conditions
		
		//else direction <= 3'b100;
		
		end
end

always@(posedge clock or negedge reset) // Update x/y positions
begin
	if (reset==1'b0)
		begin
		xposition<=50;
		yposition<=40;
		end
	else if (enabledelay3==1'b1)
		begin
		if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition-1;
		yposition<=yposition;
		end
		if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition+1;
		yposition<=yposition;
		end
		if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition-1;
		end
		if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition+1;
		end
		if (direction==3'b100)
		begin
		xposition<=xposition;
		yposition<=yposition;
		end
	end
end

endmodule				
		
		

module xycounterG2 (left,
						right,
						up,
						down,
						clock,
						enable,
						reset,
						xposition,
						yposition,
						statein,
						is_0,
						direction_reg,
						enabledelay1,
						enabledelay2,
						enabledelay3,
						enabledelay4);

input left, // Left on Keyboard
		right, // Right on Keyboard
		up, // Up on Keyboard
		down, // Down on Keyboard
		clock, // 50 MHz Clock
		enable, // X Hz Enable
		enabledelay1,
		enabledelay2,
		enabledelay3,
		enabledelay4,
		reset; // Reset
		
// Statein is current state, decides which direction is possible
// XY positions determine next state (after posedge update), 
// decides which direction is possible in the NEXT posedge update

input [3:0]statein;

parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down							
							
output reg [7:0]xposition; // The x-position of the pacman
output reg [6:0]yposition; // The y-position of the pacman
reg [2:0]direction; // 000 is left
					//	001 is right
					// 010 is up
					// 011 is down
					// 100 is idle
output [2:0]direction_reg;
assign direction_reg=direction;			
output is_0;
wire isx0;
wire isy0;

assign is_0 = isx0;

modulox U7 (xposition,isx0,enabledelay4,clock);
moduloy U8 (yposition,isy0,enabledelay4,clock);
//ymodule U0

// Will only allow direction to be changed at 10 pixel intervals
// Can split up conditions for the direction to let it switch at any interval from left/right to right/left or up/down to down/up					

always@(*) // Choose Direction
begin
	if (reset==1'b0)
		direction=3'b100;
	else
	if (enabledelay2==1'b1)
		begin
		
		if ((left&&right)||(down&&up))
		direction<=direction;
		
		else if (isx0&&isy0&&left&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (isx0&&isy0&&right&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (isx0&&isy0&&up&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (isx0&&isy0&&down&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else if (direction==3'b000&&isx0&&isy0&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&isx0&&isy0&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&isx0&&isy0&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&isx0&&isy0&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else if (direction==3'b001&&left&&(statein==LR))
		direction<=3'b000;
		else if (direction==3'b000&&right&&(statein==LR))
		direction<=3'b001;
		else if (direction==3'b010&&down&&(statein==UD))
		direction<=3'b011;
		else if (direction==3'b011&&up&&(statein==UD))
		direction<=3'b010;
		
		
		else if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		else
		direction <= direction;
		
		/*
		else if (direction==3'b100&&left&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&down&&(statein==LR))
		direction<=direction;
		else if (direction==3'b100&&right&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&up&&(statein==LR))
		direction<=direction;
		*/
		// add more conditions
		
		//else direction <= 3'b100;
		
		end
end

always@(posedge clock or negedge reset) // Update x/y positions
begin
	if (reset==1'b0)
		begin
		xposition<=100;
		yposition<=40;
		end
	else if (enabledelay3==1'b1)
		begin
		if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition-1;
		yposition<=yposition;
		end
		if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		begin
		xposition<=xposition+1;
		yposition<=yposition;
		end
		if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition-1;
		end
		if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		begin
		xposition<=xposition;
		yposition<=yposition+1;
		end // else?
		if (direction==3'b100)
		begin
		xposition<=xposition;
		yposition<=yposition;
		end
	end
end

endmodule					
		
		
module update_food_reg(enable_in,enable_out,food_not_eaten,xposition,yposition,reset,score_out,levelreset,cherry,pacpill,levelreg);
	output reg [93:0] food_not_eaten;
	output reg [0:0] enable_out;
	input enable_in;
	input reset;
	input [7:0] xposition;
	input [6:0] yposition;
	reg [9:0] score;
	output [9:0] score_out;
	output reg levelreset;
	output reg cherry;
	output reg [1:0]pacpill;
	output reg [2:0]levelreg;
	initial
		begin
			food_not_eaten[93:0]=94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000111;
			score=10'b0000000000;
			cherry = 1;
			pacpill = 2'b11;
		end
	
	assign score_out = score;
	
	always@(posedge enable_in,negedge reset)
	begin
		if (~reset)
			begin
				food_not_eaten[93:0]=94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000111;
				score=10'b0000000000;
				levelreset=1'b0;
				cherry = 1;
				pacpill = 2'b11;
				levelreg=0;
			end
		else if (food_not_eaten==0)
			begin
				food_not_eaten[93:0]=94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000111;
				levelreset=1'b1;
				cherry = 1;
				pacpill = 2'b11;
				levelreg = levelreg + 1;
			end
		else
			begin
				levelreset=1'b0;
				if (food_not_eaten[0] && xposition == 8'b00001010 && yposition == 7'b0001010)
					begin
						food_not_eaten[0] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[1] && xposition == 8'b00010100 && yposition == 7'b0001010)
					begin
						food_not_eaten[1] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[2] && xposition == 8'b00011110 && yposition == 7'b0001010)
					begin
						food_not_eaten[2] = 0;
						score = score + 10'b0000000001;
					end
				else if (pacpill[0] && xposition == 8'b00110010 && yposition == 7'b0001010)
					begin
						pacpill[0] = 0;
					end
				else if (cherry && xposition == 8'b01000110 && yposition == 7'b0001010)
					begin
						cherry = 1'b0;
						score = score + 10'b0000001011;
					end
				else if (pacpill[1] && xposition == 8'b01100100 && yposition == 7'b0001010)
					begin
						pacpill[1] = 0;
					end
				else if (food_not_eaten[6] && xposition == 8'b01111000 && yposition == 7'b0001010)
					begin
						food_not_eaten[6] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[7] && xposition == 8'b10000010 && yposition == 7'b0001010)
					begin
						food_not_eaten[7] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[8] && xposition == 8'b10001100 && yposition == 7'b0001010)
					begin
						food_not_eaten[8] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[9] && xposition == 8'b00001010 && yposition == 7'b0010100)
					begin
						food_not_eaten[9] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[10] && xposition == 8'b00011110 && yposition == 7'b0010100)
					begin
						food_not_eaten[10] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[11] && xposition == 8'b00101000 && yposition == 7'b0010100)
					begin
						food_not_eaten[11] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[12] && xposition == 8'b00110010 && yposition == 7'b0010100)
					begin
						food_not_eaten[12] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[13] && xposition == 8'b01000110 && yposition == 7'b0010100)
					begin
						food_not_eaten[13] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[14] && xposition == 8'b01010000 && yposition == 7'b0010100)
					begin
						food_not_eaten[14] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[15] && xposition == 8'b01100100 && yposition == 7'b0010100)
					begin
						food_not_eaten[15] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[16] && xposition == 8'b01101110 && yposition == 7'b0010100)
					begin
						food_not_eaten[16] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[17] && xposition == 8'b01111000 && yposition == 7'b0010100)
					begin
						food_not_eaten[17] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[18] && xposition == 8'b10001100 && yposition == 7'b0010100)
					begin
						food_not_eaten[18] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[19] && xposition == 8'b00001010 && yposition == 7'b0011110)
					begin
						food_not_eaten[19] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[20] && xposition == 8'b00011110 && yposition == 7'b0011110)
					begin
						food_not_eaten[20] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[21] && xposition == 8'b00110010 && yposition == 7'b0011110)
					begin
						food_not_eaten[21] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[22] && xposition == 8'b01010000 && yposition == 7'b0011110)
					begin
						food_not_eaten[22] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[23] && xposition == 8'b01100100 && yposition == 7'b0011110)
					begin
						food_not_eaten[23] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[24] && xposition == 8'b01111000 && yposition == 7'b0011110)
					begin
						food_not_eaten[24] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[25] && xposition == 8'b10001100 && yposition == 7'b0011110)
					begin
						food_not_eaten[25] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[26] && xposition == 8'b00001010 && yposition == 7'b0101000)
					begin
						food_not_eaten[26] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[27] && xposition == 8'b00010100 && yposition == 7'b0101000)
					begin
						food_not_eaten[27] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[28] && xposition == 8'b00011110 && yposition == 7'b0101000)
					begin
						food_not_eaten[28] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[29] && xposition == 8'b00110010 && yposition == 7'b0101000)
					begin
						food_not_eaten[29] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[30] && xposition == 8'b00111100 && yposition == 7'b0101000)
					begin
						food_not_eaten[30] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[31] && xposition == 8'b01000110 && yposition == 7'b0101000)
					begin
						food_not_eaten[31] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[32] && xposition == 8'b01010000 && yposition == 7'b0101000)
					begin
						food_not_eaten[32] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[33] && xposition == 8'b01011010 && yposition == 7'b0101000)
					begin
						food_not_eaten[33] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[34] && xposition == 8'b01100100 && yposition == 7'b0101000)
					begin
						food_not_eaten[34] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[35] && xposition == 8'b01111000 && yposition == 7'b0101000)
					begin
						food_not_eaten[35] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[36] && xposition == 8'b10000010 && yposition == 7'b0101000)
					begin
						food_not_eaten[36] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[37] && xposition == 8'b10001100 && yposition == 7'b0101000)
					begin
						food_not_eaten[37] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[38] && xposition == 8'b00001010 && yposition == 7'b0110010)
					begin
						food_not_eaten[38] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[39] && xposition == 8'b00011110 && yposition == 7'b0110010)
					begin
						food_not_eaten[39] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[40] && xposition == 8'b00110010 && yposition == 7'b0110010)
					begin
						food_not_eaten[40] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[41] && xposition == 8'b01010000 && yposition == 7'b0110010)
					begin
						food_not_eaten[41] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[42] && xposition == 8'b01100100 && yposition == 7'b0110010)
					begin
						food_not_eaten[42] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[43] && xposition == 8'b01111000 && yposition == 7'b0110010)
					begin
						food_not_eaten[43] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[44] && xposition == 8'b10001100 && yposition == 7'b0110010)
					begin
						food_not_eaten[44] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[45] && xposition == 8'b00001010 && yposition == 7'b0111100)
					begin
						food_not_eaten[45] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[46] && xposition == 8'b00010100 && yposition == 7'b0111100)
					begin
						food_not_eaten[46] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[47] && xposition == 8'b00011110 && yposition == 7'b0111100)
					begin
						food_not_eaten[47] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[48] && xposition == 8'b00101000 && yposition == 7'b0111100)
					begin
						food_not_eaten[48] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[49] && xposition == 8'b00110010 && yposition == 7'b0111100)
					begin
						food_not_eaten[49] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[50] && xposition == 8'b01000110 && yposition == 7'b0111100)
					begin
						food_not_eaten[50] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[51] && xposition == 8'b01010000 && yposition == 7'b0111100)
					begin
						food_not_eaten[51] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[52] && xposition == 8'b01100100 && yposition == 7'b0111100)
					begin
						food_not_eaten[52] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[53] && xposition == 8'b01101110 && yposition == 7'b0111100)
					begin
						food_not_eaten[53] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[54] && xposition == 8'b01111000 && yposition == 7'b0111100)
					begin
						food_not_eaten[54] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[55] && xposition == 8'b10000010 && yposition == 7'b0111100)
					begin
						food_not_eaten[55] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[56] && xposition == 8'b10001100 && yposition == 7'b0111100)
					begin
						food_not_eaten[56] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[57] && xposition == 8'b00010100 && yposition == 7'b1000110)
					begin
						food_not_eaten[57] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[58] && xposition == 8'b00110010 && yposition == 7'b1000110)
					begin
						food_not_eaten[58] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[59] && xposition == 8'b01000110 && yposition == 7'b1000110)
					begin
						food_not_eaten[59] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[60] && xposition == 8'b01100100 && yposition == 7'b1000110)
					begin
						food_not_eaten[60] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[61] && xposition == 8'b10000010 && yposition == 7'b1000110)
					begin
						food_not_eaten[61] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[62] && xposition == 8'b00001010 && yposition == 7'b1010000)
					begin
						food_not_eaten[62] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[63] && xposition == 8'b00010100 && yposition == 7'b1010000)
					begin
						food_not_eaten[63] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[64] && xposition == 8'b00011110 && yposition == 7'b1010000)
					begin
						food_not_eaten[64] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[65] && xposition == 8'b00101000 && yposition == 7'b1010000)
					begin
						food_not_eaten[65] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[66] && xposition == 8'b00110010 && yposition == 7'b1010000)
					begin
						food_not_eaten[66] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[67] && xposition == 8'b00111100 && yposition == 7'b1010000)
					begin
						food_not_eaten[67] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[68] && xposition == 8'b01000110 && yposition == 7'b1010000)
					begin
						food_not_eaten[68] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[69] && xposition == 8'b01010000 && yposition == 7'b1010000)
					begin
						food_not_eaten[69] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[70] && xposition == 8'b01011010 && yposition == 7'b1010000)
					begin
						food_not_eaten[70] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[71] && xposition == 8'b01100100 && yposition == 7'b1010000)
					begin
						food_not_eaten[71] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[72] && xposition == 8'b01101110 && yposition == 7'b1010000)
					begin
						food_not_eaten[72] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[73] && xposition == 8'b01111000 && yposition == 7'b1010000)
					begin
						food_not_eaten[73] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[74] && xposition == 8'b10000010 && yposition == 7'b1010000)
					begin
						food_not_eaten[74] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[75] && xposition == 8'b10001100 && yposition == 7'b1010000)
					begin
						food_not_eaten[75] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[76] && xposition == 8'b00001010 && yposition == 7'b1011010)
					begin
						food_not_eaten[76] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[77] && xposition == 8'b00111100 && yposition == 7'b1011010)
					begin
						food_not_eaten[77] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[78] && xposition == 8'b01011010 && yposition == 7'b1011010)
					begin
						food_not_eaten[78] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[79] && xposition == 8'b10001100 && yposition == 7'b1011010)
					begin
						food_not_eaten[79] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[80] && xposition == 8'b00001010 && yposition == 7'b1100100)
					begin
						food_not_eaten[80] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[81] && xposition == 8'b00010100 && yposition == 7'b1100100)
					begin
						food_not_eaten[81] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[82] && xposition == 8'b00011110 && yposition == 7'b1100100)
					begin
						food_not_eaten[82] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[83] && xposition == 8'b00101000 && yposition == 7'b1100100)
					begin
						food_not_eaten[83] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[84] && xposition == 8'b00110010 && yposition == 7'b1100100)
					begin
						food_not_eaten[84] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[85] && xposition == 8'b00111100 && yposition == 7'b1100100)
					begin
						food_not_eaten[85] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[86] && xposition == 8'b01000110 && yposition == 7'b1100100)
					begin
						food_not_eaten[86] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[87] && xposition == 8'b01010000 && yposition == 7'b1100100)
					begin
						food_not_eaten[87] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[88] && xposition == 8'b01011010 && yposition == 7'b1100100)
					begin
						food_not_eaten[88] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[89] && xposition == 8'b01100100 && yposition == 7'b1100100)
					begin
						food_not_eaten[89] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[90] && xposition == 8'b01101110 && yposition == 7'b1100100)
					begin
						food_not_eaten[90] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[91] && xposition == 8'b01111000 && yposition == 7'b1100100)
					begin
						food_not_eaten[91] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[92] && xposition == 8'b10000010 && yposition == 7'b1100100)
					begin
						food_not_eaten[92] = 0;
						score = score + 10'b0000000001;
					end
				else if (food_not_eaten[93] && xposition == 8'b10001100 && yposition == 7'b1100100)
					begin
						food_not_eaten[93] = 0;
						score = score + 10'b0000000001;
					end	
				else
						food_not_eaten = food_not_eaten;
				end
		end
endmodule
	
module statecollisionG (xposition,yposition,clock,enable,reset,stateout);
output reg [3:0]stateout;
reg [3:0] statein;
input [7:0]xposition;
input [6:0]yposition;
input clock;
input enable;
input reset;
parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down

always@(*)
	begin: state_table
	//L: nothing
	//R: nothing
	//U: nothing
	case(statein)
	D: if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else stateout=D;
	LU:if (xposition==80&&yposition==50)
		stateout=UD;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else if (xposition==130&&yposition==100)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else stateout=LU;
	LR:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else stateout=LR;
	LD:if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==30&&yposition==20)
		stateout=UD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==80&&yposition==30)
		stateout=LRUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else if (xposition==140&&yposition==20)
		stateout=UD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else stateout=LD;
	RU:if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==20&&yposition==100)
		stateout=LR;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==70&&yposition==10)
		stateout=D;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else stateout=RU;
	RD:if (xposition==10&&yposition==20)
		stateout=UD;
		else if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else stateout=RD;
	UD:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==80)
		stateout=RD;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else stateout=UD;
	LRU:if (xposition==10&yposition==80)
		stateout=RD;
		else if (xposition==30&&yposition==80)
		stateout=LR;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==40&&yposition==80)
		stateout=LR;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==100)
		stateout=LR;
		else if (xposition==70&&yposition==100)
		stateout=LR;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==100)
		stateout=LR;
		else if (xposition==100&&yposition==100)
		stateout=LR;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==110&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==120&&yposition==80)
		stateout=LR;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRU;
	LUD:if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==10)
		stateout=D;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==90&&yposition==40)
		stateout=LR;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else if (xposition==140&&yposition==30)
		stateout=UD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else stateout=LUD;
	LRD:if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRD;
	RUD: if (xposition==10&&yposition==30)
		stateout=UD;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==60&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==10)
		stateout=D;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else stateout=RUD;
	LRUD:if (xposition==70&&yposition==40)
		 stateout=LR;
		 else if (xposition==90&&yposition==40)
		 stateout=LR;
		 else if (xposition==80&&yposition==30)
		 stateout=UD;
		 else if (xposition==80&&yposition==50)
		 stateout=UD;
		 else stateout=LRUD;
	default:stateout=4'bXXXX;
	endcase
end


// Start with a known state
// Get info from xposition and yposition
// Based on that info, update the state
// Send out that state information in time for the next clock posedge

always@(posedge clock or negedge reset)
	begin: state_FFs
		if (reset==1'b0) statein <= RUD;
		else statein <= stateout;
	end // state_FFS



endmodule
		
		
module statecollisionG2 (xposition,yposition,clock,enable,reset,stateout);
output reg [3:0]stateout;
reg [3:0] statein;
input [7:0]xposition;
input [6:0]yposition;
input clock;
input enable;
input reset;
parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down

always@(*)
	begin: state_table
	//L: nothing
	//R: nothing
	//U: nothing
	case(statein)
	D: if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else stateout=D;
	LU:if (xposition==80&&yposition==50)
		stateout=UD;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else if (xposition==130&&yposition==100)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else stateout=LU;
	LR:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else stateout=LR;
	LD:if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==30&&yposition==20)
		stateout=UD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==80&&yposition==30)
		stateout=LRUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else if (xposition==140&&yposition==20)
		stateout=UD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else stateout=LD;
	RU:if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==20&&yposition==100)
		stateout=LR;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==70&&yposition==10)
		stateout=D;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else stateout=RU;
	RD:if (xposition==10&&yposition==20)
		stateout=UD;
		else if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else stateout=RD;
	UD:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==80)
		stateout=RD;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else stateout=UD;
	LRU:if (xposition==10&yposition==80)
		stateout=RD;
		else if (xposition==30&&yposition==80)
		stateout=LR;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==40&&yposition==80)
		stateout=LR;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==100)
		stateout=LR;
		else if (xposition==70&&yposition==100)
		stateout=LR;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==100)
		stateout=LR;
		else if (xposition==100&&yposition==100)
		stateout=LR;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==110&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==120&&yposition==80)
		stateout=LR;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRU;
	LUD:if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==10)
		stateout=D;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==90&&yposition==40)
		stateout=LR;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else if (xposition==140&&yposition==30)
		stateout=UD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else stateout=LUD;
	LRD:if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRD;
	RUD: if (xposition==10&&yposition==30)
		stateout=UD;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==60&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==10)
		stateout=D;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else stateout=RUD;
	LRUD:if (xposition==70&&yposition==40)
		 stateout=LR;
		 else if (xposition==90&&yposition==40)
		 stateout=LR;
		 else if (xposition==80&&yposition==30)
		 stateout=UD;
		 else if (xposition==80&&yposition==50)
		 stateout=UD;
		 else stateout=LRUD;
	default:stateout=4'bXXXX;
	endcase
end


// Start with a known state
// Get info from xposition and yposition
// Based on that info, update the state
// Send out that state information in time for the next clock posedge

always@(posedge clock or negedge reset)
	begin: state_FFs
		if (reset==1'b0) statein <= LUD;
		else statein <= stateout;
	end // state_FFS
endmodule		
		
module statecollision (xposition,yposition,clock,enable,reset,stateout);
	output reg [3:0]stateout;
	reg [3:0] statein;
	input [7:0]xposition;
	input [6:0]yposition;
	input clock;
	input enable;
	input reset;
	parameter L=4'b0000, // Left
	 R=4'b0001,			// Right
	 U=4'b0010, 		// Up
	 D=4'b0011,			// Down
	 LU=4'b0100,		// Left or Up
	 LR=4'b0101,		// Left or Right
	 LD=4'b0110,		// Left or Down
	 RU=4'b0111,		// Right or Up
	 RD=4'b1000,		// Right or Down
	 UD=4'b1001,		// Up or Down
	 LRU=4'b1010,		// Left or Right Or Up
	 LUD=4'b1011,		// Left or Up or Down
	 LRD=4'b1100,		// Left or Right or Down
	 RUD=4'b1101,		// Right or Up or Down
	 LRUD=4'b1110;		// Left or Right or Up or Down

	always@(*)
	begin: state_table
	//L: nothing
	//R: nothing
	//U: nothing
	case(statein)
	D: if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else stateout=D;
	LU:if (xposition==80&&yposition==50)
		stateout=UD;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else if (xposition==130&&yposition==100)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else stateout=LU;
	LR:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else stateout=LR;
	LD:if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==30&&yposition==20)
		stateout=UD;
		else if (xposition==70&&yposition==20)
		stateout=RU;
		else if (xposition==80&&yposition==30)
		stateout=LRUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else if (xposition==140&&yposition==20)
		stateout=UD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==140&&yposition==90)
		stateout=UD;
		else stateout=LD;
	RU:if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==20&&yposition==100)
		stateout=LR;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==70&&yposition==10)
		stateout=D;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else stateout=RU;
	RD:if (xposition==10&&yposition==20)
		stateout=UD;
		else if (xposition==20&&yposition==10)
		stateout=LR;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==90)
		stateout=UD;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==130&&yposition==10)
		stateout=LR;
		else stateout=RD;
	UD:if (xposition==10&&yposition==10)
		stateout=RD;
		else if (xposition==10&&yposition==40)
		stateout=RUD;
		else if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==20)
		stateout=RUD;
		else if (xposition==30&&yposition==40)
		stateout=LUD;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==50&&yposition==20)
		stateout=LUD;
		else if (xposition==50&&yposition==40)
		stateout=RUD;
		else if (xposition==50&&yposition==60)
		stateout=LUD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==20&&yposition==80)
		stateout=LRU;
		else if (xposition==10&&yposition==80)
		stateout=RD;
		else if (xposition==10&&yposition==100)
		stateout=RU;
		else if (xposition==80&&yposition==20)
		stateout=LD;
		else if (xposition==80&&yposition==40)
		stateout=LRUD;
		else if (xposition==80&&yposition==60)
		stateout=LU;
		else if (xposition==70&&yposition==60)
		stateout=RD;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==100&&yposition==20)
		stateout=RUD;
		else if (xposition==100&&yposition==40)
		stateout=LUD;
		else if (xposition==100&&yposition==60)
		stateout=RUD;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==120&&yposition==20)
		stateout=LUD;
		else if (xposition==120&&yposition==40)
		stateout=RUD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==10)
		stateout=LD;
		else if (xposition==140&&yposition==40)
		stateout=LUD;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==130&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==60&&yposition==100)
		stateout=LRU;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==90&&yposition==100)
		stateout=LRU;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==140&&yposition==100)
		stateout=LU;
		else stateout=UD;
	LRU:if (xposition==10&yposition==80)
		stateout=RD;
		else if (xposition==30&&yposition==80)
		stateout=LR;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==20&&yposition==60)
		stateout=LRD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==40&&yposition==80)
		stateout=LR;
		else if (xposition==60&&yposition==80)
		stateout=LRD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==70&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==100)
		stateout=LR;
		else if (xposition==70&&yposition==100)
		stateout=LR;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==100)
		stateout=LR;
		else if (xposition==100&&yposition==100)
		stateout=LR;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==90&&yposition==80)
		stateout=LRD;
		else if (xposition==110&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==130&&yposition==60)
		stateout=LRD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==120&&yposition==80)
		stateout=LR;
		else if (xposition==140&&yposition==80)
		stateout=LD;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRU;
	LUD:if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==30&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==10)
		stateout=D;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==50&&yposition==70)
		stateout=UD;
		else if (xposition==40&&yposition==60)
		stateout=LR;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==90&&yposition==40)
		stateout=LR;
		else if (xposition==120&&yposition==10)
		stateout=RD;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else if (xposition==140&&yposition==30)
		stateout=UD;
		else if (xposition==140&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else stateout=LUD;
	LRD:if (xposition==10&&yposition==60)
		stateout=RU;
		else if (xposition==30&&yposition==60)
		stateout=LRU;
		else if (xposition==20&&yposition==70)
		stateout=UD;
		else if (xposition==50&&yposition==80)
		stateout=LRU;
		else if (xposition==70&&yposition==80)
		stateout=LRU;
		else if (xposition==60&&yposition==90)
		stateout=UD;
		else if (xposition==80&&yposition==80)
		stateout=LR;
		else if (xposition==100&&yposition==80)
		stateout=LRU;
		else if (xposition==90&&yposition==90)
		stateout=UD;
		else if (xposition==120&&yposition==60)
		stateout=LRU;
		else if (xposition==140&&yposition==60)
		stateout=LU;
		else if (xposition==130&&yposition==70)
		stateout=UD;
		else stateout=LRD;
	RUD: if (xposition==10&&yposition==30)
		stateout=UD;
		else if (xposition==10&&yposition==50)
		stateout=UD;
		else if (xposition==20&&yposition==40)
		stateout=LR;
		else if (xposition==30&&yposition==10)
		stateout=LD;
		else if (xposition==30&&yposition==30)
		stateout=UD;
		else if (xposition==40&&yposition==20)
		stateout=LR;
		else if (xposition==50&&yposition==30)
		stateout=UD;
		else if (xposition==50&&yposition==50)
		stateout=UD;
		else if (xposition==60&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==50)
		stateout=UD;
		else if (xposition==100&&yposition==70)
		stateout=UD;
		else if (xposition==110&&yposition==60)
		stateout=LR;
		else if (xposition==120&&yposition==30)
		stateout=UD;
		else if (xposition==120&&yposition==50)
		stateout=UD;
		else if (xposition==130&&yposition==40)
		stateout=LR;
		else if (xposition==100&&yposition==10)
		stateout=D;
		else if (xposition==100&&yposition==30)
		stateout=UD;
		else if (xposition==110&&yposition==20)
		stateout=LR;
		else stateout=RUD;
	LRUD:if (xposition==70&&yposition==40)
		 stateout=LR;
		 else if (xposition==90&&yposition==40)
		 stateout=LR;
		 else if (xposition==80&&yposition==30)
		 stateout=UD;
		 else if (xposition==80&&yposition==50)
		 stateout=UD;
		 else stateout=LRUD;
	default:stateout=4'bXXXX;
	endcase
	end


	// Start with a known state
	// Get info from xposition and yposition
	// Based on that info, update the state
	// Send out that state information in time for the next clock posedge

	always@(posedge clock or negedge reset)
	begin: state_FFs
		if (reset==1'b0) statein <= RU;
		else statein <= stateout;
	end // state_FFS
endmodule

module enablercount(CLOCK_50,reset,enable,divider,enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5);
	input CLOCK_50,reset;
	input [2:0]divider;
	output reg enable;
	output reg enabledelay1;
	output reg enabledelay2;
	output reg enabledelay3;
	output reg enabledelay4;
	output reg enabledelay5;
	reg [32:0]count;

	always@(posedge CLOCK_50 or negedge reset)
		begin
			if (!reset)
				count=0;
			else
				begin
					if (divider==3'b000&&count==2499999||divider==3'b001&&count==2299999||divider==3'b010&&count==1999999||divider==3'b011&&count==1899999
					||divider==3'b100&&count==1699999||divider==3'b101&&count==1499999||divider==3'b110&&count==1299999||divider==3'b111&&count==99999)
						count=0;
					else
						count=count+1;
				end
		end
	
	always@(posedge CLOCK_50 or negedge reset)
		begin
			if (!reset)
				begin
					enable<=0;
					enabledelay1<=0;
					enabledelay2<=0;
					enabledelay3<=0;
					enabledelay4<=0;
					enabledelay5<=0;
				end
			else
				begin
					if (count==0)
						enable<=1;
					else
						enable<=0;
					enabledelay1<=enable;
					enabledelay2<=enabledelay1;
					enabledelay3<=enabledelay2;
					enabledelay4<=enabledelay3;
					enabledelay5<=enabledelay4;
				end
		end	
endmodule

module animation (
	clock,
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK,						//	VGA BLANK
	VGA_SYNC,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B,   						//	VGA Blue[9:0]
	new_x, 
	new_y,
	new_xg,
	new_yg,
	new_xg2,
	new_yg2,
	enable,
	direction,
	food_not_eaten,
	eatghost,
	cherry,
	pacpill
);

	input			clock;				//	50 MHz
	output			VGA_CLK;   			//	VGA Clock
	output			VGA_HS;				//	VGA H_SYNC
	output			VGA_VS;				//	VGA V_SYNC
	output			VGA_BLANK;			//	VGA BLANK
	output			VGA_SYNC;			//	VGA SYNC
	output	[9:0]	VGA_R;   			//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 			//	VGA Green[9:0]
	output	[9:0]	VGA_B;   			//	VGA Blue[9:0]
	input [7:0] new_x,new_xg,new_xg2;
	input [6:0] new_y,new_yg,new_yg2;
	input enable;
	input [2:0] direction;
	input [93:0] food_not_eaten;
	input eatghost;
	input cherry;
	input [1:0] pacpill;
	// PARAMETERS
	parameter [3:0] idle = 4'b0000, draw_food = 4'b0001, erase_pac = 4'b0010, draw_pac = 4'b0011, erase_ghost = 4'b0100, 
					draw_ghost = 4'b0101, erase_ghost2 = 4'b0110, draw_ghost2 = 4'b0111, draw_cherry = 4'b1000;
	parameter [6:0] cntr_y_max = 7'b0001001, clear_y_max = 7'b1110111, cntr_y_start = 7'b0000000;
	parameter [7:0] cntr_x_max = 8'b00001001, clear_x_max = 8'b10011111, cntr_x_start = 8'b00000000;

	//WIRES
	wire enable;
	wire writeEn;
	wire [7:0] new_x;
	wire [6:0] new_y;
	wire [5:0] rom_out,rom2_out,rom3_out,rom4_out,rom5_out,rom6_out,rom7_out,rom8_out,rom9_out,rom10_out;
	
	//REGS
	reg [3:0] stater;
	reg [6:0] food_cntr;
	reg [7:0] old_x, old_xg, old_xg2, old_xc, cntr_x, vga_x;
	reg [6:0] old_y, old_yg, old_yg2, old_yc, cntr_y, vga_y;
	reg [5:0] color;
	reg [6:0] address,address2,address3,address4,address5,address6,address7,address8,address9,address10;
	reg pac1;
	
	//ASSIGN
	assign writeEn = (stater == erase_pac | stater == draw_pac | stater == erase_ghost | stater == draw_ghost | stater == erase_ghost2 | stater == draw_ghost2 | stater == draw_food | stater == draw_cherry);
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1),
			.clock(clock),
			.colour(color),
			.x(vga_x),
			.y(vga_y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "pacman_background.mif";

	pacman_rom PACROM(address,clock,rom_out);
	closedpac PAC2ROM(address2,clock,rom2_out);
	pacmanleft PAC3ROM(address3,clock,rom3_out);
	pacmanupp PAC4ROM(address4,clock,rom4_out);
	pacmandownn PAC5ROM (address5,clock,rom5_out);
	
	ghostrom GHOST (address6,clock,rom6_out);
	ghostrom GHOST2 (address7,clock,rom7_out);	
	ghostromblue GHOSTB (address8,clock,rom8_out);
	ghostromblue GHOSTB2 (address9,clock,rom9_out);
	
	cherryrom CHERRIE (address10,clock,rom10_out);
	
	always@(posedge clock)
		begin
			if (enable==1'b1 && pac1==1'b0)
				pac1<=1'b1;
			else if (enable==1'b1 && pac1==1'b1)
				pac1<=1'b0;
			else pac1<=pac1;
		end
		
	initial
		begin
			stater = idle;
			old_x = 8'b00001010;
			old_y = 7'b1100100;
			old_xg = 8'b00110010;
			old_yg = 7'b0101000;
			old_xg = 100;
			old_yg = 40;
			old_xc = 8'b01000110;
			old_yc = 7'b0001010;
			address = 7'b0000000;
			address2 = 7'b0000000;
			address3 = 7'b0000000;
			address4 = 7'b0000000;
			address5 = 7'b0000000;
			address6 = 7'b0000000;
			address7 = 7'b0000000;
			address8 = 7'b0000000;
			address9 = 7'b0000000;
			address10 = 7'b0000000;
			pac1 = 1'b0;
		end
		
	always@(posedge enable, posedge clock)
		if (enable)
			begin
				stater = draw_cherry;
				address10 = 7'b0000010;
				color = rom10_out;
				cntr_x = cntr_x_start;
				cntr_y = cntr_y_start;
			end
		else
			case(stater)
				draw_cherry:
					if (!cherry)
						begin
							stater = draw_food;
							color = 6'b111110;
							cntr_x = cntr_x_start;
							cntr_y = cntr_y_start;
							food_cntr = 7'b0000000;
						end
					else
						begin
							vga_x = old_xc + cntr_x;
							vga_y = old_yc + cntr_y;
							color = rom10_out;
							address10 = address10 + 7'b0000001;
								if (cntr_x == cntr_x_max)
									if (cntr_y == cntr_y_max)
										begin
											stater = draw_food;
											color = 6'b111110;
											cntr_x = cntr_x_start;
											cntr_y = cntr_y_start;
											food_cntr = 7'b0000000;
										end
									else
										begin
											cntr_y = cntr_y + 7'b0000001;
											cntr_x = cntr_x_start;
										end
								else
									cntr_x = cntr_x + 8'b00000001;
						end
				draw_food:
					begin
						if (7'b0000000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000011 == food_cntr)
							if (!pacpill[0])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b001100;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000101 == food_cntr)
							if (!pacpill[1])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b001100;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0000111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0001010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00101000;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0001111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01101110;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0010100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0010111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0011110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00111100;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0011111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01011010;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0101000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0100111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0110010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0101111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00101000;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01101110;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0110111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b0111100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b1000110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b1000110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b1000110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b1000110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b1000110;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b0111111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00101000;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00111100;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01011010;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1000111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01101110;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b1010000;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b1011010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00111100;
									vga_y = cntr_y + 7'b0000100 + 7'b1011010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01011010;
									vga_y = cntr_y + 7'b0000100 + 7'b1011010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1001111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b1011010;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00001010;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00010100;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00011110;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00101000;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00110010;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b00111100;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010110 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01000110;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1010111 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01010000;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011000 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01011010;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011001 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01100100;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011010 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01101110;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011011 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b01111000;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011100 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10000010;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else if (7'b1011101 == food_cntr)
							if (!food_not_eaten[food_cntr])
								begin
									food_cntr = food_cntr + 7'b0000001;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
								end
							else
								begin
									vga_x = cntr_x + 8'b00000100 + 8'b10001100;
									vga_y = cntr_y + 7'b0000100 + 7'b1100100;
									color = 6'b111110;
									if (cntr_x == 8'b00000001)
										if (cntr_y == 7'b0000001)
											begin
												food_cntr = food_cntr + 7'b0000001;
												cntr_x = cntr_x_start;
												cntr_y = cntr_y_start;
											end
										else
											begin
												cntr_y = cntr_y + 7'b0000001;
												cntr_x = cntr_x_start;
											end
									else
										cntr_x = cntr_x + 8'b00000001;
								end
						else
							begin
								stater = erase_pac;
								cntr_x = cntr_x_start;
								cntr_y = cntr_y_start;
								color = 6'b000000;
							end
					end
				erase_pac:
					begin
						vga_x = old_x + cntr_x;
						vga_y = old_y + cntr_y;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									address = 7'b0000010;
									address2 = 7'b0000010;
									address3 = 7'b0000010;
									address4 = 7'b0000010;
									address5 = 7'b0000010;
									color = rom_out;
									stater = draw_pac;
									old_x = new_x;
									old_y = new_y;
								end
							else
								begin
									cntr_y = cntr_y + 7'b0000001;
									cntr_x = cntr_x_start;
								end
						else
							cntr_x = cntr_x + 8'b00000001;
					end
				draw_pac:
					if (pac1==1'b0&&direction==3'b001)
						begin
							vga_x = old_x + cntr_x;
							vga_y = old_y + cntr_y;
							color = rom_out;
							address = address + 7'b0000001;
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
						end
					else if (pac1==1'b1||(pac1==1'b0&&direction==3'b100))
						begin
							vga_x = old_x + cntr_x;
							vga_y = old_y + cntr_y;
							color = rom2_out;
							address2 = address2 + 7'b0000001;
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
						end
					else if (pac1==1'b0&&direction==3'b000)
						begin
							vga_x = old_x + cntr_x;
							vga_y = old_y + cntr_y;
							color = rom3_out;
							address3 = address3 + 7'b0000001;
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
						end
					else if (pac1==1'b0&&direction==3'b010)
						begin
							vga_x = old_x + cntr_x;
							vga_y = old_y + cntr_y;
							color = rom4_out;
							address4 = address4 + 7'b0000001;
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
						end
					else if (pac1==1'b0&&direction==3'b011)
						begin
							vga_x = old_x + cntr_x;
							vga_y = old_y + cntr_y;
							color = rom5_out;
							address5 = address5 + 7'b0000001;
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
						end
				erase_ghost:
					begin
						vga_x = old_xg + cntr_x;
						vga_y = old_yg + cntr_y;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									address6 = 7'b0000010;
									address8 = 7'b0000010;
									if (~eatghost)
										begin
											color = rom6_out;
										end
									else
										begin
											color = rom8_out;
										end
									old_xg = new_xg;
									old_yg = new_yg;
									stater = draw_ghost;
								end
							else
								begin
									cntr_y = cntr_y + 7'b0000001;
									cntr_x = cntr_x_start;
								end
						else
							cntr_x = cntr_x + 8'b00000001;
					end
				erase_ghost2:
					begin
						vga_x = old_xg2 + cntr_x;
						vga_y = old_yg2 + cntr_y;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									address7 = 7'b0000010;
									address9 = 7'b0000010;
									if (~eatghost)
										begin
											color = rom7_out;
										end
									else
										begin
											color = rom9_out;
										end
									old_xg2 = new_xg2;
									old_yg2 = new_yg2;
									stater = draw_ghost2;
								end
							else
								begin
									cntr_y = cntr_y + 7'b0000001;
									cntr_x = cntr_x_start;
								end
						else
							cntr_x = cntr_x + 8'b00000001;
					end
				draw_ghost:
					begin
							vga_x = old_xg + cntr_x;
							vga_y = old_yg + cntr_y;
							if (~eatghost)
							begin
							color = rom6_out;
							address6 = address6 + 7'b0000001;
							end
							else
							begin
							color = rom8_out;
							address8 = address8 + 7'b0000001;
							end
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									begin
										stater = erase_ghost2;
										color = 6'b000000;
										cntr_x = cntr_x_start;
										cntr_y = cntr_y_start;
									end
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
					end
				draw_ghost2:
					begin
							vga_x = old_xg2 + cntr_x;
							vga_y = old_yg2 + cntr_y;
							if (~eatghost)
							begin
							color = rom7_out;
							address7 = address7 + 7'b0000001;
							end
							else
							begin
							color = rom9_out;
							address9 = address9 + 7'b0000001;
							end
							if (cntr_x == cntr_x_max)
								if (cntr_y == cntr_y_max)
									stater = idle;
								else
									begin
										cntr_y = cntr_y + 7'b0000001;
										cntr_x = cntr_x_start;
									end
							else
								cntr_x = cntr_x + 8'b00000001;
					end
			endcase
endmodule

module moduloy(ypositionW,is0,enable,CLOCK_50);
	input [6:0]ypositionW;
	input enable;
	input CLOCK_50;
	output reg is0;

	always@(CLOCK_50)
		if (enable==1'b1)
			if (ypositionW%10==0)
				is0=1;
			else
				is0=0;
endmodule


module modulox(xpositionW,is0,enable,CLOCK_50);
	input [7:0]xpositionW;
	input CLOCK_50;
	input enable;
	output reg is0;

	always@(CLOCK_50)
		if (enable==1'b1)
			if (xpositionW%10==0)
				is0=1;
			else
				is0=0;
endmodule


module keyboard (CLOCK_50,received_data,reset,keyleft,keyright,keyup,keydown);
	input CLOCK_50,reset;
	input [6:0]received_data;
	output reg keyleft,keyright,keyup,keydown;

	always@(posedge CLOCK_50)
		case (received_data)
			7'b0010010:
				begin
					keyleft<=0;
					keyright<=0;
					keyup<=1;
					keydown<=0;
				end
			7'b0000011:
				begin
					keyleft<=1;
					keyright<=0;
					keyup<=0;
					keydown<=0;
				end
			7'b0011001:
				begin
					keyleft<=0;
					keyright<=1;
					keyup<=0;
					keydown<=0;
				end
			7'b0100100:
				begin
					keyleft<=0;
					keyright<=0;
					keyup<=0;
					keydown<=1;
				end
			default:
				begin
					keyleft<=0;
					keyright<=0;
					keyup<=0;
					keydown<=0;
				end
		endcase
endmodule

module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign HEX2 = 7'h7F;
assign HEX3 = 7'h7F;
assign HEX4 = 7'h7F;
assign HEX5 = 7'h7F;
assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);


endmodule
