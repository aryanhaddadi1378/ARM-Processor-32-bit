`define MODE_ARITHMETIC 2'b00
`define MODE_MEM 2'b01
`define MODE_BRANCH 2'b10

`define EX_MOV 4'b0001
`define EX_MVN 4'b1001
`define EX_ADD 4'b0010
`define EX_ADC 4'b0011
`define EX_SUB 4'b0100
`define EX_SBC 4'b0101
`define EX_AND 4'b0110
`define EX_ORR 4'b0111
`define EX_EOR 4'b1000
`define EX_CMP 4'b1100
`define EX_TST 4'b1110
`define EX_LDR 4'b1010
`define EX_STR 4'b1010

`define OP_MOV 4'b1101
`define OP_MVN 4'b1111
`define OP_ADD 4'b0100
`define OP_ADC 4'b0101
`define OP_SUB 4'b0010
`define OP_SBC 4'b0110
`define OP_AND 4'b0000
`define OP_ORR 4'b1100
`define OP_EOR 4'b0001
`define OP_CMP 4'b1010
`define OP_TST 4'b1000
`define OP_LDR 4'b0100
`define OP_STR 4'b0100


module Control_Unit
(
    input            S,
    input      [1:0] mode,
    input      [3:0] OP,
    
    output           SR_update,
    output           with_src1,
    output reg       MEM_R,
    output reg       MEM_W,
    output reg       WB_EN,
    output reg       B,
    output reg [3:0] EX_CMD
);

    always @(*) begin
        MEM_R = 0;
        MEM_W = 0;
        WB_EN = 0;
        B = 0;
        case (mode)
            `MODE_MEM: begin
                case (S)
                    0: begin
                        EX_CMD = `EX_STR;
                        MEM_W = 1;
                    end

                    1: begin
                        EX_CMD = `EX_LDR;
                        MEM_R = 1;
                        WB_EN = 1;
                    end
                endcase
            end

            `MODE_ARITHMETIC: begin
                case (OP)
                    `OP_MOV: begin
                        EX_CMD = `EX_MOV;
                        WB_EN = 1;
                    end

                    `OP_MVN: begin
                        EX_CMD = `EX_MVN;
                        WB_EN = 1;
                    end

                    `OP_ADD: begin
                        EX_CMD = `EX_ADD;
                        WB_EN = 1;
                    end

                    `OP_ADC: begin
                        EX_CMD = `EX_ADC;
                        WB_EN = 1;
                    end

                    `OP_SUB: begin
                        EX_CMD = `EX_SUB;
                        WB_EN = 1;
                    end

                    `OP_SBC: begin
                        EX_CMD = `EX_SBC;
                        WB_EN = 1;
                    end
                    `OP_AND: begin
                        EX_CMD = `EX_AND;
                        WB_EN = 1;
                    end

                    `OP_ORR: begin
                        EX_CMD = `EX_ORR;
                        WB_EN = 1;
                    end

                    `OP_EOR: begin
                        EX_CMD = `EX_EOR;
                        WB_EN = 1;
                    end

                    `OP_CMP: EX_CMD = `EX_CMP;
                    `OP_TST: EX_CMD = `EX_TST;
                endcase
            end

            `MODE_BRANCH: B = 1;
        endcase
    end

    assign with_src1 = (EX_CMD == `EX_MOV || EX_CMD == `EX_MOV || B) ? 1'b0 : 1'b1;
    assign SR_update = S;

endmodule
