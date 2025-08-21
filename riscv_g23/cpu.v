`include "riscv_defs.vh"

module cpu(
    input clk,
    input rst
);
    reg [31:0] pc;
    wire [31:0] instr;

    wire [6:0]  opcode = instr[6:0];
    wire [4:0]  rd     = instr[11:7];
    wire [2:0]  funct3 = instr[14:12];
    wire [4:0]  rs1    = instr[19:15];
    wire [4:0]  rs2    = instr[24:20];
    wire [6:0]  funct7 = instr[31:25];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    instr_mem IMEM(.addr(pc), .instr(instr));

    wire [31:0] rs1_data, rs2_data, rd_data;
    regfile RF(
        .clk(clk), .we(reg_we),
        .rs1_addr(rs1), .rs2_addr(rs2),
        .rd_addr(rd), .rd_data(rd_data),
        .rs1_data(rs1_data), .rs2_data(rs2_data)
    );

    wire [31:0] alu_a = rs1_data;
    wire [31:0] alu_b = alu_src_imm ? imm_i : (op_is_sll ? rs2_data : rs2_data);
    wire [31:0] alu_y;
    wire alu_zero;
    alu ALU(.a(alu_a), .b(alu_b), .op(alu_op), .y(alu_y), .zero(alu_zero));

    wire [31:0] lh_signed;
    data_mem DMEM(
        .clk(clk),
        .mem_we_half(mem_we_half),
        .mem_re_half(mem_re_half),
        .addr(alu_y),       
        .rs2_data(rs2_data),
        .lh_signed(lh_signed)
    );

    // Control
    reg [3:0]  alu_op;
    reg        reg_we;
    reg        alu_src_imm;
    reg        mem_we_half;
    reg        mem_re_half;
    reg        writeback_from_mem;
    reg        op_is_sll;
    reg        take_branch_bne;

    localparam ALU_ADD = 4'd0;
    localparam ALU_OR  = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_SLL = 4'd3;

    always @* begin
        alu_op = ALU_ADD;
        reg_we = 1'b0;
        alu_src_imm = 1'b0;
        mem_we_half = 1'b0;
        mem_re_half = 1'b0;
        writeback_from_mem = 1'b0;
        op_is_sll = 1'b0;
        take_branch_bne = 1'b0;

        case (opcode)
            `OPC_RTYPE: begin
                reg_we = 1'b1;
                case (funct3)
                    `F3_ADD_SUB: begin 
                        if (funct7 == `F7_ADD_SRL_SLL) alu_op = ALU_ADD;
                    end
                    `F3_OR: begin
                        alu_op = ALU_OR;
                    end
                    `F3_SLL: begin
                        alu_op = ALU_SLL;
                        op_is_sll = 1'b1;
                    end
                    default: begin end
                endcase
            end

            `OPC_ITYPE: begin 
                reg_we = 1'b1;
                alu_src_imm = 1'b1;
                if (funct3 == `F3_ANDI) alu_op = ALU_AND;
            end

            `OPC_LOAD: begin 
                alu_src_imm = 1'b1;
                mem_re_half = (funct3 == `F3_LH);
                writeback_from_mem = 1'b1;
                reg_we = 1'b1;
                alu_op = ALU_ADD;
            end

            `OPC_STORE: begin 
                alu_src_imm = 1'b1;
                mem_we_half = (funct3 == `F3_SH);
                reg_we = 1'b0;
            end

            `OPC_BRANCH: begin 
                take_branch_bne = (funct3 == `F3_BNE) && (rs1_data != rs2_data);
                reg_we = 1'b0;
            end
            default: begin end
        endcase
    end

    assign rd_data = writeback_from_mem ? lh_signed : alu_y;

    wire [31:0] pc_next_seq = pc + 32'd4;
    wire [31:0] pc_branch   = pc + imm_b;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end else begin
            if ((opcode == `OPC_BRANCH) && take_branch_bne)
                pc <= pc_branch;
            else
                pc <= pc_next_seq;
        end
    end

endmodule
