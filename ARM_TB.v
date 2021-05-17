`timescale 1ns/1ns

module ARM_TB;

    reg clk = 0;
    reg rst;
    reg isForwardingActive;

    ARM CPU(
        .clk(clk),
        .rst(rst),
        .isForwardingActive(isForwardingActive)
    );

    always #10 clk = ~clk;

    initial begin
        rst = 1;
        isForwardingActive = 1;
        # (5);
        rst = 0;
        # (7000);
        rst = 1;
        isForwardingActive = 0;
        # (5);
        rst = 0;
        # (7000);
    $stop;
    end
    
endmodule