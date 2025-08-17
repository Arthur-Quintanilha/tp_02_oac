`timescale 1ns/1ps
module testbench;
    reg clk = 0;
    reg rst = 1;

    // Instantiate CPU
    cpu dut(.clk(clk), .rst(rst));

    // Clock generation
    always #5 clk = ~clk; // 100MHz

    integer i;

    initial begin
        // Optional: preload data memory or registers via hierarchy if needed
        // Example initial register values to exercise the program:
        // x1=1, x2=2, x3=3, x4=4, x10=0, memory at [2] has some 32-bit word
        // Wait for IMEM to load
        #1;
        // Set some register values
        dut.RF.regs[1]  = 32'd1;   // x1
        dut.RF.regs[2]  = 32'd2;   // x2
        dut.RF.regs[3]  = 32'd3;   // x3
        dut.RF.regs[4]  = 32'd4;   // x4
        dut.RF.regs[10] = 32'd0;   // x10
        dut.DMEM.mem[2] = 32'h00005678; // at byte addr 8 (since word index 2) -> LH will see 0x5678 or 0x0000 depending on half

        // Reset pulse
        #12 rst = 0;

        // Run for some cycles
        repeat (40) @(posedge clk);

        // Dump registers
        $display("\n==== REGISTERS (x0..x31) ====");
        for (i=0; i<32; i=i+1) begin
            $display("x%0d = 0x%08x (%0d)", i, dut.RF.regs[i], dut.RF.regs[i]);
        end

        // Dump first 32 words of data memory
        $display("\n==== DATA MEMORY [0..31] (word indices) ====");
        for (i=0; i<32; i=i+1) begin
            $display("DMEM[%0d] = 0x%08x", i, dut.DMEM.mem[i]);
        end

        $finish;
    end
endmodule
