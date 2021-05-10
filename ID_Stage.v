`include "constants.h"

module ID_Stage
(
	input                     			  clk,
	input                				  rst,
	input 								  Freeze,
	input 								  reg_file_enable,
	input  [3:0]                          Status_Register,
	input  [`REG_FILE_DEPTH-1:0]	      reg_file_wb_address,
	input  [`WORD_WIDTH-1:0]    		  PC_in,
	input  [`WORD_WIDTH-1:0]    		  instruction_in,
	input  [`WORD_WIDTH-1:0]   			  reg_file_wb_data,
	output                                mem_read_out,
	output                                mem_write_out,
	output                                WB_EN_out,
	output                                Imm_out,
	output                                B_out,
	output                                S_out,
	output                                has_src2,
	output                                has_src1,
	output [3:0]						  EX_command_out,
	output [`REG_FILE_DEPTH-1:0] 		  reg_file_src1,
	output [`REG_FILE_DEPTH-1:0] 		  reg_file_src2,
	output [`REG_FILE_DEPTH-1:0] 		  reg_file_dst,
	output [`SIGNED_IMM_WIDTH-1:0]        signed_immediate,
	output [`SHIFTER_OPERAND_WIDTH-1:0]   shifter_operand,
	output [`WORD_WIDTH-1:0]   			  PC_out,
	output [`WORD_WIDTH-1:0]			  val_Rn,
	output [`WORD_WIDTH-1:0]			  val_Rm
);

	wire [3:0] EX_command;
	wire mem_read, mem_write, WB_en, Imm, B, SR_update;
	wire [8:0] control_unit_mux_in, control_unit_mux_out;
	wire condition_state;

	assign PC_out = PC_in;
	assign control_unit_mux_enable = (~condition_state) | Freeze;
	assign control_unit_mux_in = {SR_update, B, EX_command, mem_write, mem_read, WB_en};
	assign {S_out, B_out, EX_command_out, mem_write_out, mem_read_out, WB_EN_out} = control_unit_mux_out;
	assign shifter_operand = instruction_in[11:0];
	assign reg_file_dst = instruction_in[15:12];
	assign reg_file_src1 = instruction_in[19:16];
	assign signed_immediate = instruction_in[23:0];
	assign Imm_out = instruction_in[25];
	assign has_src2 = (~instruction_in[25]) | mem_write;

	MUX_2_to_1 #(.WORD_WIDTH(4)) MUX_2_to_1_Reg_File (
		.select(mem_write),
		.inp1(instruction_in[3:0]), 
		.inp2(instruction_in[15:12]),
		.out(reg_file_src2)
	);

	Register_File register_file(
		.clk(clk), .rst(rst),
		.WB_en(reg_file_enable),
		.src1(reg_file_src1), 
		.src2(reg_file_src2),
		.WB_dest(reg_file_wb_address),
		.WB_result(reg_file_wb_data),
		.reg1(val_Rn), 
		.reg2(val_Rm)
	);

	MUX_2_to_1 #(.WORD_WIDTH(9)) MUX_2_to_1_Control_Unit (
		.select(control_unit_mux_enable),
		.inp1(control_unit_mux_in), 
		.inp2(9'b0),
		.out(control_unit_mux_out)
	);

	Control_Unit control_unit (
		.S(instruction_in[20]),
		.mode(instruction_in[27:26]), 
		.op_code(instruction_in[24:21]),
		.EX_command(EX_command),
		.mem_read(mem_read), 
		.mem_write(mem_write),
		.WB_en(WB_en), 
		.B(B),
		.SR_update(SR_update),
		.has_src1(has_src1)
	);

	Condition_Check condition_check (
		.condition(instruction_in[31:28]),
		.Status_Register(Status_Register),
		.condition_state(condition_state)
	);

endmodule
