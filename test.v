module test (
    input wire clk, 
    input  wire [7:0] sw,
    output wire [7:0] led
);

    assign led [7:2] = {sw[7:6], sw[7:6], sw[7:6]};
    
    LUT6 #(.INIT(64'h8978_97342_3333_4323)) uut (.O(led[1]), .I0(sw[0]), .I1(sw[1]), .I2(sw[2]), .I3(sw[3]), .I4(sw[4]), .I5(sw[5])); 
    assign led[0] = sw[0] | sw[1] & sw[2] ^ sw[3] | sw[4] & sw[5];
    
endmodule
