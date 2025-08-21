`timescale 1ns/1ps
module testbench;
    reg clk = 0;
    reg rst = 1;

    cpu dut(.clk(clk), .rst(rst));

    always #5 clk = ~clk; 

    integer i;
    integer logfile;
 
    initial begin
        logfile = $fopen("log.txt", "w");
        if (!logfile) begin
           $display("Erro ao abrir log.txt");
           $finish;
        end

        #1;
        dut.RF.regs[1]  = 32'd1;   // x1
        dut.RF.regs[2]  = 32'd2;   // x2
        dut.RF.regs[3]  = 32'd3;   // x3
        dut.RF.regs[4]  = 32'd4;   // x4
        dut.RF.regs[10] = 32'd0;   // x10
        dut.DMEM.mem[2] = 32'h00005678; // Mem[8] = 0x5678 (halfword test)

        #12 rst = 0;

        repeat (40) @(posedge clk);

        $display("\n==== REGISTERS (x0..x31) ====");
        $fdisplay(logfile, "\n==== REGISTERS (x0..x31) ====");
        for (i=0; i<32; i=i+1) begin
            $display("x%0d = 0x%08x (%0d)", i, dut.RF.regs[i], dut.RF.regs[i]);
            $fdisplay(logfile, "x%0d = 0x%08x (%0d)", i, dut.RF.regs[i], dut.RF.regs[i]);
        end

        $display("\n==== DATA MEMORY [0..31] (word indices) ====");
        $fdisplay(logfile, "\n==== DATA MEMORY [0..31] (word indices) ====");
        for (i=0; i<32; i=i+1) begin
            $display("DMEM[%0d] = 0x%08x", i, dut.DMEM.mem[i]);
            $fdisplay(logfile, "DMEM[%0d] = 0x%08x", i, dut.DMEM.mem[i]);
        end

        $fclose(logfile);

        $finish;
    end
endmodule
