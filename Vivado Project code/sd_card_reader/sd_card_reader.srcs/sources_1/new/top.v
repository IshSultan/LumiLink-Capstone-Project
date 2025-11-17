//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 03:27:41 PM
// Design Name: 
// Module Name: top
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

module top (
    input wire clk100MHz,
    input wire reset_n,
    
    // SD Card SPI signals
    output wire sd_sclk,
    output wire sd_mosi,
    input wire sd_miso,
    output wire sd_cs,
    
    // Status LEDs
    output reg [7:0] leds
);

// Clock generation (slow down SPI clock)
reg [7:0] clk_divider;
wire spi_clk;

// Internal signals
wire spi_start;
wire [7:0] spi_tx_data;
wire [7:0] spi_rx_data;
wire spi_busy;
wire spi_done;

wire [7:0] sd_data_out;
wire sd_data_valid;
wire sd_ready;
wire sd_error;

wire bram_we;
wire [15:0] bram_addr;
wire [7:0] bram_din;
wire [7:0] bram_dout;

// Clock divider for SPI (approx 390 kHz)
always @(posedge clk100MHz) begin
    clk_divider <= clk_divider + 8'd1;
end

assign spi_clk = clk_divider[7];

// Instantiate SPI interface
spi_interface spi_inst (
    .clk(spi_clk),
    .reset_n(reset_n),
    .start(spi_start),
    .tx_data(spi_tx_data),
    .rx_data(spi_rx_data),
    .busy(spi_busy),
    .done(spi_done),
    .spi_clk(sd_sclk),
    .spi_mosi(sd_mosi),
    .spi_miso(sd_miso),
    .spi_cs_n(sd_cs)
);

// Instantiate SD controller
sd_controller sd_ctl_inst (
    .clk(clk100MHz),
    .reset_n(reset_n),
    .start_read(start_read),
    .sector_addr(sector_addr),
    .data_out(sd_data_out),
    .data_valid(sd_data_valid),
    .ready(sd_ready),
    .error(sd_error),
    .spi_start(spi_start),
    .spi_tx_data(spi_tx_data),
    .spi_rx_data(spi_rx_data),
    .spi_busy(spi_busy),
    .spi_done(spi_done)
);

// Instantiate BRAM buffer
bram_buffer bram_inst (
    .clk(clk100MHz),
    .we(sd_data_valid), // Write when we have valid SD data
    .addr(bram_addr),
    .din(sd_data_out),
    .dout(bram_dout)
);

// BRAM address counter
reg [15:0] bram_addr_counter;
always @(posedge clk100MHz or negedge reset_n) begin
    if (!reset_n) begin
        bram_addr_counter <= 16'd0;
    end else if (sd_data_valid) begin
        bram_addr_counter <= bram_addr_counter + 16'd1;
    end
end
assign bram_addr = bram_addr_counter;

// Control FSM
reg start_read;
reg [31:0] sector_addr;
reg [2:0] main_state;

localparam MAIN_IDLE = 3'd0;
localparam MAIN_WAIT_READY = 3'd1;
localparam MAIN_START_READ = 3'd2;
localparam MAIN_READING = 3'd3;
localparam MAIN_DONE = 3'd4;

always @(posedge clk100MHz or negedge reset_n) begin
    if (!reset_n) begin
        main_state <= MAIN_IDLE;
        leds <= 8'h00;
        start_read <= 1'b0;
        sector_addr <= 32'h00000000;
    end else begin
        case (main_state)
            MAIN_IDLE: begin
                leds <= 8'h01;  // Power-on LED
                main_state <= MAIN_WAIT_READY;
            end
            
            MAIN_WAIT_READY: begin
                if (sd_ready) begin
                    main_state <= MAIN_START_READ;
                    start_read <= 1'b1;
                    sector_addr <= 32'h00001234; // Test sector
                end
            end
            
            MAIN_START_READ: begin
                start_read <= 1'b0;
                main_state <= MAIN_READING;
            end
            
            MAIN_READING: begin
                if (sd_ready) begin // Read complete
                    main_state <= MAIN_DONE;
                    leds <= 8'hFF;
                end else if (sd_error) begin
                    leds <= 8'hAA; // Error pattern
                    main_state <= MAIN_DONE;
                end
            end
            
            MAIN_DONE: begin
                // Stay in done state
                leds <= 8'hFF;
            end
        endcase
    end
end

endmodule
