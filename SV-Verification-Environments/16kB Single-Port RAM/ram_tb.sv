`include "ram_interface.sv"
`include "uvm_macros.svh"
`include "ram_write_read_test.sv"
import uvm_pkg::*;

module ram_tb;

  logic clk;
  logic rstn;

  ram_intf vif(clk);

  ram DUT (
    .clk(vif.clk),
    .rstn(vif.rstn),
    .we(vif.we),
    .addr(vif.addr),
    .wdata(vif.wdata),
    .rdata(vif.rdata)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end
  
  initial begin
    uvm_config_db#(virtual ram_intf)::set(uvm_top, "uvm_test_top", "vif", vif);
    run_test("ram_write_read_test");
  end

endmodule