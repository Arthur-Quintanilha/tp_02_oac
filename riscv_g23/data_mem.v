module data_mem(
    input         clk,
    input         mem_we_half,    
    input         mem_re_half,      
    input  [31:0] addr,           
    input  [31:0] rs2_data,         
    output [31:0] lh_signed          
);
    reg [31:0] mem[0:255];
    wire [7:0] word_index = addr[31:24]; 
    wire [31:0] w = mem[addr[31:2]];
    wire half_sel = addr[1]; 

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

endmodule
