`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axil_if.sv"
`include "axil_tr.sv"
`include "axil_mon.sv"
`include "axil_drv.sv"
`include "axil_seqr.sv"
`include "axil_agt.sv"
`include "axil_scb.sv"
`include "axil_ref.sv"
`include "axil_env.sv"
`include "axil_smoke_seq.sv"
`include "axil_base_test.sv"
`include "smoke_test.sv"


module top_tb;

logic clk;
logic rst_n;

axil_if #(32, 16)  axil_if0(
	.clk(clk),
	.rst_n(rst_n)
);

virtual axil_if #(32,16) vif;

initial begin 
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	rst_n = 0;
	repeat (10) @(posedge clk);
	rst_n = 1;
end

axil_ram #(32, 16)  ram(
	.clk(clk),
	.rst (~rst_n),
  //write address
	.s_axil_awaddr (axil_if0.awaddr),
	.s_axil_awprot  (3'b000),
	.s_axil_awvalid(axil_if0.awvalid),
	.s_axil_awready(axil_if0.awready),
  //write data
	.s_axil_wdata  (axil_if0.wdata),
	.s_axil_wstrb  (axil_if0.wstrb),
	.s_axil_wvalid (axil_if0.wvalid),
	.s_axil_wready (axil_if0.wready),
  //write response 
	.s_axil_bresp  (axil_if0.bresp),
	.s_axil_bvalid (axil_if0.bvalid),
	.s_axil_bready (axil_if0.bready),
  //read  address
	.s_axil_araddr (axil_if0.araddr),
	.s_axil_arprot (3'b000),
	.s_axil_arvalid(axil_if0.arvalid),
	.s_axil_arready(axil_if0.arready),
  //read data
	.s_axil_rdata  (axil_if0.rdata),
	.s_axil_rresp  (axil_if0.rresp),
	.s_axil_rvalid (axil_if0.rvalid),
	.s_axil_rready (axil_if0.rready)
);
	

initial begin
	vif = axil_if0;
	uvm_config_db #(virtual axil_if #(32,16))::set(null, "uvm_test_top.env", "vif", vif);
  run_test("smoke_test");
end

endmodule





