//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 03:23:37 PM
// Design Name: 
// Module Name: spi_interface
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

module spi_interface (
    input wire clk,
    input wire reset_n,
    input wire start,
    input wire [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg busy,
    output reg done,
    
    // Physical SPI signals
    output reg spi_clk,
    output reg spi_mosi,
    input wire spi_miso,
    output reg spi_cs_n
);

reg [7:0] tx_shift;
reg [7:0] rx_shift;
reg [3:0] bit_count;
reg [2:0] state;

localparam IDLE = 3'b000;
localparam CS_ASSERT = 3'b001;
localparam TRANSFER = 3'b010;
localparam CS_DEASSERT = 3'b011;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= IDLE;
        spi_cs_n <= 1'b1;
        spi_clk <= 1'b0;
        spi_mosi <= 1'b0;
        busy <= 1'b0;
        done <= 1'b0;
        rx_data <= 8'h00;
        tx_shift <= 8'h00;
        rx_shift <= 8'h00;
        bit_count <= 4'd0;
    end else begin
        case (state)
            IDLE: begin
                spi_cs_n <= 1'b1;
                spi_clk <= 1'b0;
                done <= 1'b0;
                if (start) begin
                    state <= CS_ASSERT;
                    busy <= 1'b1;
                    tx_shift <= tx_data;
                    bit_count <= 4'd0;
                    rx_shift <= 8'h00;
                end
            end
            
            CS_ASSERT: begin
                spi_cs_n <= 1'b0;
                state <= TRANSFER;
            end
            
            TRANSFER: begin
                // Toggle SPI clock
                spi_clk <= ~spi_clk;
                
                if (spi_clk) begin
                    // Rising edge - setup data
                    spi_mosi <= tx_shift[7];
                end else begin
                    // Falling edge - sample data
                    rx_shift <= {rx_shift[6:0], spi_miso};
                    tx_shift <= {tx_shift[6:0], 1'b0};
                    bit_count <= bit_count + 4'd1;
                    
                    if (bit_count == 4'd7) begin
                        state <= CS_DEASSERT;
                        rx_data <= {rx_shift[6:0], spi_miso};
                    end
                end
            end
            
            CS_DEASSERT: begin
                spi_clk <= 1'b0;
                spi_cs_n <= 1'b1;
                done <= 1'b1;
                busy <= 1'b0;
                state <= IDLE;
            end
        endcase
    end
end

endmodule