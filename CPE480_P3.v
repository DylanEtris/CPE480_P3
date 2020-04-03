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
`define HIGH4 [15:12]
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

`define OPCI8	8'hbz
`define OPCII	8'hcz
`define OPCUP	8'hdz

`define OPBZ	8'hez
`define OPBNZ	8'hfz

`define NOP	16'h5100  //is this okay for a NOP?




module processor(halt, reset, clk);
output reg halt;
input reset, clk;

reg `DATA r `REGS;	// register file
reg `DATA dm `SIZE;	// data memory
reg `INST im `SIZE;	// instruction memory
reg `ADDR pc;
reg `ADDR tpc, pc0, pc1, pc2, pc3;
reg `INST ir;
reg `INST ir0, ir1, ir2;
reg `DATA rd0, rd1, rd2;
reg `DATA rs0, rs1, rs2;
reg `DATA res;
reg jump;
wire zreg;		// z flag
wire pendz;
wire pendpc;
reg wait1, wait2;
reg `STATE op;

reg `NIB head;		// current header (1st half of opcode)
reg `REGNAME d;	// destination register name
reg `REGNAME s; //source register name
reg `DATA src;		// src value
reg `DATA target;	// target for branch or jump
reg `ADDR lc;		// addr of this instruction

assign zreg = (res == 0);


always @(reset) begin
	halt <= 0;
	pc <= 0;
	ir0 <= `NOP; ir1 <= `NOP; ir2 <= `NOP;
	jump = 0;

	//Load vmem files
	$readmemh0(im);
	$readmemh1(dm);
end


function setsrd;
input `INST inst;
setsrd = ((inst `F_OP >= `OPCI8) && (inst `F_OP <= `OPCUP)) ||
	 ((inst `F_OP >= `OPAND) && (inst `F_OP <= `OPSLTII)) ||
	 ((inst `F_OP >= `OPNOT) && (inst `F_OP <= `OPLD));
endfunction

//work on this
function setspc;
input `INST inst;
	setspc = ((inst `F_OP == `OPBZ) ||
		  (inst `F_OP == `OPBNZ) ||
		  (inst `F_OP == `OPJR));
endfunction

//work on this
function setsz;
input `INST inst;
setsz = 0;
endfunction

//work on this
function iscond;
input `INST inst;
iscond = 0;
endfunction


//work on this
function usesrd;
input `INST inst;
usesrd = ((inst `F_OP == `OPADDI) ||
          (inst `F_OP == `OPADDII) ||
          (inst `F_OP == `OPADDP) ||
          (inst `F_OP == `OPADDPP) ||
          (inst `F_OP == `OPMULI) ||
          (inst `F_OP == `OPMULII) ||
          (inst `F_OP == `OPMULP) ||
          (inst `F_OP == `OPMULPP) ||
          (inst `F_OP == `OPAND) ||
          (inst `F_OP == `OPOR) ||
          (inst `F_OP == `OPXOR) ||
          (inst `F_OP == `OPNOT) ||
          (inst `F_OP == `OPANYI));
endfunction

//work on this
function usesrs;
input `INST inst;
usesrs = 0;
endfunction

//work on this
// pending z update?
assign pendz = (setsz(ir0) || setsz(ir1));

//work on this
// pending PC update?
assign pendpc = (setspc(ir0) || setspc(ir1));



//stage 0: instruction fetch
always @(posedge clk) begin

	tpc = (jump ? target : pc);

	if (wait1) begin
		pc <= tpc;
		$display("stuck in if(wait1)\n");
		//wait
	end else begin
		//not blocked by stage 1
		ir = im[tpc];

		if (pendpc || (iscond(ir) && pendz)) begin
			//waiting... pc doesnt change
			ir0 <= `NOP;
			pc <= tpc;
		end else begin
			ir0 <= ir;
		end
		pc <= tpc + 1;
	end
end


//this needs fixing i think, gets stuck in infinite loop i think 
//stage 1: register read
always @(posedge clk) begin
  $display("%H %d %d %H %H %d %d\n", iro, setsrd(ir1),usesrd(ir0), ir0`F_D, ir1`F_D, ir0`F_S, ir1`F_D);
  if ((ir0 != `NOP) && setsrd(ir1) && ((usesrd(ir0) && (ir0 `F_D == ir1 `F_D)) ||
       (usesrs(ir0) && (ir0 `F_S == ir1 `F_D)))) begin
    // stall waiting for register value
    wait1 = 1;
    ir1 <= `NOP;
  end else begin
    // all good, get operands (even if not needed)
    wait1 = 0;
    rd1 <= r[ir0 `F_D];
    rs1 <= r[ir0 `F_S];
    ir1 <= ir0;
  end

end

//stage 2: ALU, data memory access, reg write
always @(posedge clk) begin
if ((ir1 == `NOP) || ((ir1 == `OPBZ) && (zreg == 0)) || ((ir1 == `OPBNZ) && (zreg == 1))) begin
	// condition says nothing happens
	jump <= 0;
end else begin
	case(ir1 `F_OP)
		`OPADDI: begin res = rd1 + rs1; end
		`OPADDII: begin res = rd1 + rs1; res`HI8 = rd1`HI8 + rs1`HI8; end
		`OPADDP: begin res <= rd1 + rs1; end
		`OPADDPP: begin res <= rd1 + rs1; res`HI8 = rd1`HI8 + rs1`HI8; end
		`OPMULI: begin res <= rd1 * rs1; end
		`OPMULII: begin res <= rd1 * rs1; res`HI8 = rd1`HI8 * rs1`HI8; end
		`OPMULP: begin res <= rd1 * rs1; end
		`OPMULPP: begin res <= rd1 * rs1; res`HI8 <= rd1`HI8 * rs1`HI8; end
		`OPAND: begin res <= rd1 & rs1; end
		`OPOR: begin res <= rd1 | rs1; end
		`OPXOR: begin res <= rd1 ^ rs1; end
		`OPNOT: begin res <= ~rd1; end
		`OPANYI: begin res <= (rd1 ? -1 : 0); end
		`OPANYII: begin res `HI8 <= (rd1 `HI8 ? -1 : 0); res `LO8 <= (rd1 `LO8 ? -1 : 0); end
		`OPLD:  begin res <= dm[rs1]; end
		`OPSLTI: begin res <= rd1 < rs1; end
		`OPSLTII: begin res `HIGH8 <= rd1 `HIGH8 < rs1 `HIGH8; rd1 `LOW8 <= rd1 `LOW8 < rs1 `LOW8; end
		`OPI2P: begin res <= rd1; end
		`OPII2PP: begin res `HI8 <= rd1 `HI8; rd1 `LO8 <= rd1 `LO8; end
		`OPP2I: begin res <= rd1; end
		`OPPP2II: begin res `HI8 <= rd1 `HI8; rd1 `LO8 <= rd1 `LO8; end
		`OPINVP: begin res <= (rd1 == 1 ? 1 : 0); end
		`OPINVPP: begin res `HI8 <= (rd1`HI8 == 1 ? 1 : 0); rd1`LO8 <= (rd1`LO8 == 1 ? 1 : 0); end
		`OPCI8:	begin res <= ir1`F_C8; if(ir1[11:11] == 1) res`HI8 = 255; else res`HI8 = 0; end
		`OPCII: begin res <= ir`F_C8; res`HI8 <= ir1`F_C8; end
		`OPCUP: begin res`HI8 <= ir1`F_C8; end
		`OPSHI: begin res <= (rs1 > 32767 ? rd1 >> -rs1 : rd1 << rs1); end
		`OPSHII: begin res`LO8 <= (rs1`LO8 > 127 ? rd1`LO8 >> -rs1`LO8 : rd1`LO8 << rs1`LO8); 
			       res`HI8 <= (rs1`HI8 > 127 ? rd1`HI8 >> -rs1`HI8 : rd1`HI8 << rs1`HI8); end
		`OPST:  begin dm[rs1] <= rd1; end // this may be wrong
		`OPLD:  begin res = dm[rs1]; end
		//add jumps, branches somewhere?
		default: halt <= 1;
	endcase

//work on this
	if (setsrd(ir1)) begin
		if (ir1 `F_D == 15) begin
			jump <= 1;
			target <= res;
		end else begin
			r[ir1 `F_D] <= res;
			jump <= 0;
		end
	end else jump <= 0;
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
  #10 reset = 0;
  while (!halted) begin
    #10 clk = 1;
    #10 clk = 0;
  end
  $finish;
end
endmodule
