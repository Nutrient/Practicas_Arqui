/******************************************************************
* Description
*	This is a  an 4to1 multiplexer that can be parameterized in its bit-width.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* Contibuidor:
*	Erick Cardona y Carlo Bruno Figueroa
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

module Multiplexer4to1
#(
	parameter NBits=32
)
(
	input [1:0] Selector,
	input [NBits-1:0] MUX_Data0,
	input [NBits-1:0] MUX_Data1,
	input [NBits-1:0] MUX_Data2,
	input [NBits-1:0] MUX_Data3,
	
	output reg [NBits-1:0] MUX_Output

);

	always@(Selector,MUX_Data3,MUX_Data2,MUX_Data1,MUX_Data0) begin
		casex(Selector)
			2'b00: MUX_Output = MUX_Data0;
			2'b01: MUX_Output = MUX_Data1;
			2'b10: MUX_Output = MUX_Data2;
			
			default: MUX_Output = MUX_Data3;
	endcase

endmodule