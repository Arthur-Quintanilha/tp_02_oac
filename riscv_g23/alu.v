module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  op,
    output reg [31:0] y,
    output zero
);
    localparam ALU_ADD = 4'd0;
    localparam ALU_OR  = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_SLL = 4'd3;
    localparam ALU_PASSB = 4'd15;

    always @* begin
        case (op)
            ALU_ADD: y = a + b;
            ALU_OR : y = a | b;
            ALU_AND: y = a & b;
            ALU_SLL: y = a << b[4:0];
            ALU_PASSB: y = b;
            default: y = 32'hDEADBEEF;
        endcase
    end

    assign zero = (y == 32'b0);
endmodule
