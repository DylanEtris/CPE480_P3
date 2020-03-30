// some basic sizes of things
`define DATA	[15:0]
`define ADDR	[15:0] //address
`define INST	[15:0] //instruction
`define SIZE	[65535:0]
`define STATE	[7:0]  //state number size & opcode size
`define REGS	[15:0] //size of registers
`define REGNAME	[3:0]  //16 registers to choose from
`define WORD	[15:0] //16-bit words
`define HALF	[7:0]	//8-bit half-words
`define NIB		[3:0]	//4-bit nibble
`define HI8		[15:8]
`define LO8		[7:0]
`define HIGH8	[15:8]
`define LOW8	[7:0]

// the instruction fields
`define F_H		[15:12] //4-bit header (needed for short opcodes)
`define F_OP	[15:8]
`define F_D		[3:0]
`define F_S		[7:4]
`define F_C8	[11:4]
`define F_ADDR	[11:4]

//long instruction headers
`define HCI8	4'hb
`define HCII	4'hc
`define HCUP	4'hd
`define HBNZ	4'hf
`define HBZ		4'he

// opcode values, also state numbers
`define OPADDI	8'h70
`define OPADDII	8'h71
`define OPMULI	8'h72
`define OPMULII	8'h73
`define OPSHI	8'h74
`define OPSHII	8'h75
`define OPSLTI	8'h76
`define OPSLTII	8'h77

`define OPADDP	8'h60
`define OPADDPP	8'h61
`define OPMULP	8'h62
`define OPMULPP	8'h63

`define OPAND	8'h50
`define OPOR	8'h51
`define OPXOR	8'h52

`define OPLD	8'h40
`define OPST	8'h41

`define OPANYI	8'h30
`define OPANYII	8'h31
`define OPNEGI	8'h32
`define OPNEGII	8'h33

`define OPI2P	8'h20
`define OPII2PP	8'h21
`define OPP2I	8'h22
`define OPPP2II	8'h23
`define OPINVP	8'h24
`define OPINVPP	8'h25

`define OPNOT	8'h10

`define OPJR	8'h01

`define OPTRAP	8'h00

`define OPCI8	8'hb0
`define OPCII	8'hc0
`define OPCUP	8'hd0

`define OPBZ	8'he0
`define OPBNZ	8'hf0


// state numbers (unused op codes)
`define Start	8'h98
`define Decode	8'h99

// some shorthands for in-state operations
`define START	state <= `Start; end
`define NEXT	begin pc = pc + 1; `START end //why is is like this?
//`define PCSAVE	begin u[usp + 1] <= landpc; usp <= usp + 1; end
`define	DSAVE	begin u[usp + 1] <= r[d]; usp <= usp + 1; end
`define	PCREST	begin pc <= u[usp]; usp <= usp - 1; end
`define	DREST	begin r[d] <= u[usp]; usp <= usp - 1; end



module processor(halt, reset, clk);
output reg halt;
input reset, clk;

reg `DATA r `REGS;	// register file
reg `DATA dm `SIZE;	// data memory
reg `INST im `SIZE;	// instruction memory
reg `INST ir;
reg `STATE state;
//reg `STATE op;		// current opcode
reg `NIB head;		// current header (1st half of opcode)
reg `REGNAME d;	// destination register name
reg `REGNAME s; //source register name
reg `DATA src;		// src value
reg `DATA target;	// target for branch or jump
reg `ADDR pc;
reg `ADDR lc;		// addr of this instruction
//reg `ADDR landpc;	// addr of previous instruction
//reg `UPTR usp;		// undo stack pointer
//reg `DATA u `USIZE;	// undo stack
//reg `DATA check;
//reg `DATA errors;



always @(posedge clk) begin
	if (reset) begin
		halt <= 0;
		pc <= 0;
//		landpc <= 0;
		state <= `Start;
//		check <= 0;
//		errors <= 0;
		//Load vmem files
	$readmemh0(im);
	$readmemh1(dm);
	end 
	else begin
		//#1 $display("State: %h",state);
		// extract the header
		head = ir `F_H;
		// get destination register
		d <= ir `F_D;
		case (state)
		`Start: begin
			ir <= im[pc]; 
			state <= `Decode; 
//			landpc <= lc; 
			lc <= pc; 
			end
		`Decode: begin 
			case(head)
				`HCI8: state <= `OPCI8;
				`HCII: state <= `OPCII;
				`HCUP: state <= `OPCUP;
				`HBNZ: state <= `OPBNZ;
				`HBZ:  state <= `OPBZ;
				default: begin
					state <= ir`F_OP;
					s = ir `F_S;
				end
				endcase
			pc <= pc + 1;
			d = ir `F_D;
			end
		`OPCI8:	begin
			r[d] <= ir`F_C8;
			if(ir[11:11] == 1)
				r[d]`HI8 <= 255;
			else
				r[d]`HI8 <= 0;
			state <= `Start;
			//#1 $display("ci8, $%d = %H", d, r[d]);
			end
		`OPCII: begin
			r[d] <= ir`F_C8;
			r[d]`HI8 <= ir`F_C8;
			state <= `Start;
			//#1 $display("cii, $%d = %H", d, r[d]);
			end
		`OPCUP: begin
			r[d]`HI8 <= ir`F_C8;
			state <= `Start;
			//#1 $display("cup, $%d = %H", d, r[d]);
			end
		`OPADDI: begin 
			r[d] <= r[d] + r[s]; 
			state <= `Start; 
			//#1 $display("addi, $%d +$%d = %h",d,s,r[d]);
			end
		`OPADDP:begin 
			r[d] <= r[d] + r[s]; 
			state <= `Start; 
			//#1 $display("addp, $%d +$%d = %h",d,s,r[d]);
			end
		`OPADDII:begin
			r[d] <= r[d] + r[s];
			r[d]`HI8 <= r[d]`HI8 + r[s]`HI8;
			state <= `Start;
			//#1 $display("addii $%d, $%d =%h",d,s,r[d]);
			end
		`OPADDPP:begin
			r[d] <= r[d] + r[s];
			r[d]`HI8 <= r[d]`HI8 + r[s]`HI8;
			state <= `Start;
			//#1 $display("addpp $%d, $%d =%h",d,s,r[d]);
			end
		`OPMULI:begin
			r[d] <= r[d] * r[s];
			state <= `Start;
			//#1 $display("muli $%d, $%d =%h",d,s,r[d]);
			end
		`OPMULP:begin
			r[d] <= r[d] * r[s];
			state <= `Start;
			//#1 $display("mulp $%d, $%d =%h",d,s,r[d]);
			end
		`OPMULII:begin
			r[d] <= r[d] * r[s];
			r[d]`HI8 <= r[d]`HI8 * r[s]`HI8;
			state <= `Start;
			//#1 $display("mulii $%d, $%d =%h",d,s,r[d]);
			end
		`OPMULPP:begin
			r[d] <= r[d] * r[s];
			r[d]`HI8 <= r[d]`HI8 * r[s]`HI8;
			state <= `Start;
			//#1 $display("mulpp $%d, $%d =%h",d,s,r[d]);
			end
		`OPSHI: begin
			r[d] <= (r[s] > 32767 ? r[d] >> -r[s] : r[d] << r[s]);
			state <= `Start;
			//#1 $display("shi $%d, $%d =%h",d,s,r[d]);
			end
		`OPSHII: begin
			r[d]`LO8 <= (r[s]`LO8 > 127 ? r[d]`LO8 >> -r[s]`LO8 : r[d]`LO8 << r[s]`LO8);
			r[d]`HI8 <= (r[s]`HI8 > 127 ? r[d]`HI8 >> -r[s]`HI8 : r[d]`HI8 << r[s]`HI8);
			state <= `Start;
			//#1 $display("shii $%d, $%d =%h",d,s,r[d]);
			end
		`OPAND: begin
			r[d] <= r[d] & r[s];
			state <= `Start;
			//#1 $display("and, $%d +$%d = %h",d,s,r[d]);
			end
		`OPOR: begin
			r[d] <= r[d] | r[s];
			state <= `Start;
			//#1 $display("or, $%d +$%d = %h",d,s,r[d]);
			end
		`OPXOR: begin
			r[d] <= r[d] ^ r[s];
			state <= `Start;
			//#1 $display("xor, $%d +$%d = %h",d,s,r[d]);
			end
		`OPNOT: begin
			r[d] <= ~r[d];
			state <= `Start;
			//#1 $display("not, $%d +$%d = %h",d,s,r[d]);
			end
		`OPANYI:begin
			r[d] <= (r[d] ? -1 : 0); 
			state <= `Start;
			//#1 $display("anyi, $%d +$%d = %h",d,s,r[d]);
			end
		`OPANYII:begin
			r[d] `HI8 <= (r[d] `HI8 ? -1 : 0);
			r[d] `LO8 <= (r[d] `LO8 ? -1 : 0);  
			state <= `Start;
			//#1 $display("anyii, $%d +$%d = %h",d,s,r[d]);
			end
		`OPNEGI: begin
			r[d] <= -r[d];
			state <= `Start;
			//#1 $display("negi, $%d +$%d = %h",d,s,r[d]);
			end
		`OPNEGII: begin
			r[d] `HI8 <= -r[d] `HI8;
			r[d] `LO8 <= -r[d] `LO8;
			state <= `Start;
			//#1 $display("negii, $%d +$%d = %h",d,s,r[d]);
			end
		`OPST:  begin
			dm[r[s]] <= r[d]; 
			state <= `Start;
			//#1 $display("st, $%d +$%d = %h",d,s,dm[r[s]]);
			end
		`OPLD:  begin
			r[d] <= dm[r[s]];
			state <= `Start;
			//#1 $display("ld, $%d +$%d = %h",d,s,r[d]);
			end
		`OPSLTI: begin 
			r[d] <= r[d] < r[s]; 
			state <= `Start;
			//#1 $display("slti $%d, $%d =%h",d,s,r[d]); 
			end
		`OPSLTII: begin 
			r[d] `HIGH8 <= r[d] `HIGH8 < r[s] `HIGH8; 
			r[d] `LOW8 <= r[d] `LOW8 < r[s] `LOW8; 
			state <= `Start; 
			//#1 $display("sltii $%d, $%d =%h",d,s,r[d]); 
			end
		`OPI2P: begin 
			r[d] <= r[d];
			state <= `Start; 
			//#1 $display("i2p $%d, $%d =%h",d,d,r[d]);
			end
		`OPII2PP: begin
			r[d] `HI8 <= r[d] `HI8;
			r[d] `LO8 <= r[d] `LO8;
			state <= `Start; 
			//#1 $display("ii2pp $%d, $%d =%h",d,d,r[d]);
			end
		`OPP2I: begin 
			r[d] <= r[d];
			state <= `Start; 
			//#1 $display("p2i $%d, $%d =%h",d,d,r[d]);
			end
		`OPPP2II: begin
			r[d] `HI8 <= r[d] `HI8;
			r[d] `LO8 <= r[d] `LO8;
			state <= `Start; 
			//#1 $display("pp2ii $%d, $%d =%h",d,d,r[d]);
			end
		`OPINVP: begin 
			r[d] <= (r[d] == 1 ? 1 : 0);
			state <= `Start; 
			//#1 $display("invp $%d, $%d =%h",d,d,r[d]);
			end
		`OPINVPP: begin 
			r[d]`HI8 <= (r[d]`HI8 == 1 ? 1 : 0);
			r[d]`LO8 <= (r[d]`LO8 == 1 ? 1 : 0);
			state <= `Start; 
			//#1 $display("invpp $%d, $%d =%h",d,d,r[d]);
			end
		`OPJR: begin 
			//#1 $display("JR from %d",pc);
			pc <= r[d]; 
			state <= `Start; 
			//#1 $display("JR to %d",pc);
			end
		`OPBZ: 	begin
			//#1 $display("BZ from %d",pc);
		    if(r[d] == 0) pc <= pc - 1 + ir `F_C8;
			state <= `Start;
			//#1 $display("BZ to %d",pc);
			end
		`OPBNZ: begin
			//#1 $display("BNZ from %d",pc);
		       	if(r[d] != 0) begin
		       		pc <= pc - 1 + ir `F_C8;
		       	end
			state <= `Start;
			//#1 $display("BNZ to %d",pc);
			end
		default:
			halt <= 1;
		endcase
	end
end
endmodule

module testbench;
reg reset = 0;
reg clk = 0;
wire halted;
processor PE(halted, reset, clk);
initial begin
$dumpfile;
$dumpvars(0, PE);
  #10 reset = 1;
  #10 clk = 1;
  #10 reset = 0;
  while (!halted) begin
    #10 clk = 0;
    #10 clk = 1;
  end
  $finish;
end
endmodule
