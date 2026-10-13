
`timescale 1ns/1ps

module tb_sync_fifo;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full;
    wire empty;

    integer errors;

    sync_fifo #(
        .DATA_WIDTH(8),
        .DEPTH(16),
        .ADDR_WIDTH(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // 10 ns clock period
    initial clk = 0;
    always #5 clk = ~clk;

    // Apply inputs away from the rising edge
    task write_data;
        input [7:0] value;
        begin
            @(negedge clk);
            din = value;
            wr_en = 1;
            rd_en = 0;
            @(posedge clk);
            #1;
            @(negedge clk);
            wr_en = 0;
        end
    endtask

    task read_data;
        input [7:0] expected;
        begin
            @(negedge clk);
            wr_en = 0;
            rd_en = 1;
            @(posedge clk);
            #1;
            if (dout !== expected) begin
                $display("FAIL: expected %0d, got %0d",
                         expected, dout);
                errors = errors + 1;
            end else begin
                $display("PASS: read %0d", dout);
            end
            @(negedge clk);
            rd_en = 0;
        end
    endtask

    initial begin

    $dumpfile("waveforms/fifo_waveform.vcd");
     $dumpvars(0, tb_sync_fifo);
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Test 1: FIFO starts empty
        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should be empty after reset");
            errors = errors + 1;
        end else begin
            $display("PASS: FIFO empty after reset");
        end

        // Test 2: FIFO ordering
        write_data(10);
        write_data(20);
        write_data(30);

        if (empty !== 1'b0) begin
            $display("FAIL: FIFO should not be empty");
            errors = errors + 1;
        end

        read_data(10);
        read_data(20);
        read_data(30);

        // Test 3: FIFO becomes empty again
        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should be empty after reads");
            errors = errors + 1;
        end else begin
            $display("PASS: FIFO empty after reads");
        end

        // Test 4: Fill all 16 entries
        for (integer i = 0; i < 16; i = i + 1)
            write_data(i);

        if (full !== 1'b1) begin
            $display("FAIL: FIFO should be full");
            errors = errors + 1;
        end else begin
            $display("PASS: FIFO full at 16 entries");
        end

        // Test 5: Read all 16 entries in order
        for (integer j = 0; j < 16; j = j + 1)
            read_data(j);

        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should be empty at end");
            errors = errors + 1;
        end

               // Test 6: Read while empty
        // A read must not change the empty FIFO's occupancy.
        @(negedge clk);
        wr_en = 0;
        rd_en = 1;
        @(posedge clk);
        #1;

        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should remain empty after read while empty");
            errors = errors + 1;
        end else begin
            $display("PASS: read while empty keeps FIFO empty");
        end

        @(negedge clk);
        rd_en = 0;

        // Test 7: Write while full
        // Fill all 16 entries with values 0 to 15.
        for (integer k = 0; k < 16; k = k + 1)
            write_data(k);

        // Attempt an additional write while full.
        write_data(200);

        if (full !== 1'b1) begin
            $display("FAIL: FIFO should remain full after write while full");
            errors = errors + 1;
        end else begin
            $display("PASS: write while full keeps FIFO full");
        end

        // Confirm the original entries remain unchanged.
        for (integer m = 0; m < 16; m = m + 1)
            read_data(m);

        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should be empty after boundary test");
            errors = errors + 1;
        end

        // Test 8: Simultaneous read and write
        write_data(42);
        write_data(55);

        @(negedge clk);
        din = 77;
        wr_en = 1;
        rd_en = 1;

        @(posedge clk);
        #1;

        if (dout !== 42) begin
            $display("FAIL: simultaneous read/write expected 42, got %0d", dout);
            errors = errors + 1;
        end else begin
            $display("PASS: simultaneous read/write returns oldest value 42");
        end

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        // Remaining FIFO order should be 55, then 77.
        read_data(55);
        read_data(77);

        if (empty !== 1'b1) begin
            $display("FAIL: FIFO should be empty after simultaneous read/write test");
            errors = errors + 1;
        end else begin
            $display("PASS: FIFO empty after simultaneous read/write test");
        end

        // Final regression result
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule

