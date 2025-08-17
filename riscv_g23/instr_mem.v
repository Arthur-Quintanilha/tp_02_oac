// Instruction memory: 256 words (1KB). Loads binary lines via $readmemb.
module instr_mem(
    input  [31:0] addr,      // byte address
    output [31:0] instr
);
    reg [31:0] mem[0:255];
    initial begin
        // Expect a file "saida.dat" with 32-bit binary strings (one per line)
        $readmemb("saida.dat", mem);
    end
    assign instr = mem[addr[31:2]]; // word aligned
endmodule
