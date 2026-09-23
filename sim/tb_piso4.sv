`timescale 1ns/1ps

module piso4 (
    input wire clk, rst, load, enable,
    input wire [3:0] data_in,
    output wire serial_out,
    output reg [3:0] value
);

    assign serial_out = value[3];

    always @(posedge clk) begin
        if (rst) value <= 4'd0;
        else if (load) value <= data_in;
        else if (enable) value <= {value[2:0], 1'b0};
    end

endmodule
