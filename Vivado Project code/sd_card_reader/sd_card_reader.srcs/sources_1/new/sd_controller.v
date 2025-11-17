//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 03:26:40 PM
// Design Name: 
// Module Name: sd_controller
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

module sd_controller (
    input wire clk,
    input wire reset_n,
    input wire start_read,
    input wire [31:0] sector_addr,
    input wire [7:0] spi_rx_data,
    input wire spi_busy,
    input wire spi_done,
    output reg [7:0] data_out = 8'h00,        // ADD DEFAULT
    output reg data_valid = 1'b0,             // ADD DEFAULT  
    output reg ready = 1'b0,                  // ADD DEFAULT
    output reg error = 1'b0,                  // ADD DEFAULT
    output reg spi_start = 1'b0,              // ADD DEFAULT
    output reg [7:0] spi_tx_data = 8'hFF      // ADD DEFAULT
    
);



// SD Card commands
localparam CMD0  = 8'h40;   // GO_IDLE_STATE
localparam CMD8  = 8'h48;   // SEND_IF_COND
localparam CMD16 = 8'h50;   // SET_BLOCKLEN
localparam CMD17 = 8'h51;   // READ_SINGLE_BLOCK

// State definitions
localparam STATE_INIT = 6'd0;
localparam STATE_CMD0 = 6'd1;
localparam STATE_CMD8 = 6'd2;
localparam STATE_CMD16 = 6'd3;
localparam STATE_READY = 6'd4;
localparam STATE_READ_CMD = 6'd5;
localparam STATE_READ_WAIT = 6'd6;
localparam STATE_READ_DATA = 6'd7;

// Also initialize internal registers
reg [5:0] state = STATE_INIT;
reg [31:0] response_timeout = 32'd0;
reg [9:0] data_counter = 10'd0;              // INITIALIZE
reg [7:0] retry_count = 8'd0;
reg [15:0] bram_addr = 16'd0;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= STATE_INIT;
        spi_start <= 1'b0;
        ready <= 1'b0;
        error <= 1'b0;
        data_valid <= 1'b0;
        retry_count <= 8'd0;
        bram_addr <= 16'd0;
        response_timeout <= 32'd0;
        data_counter <= 10'd0;
        spi_tx_data <= 8'hFF;  // Default to idle
    end else begin
        // Default assignments
        spi_start <= 1'b0;
        data_valid <= 1'b0;
        
        case (state)
            STATE_INIT: begin
                // Wait for initialization period
                if (response_timeout < 32'd100) begin
                    response_timeout <= response_timeout + 32'd1;
                     if (response_timeout == 32'd1) begin
            $display("SD Controller: INIT started at time %t", $time);
            end
                end else begin
                    state <= STATE_CMD0;
                    response_timeout <= 32'd0;
                    $display("SD Controller: INIT complete, moving to CMD0");
                    
                end
            end
            
            STATE_CMD0: begin
                // Send CMD0 - GO_IDLE_STATE
                if (!spi_busy) begin
                    spi_tx_data <= 8'h40;  // CMD0
                    spi_start <= 1'b1;
                    state <= STATE_CMD8;
                    $display("SD Controller: Sent CMD0");
                    
                end
                
            end
            
            STATE_CMD8: begin
                if (spi_done && !spi_busy) begin
                    spi_tx_data <= 8'h48;  // CMD8  
                    spi_start <= 1'b1;
                    state <= STATE_READY;
                    $display("SD Controller: Sent CMD8");
                    
                end
            end
            
            STATE_READY: begin
                if (spi_done) begin
                    ready <= 1'b1;
                    if (start_read) begin
                        state <= STATE_READ_CMD;
                        ready <= 1'b0;
                        bram_addr <= 16'd0;
                    end
                end
            end
            
            // ... rest of states ...
        endcase
    end
end

endmodule
