`timescale 1ns/1ps

module tb_apb;

  reg clk = 0, reset = 0, write;
  reg [15:0] addr;
  reg [31:0] data;
  wire [31:0] prdata;
  wire pready, pslverr;
  reg [2:0] ready;
  wire ss_write, enable;
  wire [2:0] out_select;
  wire [15:0] out_addr;
  wire [31:0] write_data, out_read;

  // Clock generation
  always #5 clk = ~clk;

  // Instantiate Master
  APB_master master (
    .clk(clk),
    .reset(reset),
    .addr(addr),
    .data(data),
    .read(prdata),
    .ready(ready),
    .write(write),
    .ss_write(ss_write),
    .enable(enable),
    .out_select(out_select),
    .out_addr(out_addr),
    .write_data(write_data),
    .out_read(out_read)
  );

  // Instantiate Slave
  APB_slave slave (
    .clk(clk),
    .reset(reset),
    .PSEL(ss_write),
    .PENABLE(enable),
    .PWRITE(write),
    .PADDR(addr),
    .PWDATA(data),
    .PRDATA(prdata),
    .PREADY(pready),
    .PSLVERR(pslverr)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_apb);

    $display("Starting simulation...");

    reset = 1;
    ready = 3'b111;

    #10 reset = 0;

    // Write to slave
    addr = 16'h000A;
    data = 32'h12345678;
    write = 1;
    #20;

    // Read from slave
    write = 0;
    #20;

    $display("Read Data: %h", prdata);
    $display("PSLVERR: %b", pslverr);

    // Invalid address test
    addr = 16'h00FF;
    write = 0;
    #20;

    $display("Read from invalid address: %h", prdata);
    $display("PSLVERR: %b", pslverr);

    $display("Simulation finished.");
    $finish;
  end

endmodule
