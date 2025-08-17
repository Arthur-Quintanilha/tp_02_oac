// Data memory: 256 words (1KB). Supports LH/SH using halfword lanes.
module data_mem(
    input         clk,
    input         mem_we_half,       // write halfword
    input         mem_re_half,       // read halfword
    input  [31:0] addr,              // byte address
    input  [31:0] rs2_data,          // data to write (only [15:0] used for SH)
    output [31:0] lh_signed          // result (sign-extended)
);
    reg [31:0] mem[0:255];
    wire [7:0] word_index = addr[31:24]; // not used, but shows byte addressing
    wire [31:0] w = mem[addr[31:2]];
    wire half_sel = addr[1]; // 0 -> lower 16, 1 -> upper 16

    // LH: sign-extend selected halfword
    wire [15:0] half = half_sel ? w[31:16] : w[15:0];
    assign lh_signed = {{16{half[15]}}, half};

    always @(posedge clk) begin
        if (mem_we_half) begin
            if (half_sel)
                mem[addr[31:2]][31:16] <= rs2_data[15:0];
            else
                mem[addr[31:2]][15:0]  <= rs2_data[15:0];
        end
    end

    // Optional: preload some memory here if desired using $readmemh/memb
    // initial $readmemh("data_init.hex", mem);
endmodule
