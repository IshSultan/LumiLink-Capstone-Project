//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 03:25:18 PM
// Design Name: 
// Module Name: bram_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module bram_buffer (
    input wire clk,
    input wire we,
    input wire [15:0] addr,
    input wire [7:0] din,
    output reg [7:0] dout
);

// 64KB Block RAM
reg [7:0] bram [0:65535];

always @(posedge clk) begin
    if (we) begin
        bram[addr] <= din;
    end
    dout <= bram[addr];
end

// CORRECT: Initialize BRAM to known values
integer i;
initial begin
    for (i = 0; i < 65536; i = i + 1) begin
        bram[i] = 8'h00; // Initialize to zeros
    end
end

endmodule