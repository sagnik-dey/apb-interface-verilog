`timescale 1ns/1ps

// ---------------------
// APB Master Module
// ---------------------
module APB_master (
  input clk,
  input reset,
  input [15:0] addr,
  input [31:0] data,
  input [31:0] read,
  input [2:0] ready,
  input write,
  output reg ss_write,
  output reg enable,
  output reg [2:0] out_select,
  output reg [15:0] out_addr,
  output reg [31:0] write_data,
  output reg [31:0] out_read
);

  parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;
  reg [1:0] pres_state, next_state;
  reg select;
  reg [2:0] ss1 = 3'b001, ss2 = 3'b010, ss3 = 3'b100;

  parameter ss1min = 16'h0000, ss1max = 16'h003C;
  parameter ss2min = 16'h003D, ss2max = 16'h0078;
  parameter ss3min = 16'h0079, ss3max = 16'h008C;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pres_state <= s0;
      enable <= 0;
      out_select <= 0;
      out_addr <= 0;
      write_data <= 0;
      ss_write <= 0;
      out_read <= 0;
    end else begin
      ss_write <= write;

      if (addr >= ss1min && addr <= ss1max) begin
        out_select <= ss1;
        select <= 1;
      end else if (addr >= ss2min && addr <= ss2max) begin
        out_select <= ss2;
        select <= 1;
      end else if (addr >= ss3min && addr <= ss3max) begin
        out_select <= ss3;
        select <= 1;
      end else begin
        select <= 0;
      end

      case (pres_state)
        s0: begin
          if (select)
            next_state <= s1;
          else
            next_state <= s0;
        end

        s1: begin
          enable <= 1;
          out_addr <= addr;
          write_data <= data;
          next_state <= s2;
        end

        s2: begin
          if (ready != 0) begin
            out_read <= read;
            enable <= 0;
            next_state <= s0;
          end else begin
            next_state <= s2;
          end
        end
      endcase

      pres_state <= next_state;
    end
  end
endmodule
