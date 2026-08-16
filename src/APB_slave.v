`timescale 1ns/1ps

// ---------------------
// APB Slave Module
// ---------------------
module APB_slave (
  input clk,
  input reset,
  input PSEL,
  input PENABLE,
  input PWRITE,
  input [15:0] PADDR,
  input [31:0] PWDATA,
  output reg [31:0] PRDATA,
  output reg PREADY,
  output reg PSLVERR
);

  reg [31:0] mem [0:255]; // Simple memory

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      PRDATA <= 0;
      PREADY <= 0;
      PSLVERR <= 0;
    end else begin
      if (PSEL) begin
        PREADY <= 1;
        if (PENABLE) begin
          if (PADDR < 256) begin
            PSLVERR <= 0;
            if (PWRITE)
              mem[PADDR] <= PWDATA;
            else
              PRDATA <= mem[PADDR];
          end else begin
            PSLVERR <= 1;
            PRDATA <= 32'hDEADBEEF;
          end
        end
      end else begin
        PREADY <= 0;
        PSLVERR <= 0;
      end
    end
  end

endmodule
