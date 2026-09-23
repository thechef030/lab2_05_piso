`timescale 1ns/1ps

module tb_piso4;

    reg clk=0, rst=1;
    integer checks=0;

    always #5 clk=~clk;

    task step;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check(
        input condition,
        input [8*100-1:0] description
    );
        begin
            checks=checks+1;

            if (condition !== 1'b1) begin
                $display(
                    "LAB2_FAIL %0s time=%0t",
                    description,
                    $time
                );
                $fatal(1, "check failed");
            end
        end
    endtask

    task finish;
        begin
            $display(
                "LAB2_PASS piso4 checks=%0d",
                checks
            );
            $finish;
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0,tb_piso4);
    end

    initial begin
        #100000;
        $fatal(1,"watchdog timeout");
    end

    reg load=0, enable=0;
    reg [3:0] data_in=0;

    wire serial_out;
    wire [3:0] value;

    piso4 dut(
        clk,
        rst,
        load,
        enable,
        data_in,
        serial_out,
        value
    );

    integer word, bit_number;

    initial begin
        step;
        check(value===0,"reset");
        rst=0;

        for(word=0; word<16; word=word+1) begin
            data_in=word;
            load=1;
            enable=1;
            step;

            check(value===word,"load beats shift");

            load=0;
            enable=0;
            step;

            check(value===word,"hold");

            enable=1;

            for(bit_number=3;
                bit_number>=0;
                bit_number=bit_number-1) begin

                check(
                    serial_out===((word>>bit_number)&1),
                    "MSB first before edge"
                );

                step;
            end

            check(value===0,"four shifts zero fill");
        end

        rst=1;
        load=1;
        data_in=15;
        step;

        check(value===0,"reset beats load");

        finish;
    end

endmodule
