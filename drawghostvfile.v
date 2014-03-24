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
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	LEDR
);

input [17:10] SW;
input CLOCK_50;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output   [7:0] LEDG;
	output [17:0] LEDR;
//output [7:0]xposition;
//output [6:0]yposition;
//output [3:0]statein;

//assign xposition=xpositionW;
//assign yposition=ypositionW;
//assign statein=stateW;
wire is_0;
wire is_0g;
wire [3:0]stateW;
wire [3:0]stateG;
wire [7:0]xpositionW,xpositionG;
wire [6:0]ypositionW,ypositionG;
wire [0:0]enable,enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5;

assign LEDG[3:0]= stateW;
assign LEDG[4] = is_0;

wire [2:0]direction_reg;
wire [2:0]direction_regG;
wire keyleft,keyright,keyup,keydown;

assign LEDG[7:5]=direction_reg;

wire gameover;
wire resetwire=SW[13]||gameover;


assign LEDG[8]=gameover;

wire gameover;

always@(CLOCK_50)
begin
if (xpositionW==xpositionG && ypositionW==ypositionG)
gameover=1'b1;
else
gameover=1'b0;
end


gameovercheck game0 (CLOCK_50,xpositionW,xpositionG,ypositionW,ypositionG,gameover);

xycounter U0 (SW[17],SW[16],SW[15],SW[14],CLOCK_50,enable,resetwire,xpositionW,ypositionW,stateW,is_0,direction_reg,enabledelay1,enabledelay2,enabledelay3,enabledelay4);
xycounterG GHOST (SW[17],SW[16],SW[15],SW[14],CLOCK_50,enable,resetwire,xpositionG,ypositionG,stateG,is_0g,direction_regG,enabledelay1,enabledelay2,enabledelay3,enabledelay4);

statecollision U1 (xpositionW,ypositionW,CLOCK_50,enable,resetwire,stateW);
statecollisionG GHOST1 (xpositionG,ypositionG,CLOCK_50,enable,resetwire,stateG);

enablercount U2 (CLOCK_50,resetwire,enable,SW[12:10],enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5);

keyboard U3 (CLOCK_50,HEX0,HEX1,resetwire,keyleft,keyright,keyup,keydown);

assign LEDR[0]=keyleft;
assign LEDR[1]=keyright;
assign LEDR[2]=keyup;
assign LEDR[3]=keydown;

output [6:0]HEX0;
output [6:0]HEX1;
output [6:0]HEX2;
output [6:0]HEX3;
output [6:0]HEX4;
output [6:0]HEX5;
output [6:0]HEX6;
output [6:0]HEX7;

 PS2_Demo U5 (
	// Inputs
	CLOCK_50,
	resetwire,

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
		enabledelay5
);

endmodule



module gameovercheck (CLOCK_50,xpositionW,xpositionG,ypositionW,ypositionG,gameover);

input CLOCK_50;
input [7:0]xpositionW,xpositionG;
input [6:0]ypositionW,ypositionG;
output reg gameover;
/*
always@(posedge CLOCK_50)
begin
if ((xpositionW-xpositionG>0)&&(xpositionG-xpositionW<10))
	begin
	if ((ypositionW-ypositionG>0)&&(ypositionG-ypositionW<10))
		begin
			gameover=1'b1;
		end
	else if ((ypositionW-ypositionG<0)&&(ypositionG-ypositionW>10))
		begin
			gameover=1'b1;
		end
	end
else if ((xpositionW-xpositionG<0)&&(xpositionG-xpositionW>10))
	begin
	if ((ypositionW-ypositionG>0)&&(ypositionG-ypositionW<10))
		begin
			gameover=1'b1;
		end
	else if ((ypositionW-ypositionG<0)&&(ypositionG-ypositionW>10))
		begin
			gameover=1'b1;
		end
	end
else gameover=1'b0;
end
*/
always@(posedge CLOCK_50)
if (xpositionW==xpositionG&&ypositionW==ypositionG)
gameover=1'b1;
else
gameover=1'b0;

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

modulox U5 (xposition,isx0,enabledelay4,clock);
moduloy U6 (yposition,isy0,enabledelay4,clock);
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
		
		else if (direction==3'b001&&left&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b000&&right&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&down&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		else if (direction==3'b011&&up&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		
		else if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		
		else if (direction==3'b100&&left&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&down&&(statein==LR))
		direction<=direction;
		else if (direction==3'b100&&right&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&up&&(statein==LR))
		direction<=direction;
		
		// add more conditions
		
		else direction <= 3'b100;
		
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
		
		else if (direction==3'b001&&left&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b000&&right&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&down&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		else if (direction==3'b011&&up&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		
		else if (direction==3'b000&&(statein==L||statein==LU||statein==LR||statein==LD||statein==LRU||statein==LUD||statein==LRD||statein==LRUD))
		direction<=3'b000;
		else if (direction==3'b001&&(statein==R||statein==RU||statein==LR||statein==RD||statein==LRU||statein==RUD||statein==LRD||statein==LRUD))
		direction<=3'b001;
		else if (direction==3'b010&&(statein==U||statein==LU||statein==RU||statein==UD||statein==LRU||statein==LUD||statein==RUD||statein==LRUD))
		direction<=3'b010;
		else if (direction==3'b011&&(statein==D||statein==LD||statein==RD||statein==UD||statein==LUD||statein==LRD||statein==RUD||statein==LRUD))
		direction<=3'b011;
		
		
		else if (direction==3'b100&&left&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&down&&(statein==LR))
		direction<=direction;
		else if (direction==3'b100&&right&&(statein==UD))
		direction<=direction;
		else if (direction==3'b000&&up&&(statein==LR))
		direction<=direction;
		
		// add more conditions
		
		else direction <= 3'b100;
		
		end
end

always@(posedge clock or negedge reset) // Update x/y positions
begin
	if (reset==1'b0)
		begin
		xposition<=140;
		yposition<=10;
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
		if (reset==1'b0) statein <= LD;
		else statein <= stateout;
	end // state_FFS



endmodule





module enablercount(CLOCK_50,reset,enable,divider,enabledelay1,enabledelay2,enabledelay3,enabledelay4,enabledelay5);

input CLOCK_50,
		reset;
		
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
	if (divider==3'b000&&count==2499999||divider==3'b001&&count==2299999||divider==3'b010&&count==1999999||divider==3'b011&&count==1699999
	||divider==3'b100&&count==1499999||divider==3'b101&&count==1299999||divider==3'b110&&count==99999||divider==3'b111&&count==4999999)
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




module animation
	(
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
		new_x_g,
		new_y_g,
		enable
	);

	input				clock;				//	50 MHz
	//	Button[3:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	input [7:0] new_x;
	input [6:0] new_y;
	input [7:0] new_x_g;
	input [6:0] new_y_g;
	input enable;
							
	// PARAMETERS
	parameter [2:0] idle = 3'b000, erase_pac = 3'b001, draw_pac = 3'b010, erase_ghost = 3'b011, draw_ghost = 3'b100, clear = 3'b101;
	parameter [6:0] cntr_y_max = 7'b0001001, clear_y_max = 7'b1110111, cntr_y_start = 7'b0000000;
	parameter [7:0] cntr_x_max = 8'b00001001, clear_x_max = 8'b10011111, cntr_x_start = 8'b00000000;

	//WIRES
	wire enable;
	wire writeEn;
	wire [5:0] rom_out,rom_out_ghost;
	
	//REGS
	reg [1:0] stater;
	reg [7:0] old_x, old_x_g, cntr_x, vga_x;
	reg [6:0] old_y, old_y_g, cntr_y, vga_y;
	reg [5:0] color;
	reg [6:0] address,address_ghost;
	//reg [2:0] direction;
	
	//ASSIGN
	assign writeEn = (stater == erase_ghost | stater == erase_pac | stater == draw_ghost | stater == draw_pac | stater == clear);
	
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
	ghost GHOSTROM(address_ghost,clock,rom_out_ghost);
		
	initial
		begin
			old_x = 8'b00001010;
			old_y = 7'b1100100;
			old_x_g = 8'b10001100;
			old_y_g = 7'b0001010;
			address = 7'b0000000;
		end
		
	always@(posedge enable, posedge clock)
		if (enable)
			begin
				stater = erase_pac;
				color = 6'b000000;
				cntr_x = cntr_x_start;
				cntr_y = cntr_y_start;
			end
		else
			case(stater)
				erase_pac:
					begin
						vga_x = old_x + cntr_x;
						vga_y = old_y + cntr_y;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									address = 7'b0000000;
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
					begin
						vga_x = old_x + cntr_x;
						vga_y = old_y + cntr_y;
						color = rom_out;
						address = address + 7'b0000001;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									color = 6'b000000;
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									stater = erase_ghost;
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
						vga_x = old_x_g + cntr_x;
						vga_y = old_y_g + cntr_y;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									cntr_x = cntr_x_start;
									cntr_y = cntr_y_start;
									address_ghost = 7'b0000000;
									color = rom_out_ghost;
									old_x_g = new_x_g;
									old_y_g = new_y_g;
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
				draw_ghost:
					begin
						vga_x = old_x_g + cntr_x;
						vga_y = old_y_g + cntr_y;
						color = rom_out_ghost;
						address_ghost = address_ghost + 7'b0000001;
						if (cntr_x == cntr_x_max)
							if (cntr_y == cntr_y_max)
								begin
									stater = idle;
								end
							else
								begin
									cntr_y = cntr_y + 7'b0000001;
									cntr_x = cntr_x_start;
								end
						else
							cntr_x = cntr_x + 8'b00000001;
					end
				clear:
					begin
						vga_x = cntr_x;
						vga_y = cntr_y;
						if (cntr_x == clear_x_max)
							if (cntr_y == clear_y_max)
								begin
									stater = idle;
								end
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
input [7:0]ypositionW;
input enable;
input CLOCK_50;
output reg is0;

always@(CLOCK_50)
if (enable==1'b1)
begin
if (ypositionW%10==0)
	is0=1;
else
	is0=0;
	end
endmodule


module modulox(xpositionW,is0,enable,CLOCK_50);
input [7:0]xpositionW;
input CLOCK_50;
input enable;
output reg is0;

always@(CLOCK_50)
if (enable==1'b1)
begin
if (xpositionW%10==0)
	is0=1;
else
	is0=0;
	end
endmodule


module keyboard (CLOCK_50,received_data,received_data2,reset,keyleft,keyright,keyup,keydown);

input CLOCK_50,reset;
input [6:0]received_data;
input [6:0]received_data2;
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
