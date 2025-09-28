`ifndef AXIL_IF__SV
`define AXIL_IF__SV

interface axil_if #(
	parameter DATA_WIDTH=32,
 	          ADDR_WIDTH=16
)(
	input clk,
	input rst_n
);

	//write address channel
	logic [ADDR_WIDTH-1:0]     awaddr;
	logic                      awvalid;
	logic                      awready;

	//write data channel
	logic [DATA_WIDTH-1    :0] wdata;
	logic [(DATA_WIDTH/8)-1:0] wstrb;
	logic                      wvalid;
	logic                      wready;

	//write response channel
	logic [1:0]                bresp;
	logic                      bvalid;
	logic                      bready;

	//read address channel
	logic [ADDR_WIDTH-1:0]     araddr;
	logic                      arvalid;
	logic                      arready;

	//read data channel
	logic [DATA_WIDTH-1:0]     rdata;
	logic [1:0]                rresp;
	logic                      rvalid;
	logic                      rready;

	clocking master_cb @(posedge clk);
		default input #1step output #0;
		//write address channel
		input awready;
		output awvalid, awaddr;
		//write data channel
		input wready;
		output wdata, wstrb, wvalid;
		//write response channel
		input bresp, bvalid;
		output bready;
		//read address channel
		input  arready;
		output arvalid, araddr;
		//read data channel
		input  rdata, rresp, rvalid;
		output rready;
	endclocking

	clocking mon_cb @(posedge clk);
		default input #1step output #0;
		// Write address
		input awaddr, awvalid, awready;
		// Write data
		input wdata, wstrb, wvalid, wready;
		// Write response
		input bresp, bvalid, bready;
		// Read address
		input araddr, arvalid, arready;
		// Read data
		input rdata, rresp, rvalid, rready;
	endclocking

	modport drv (
		clocking master_cb,
	  input clk, rst_n
		);
	
	modport mon (
		clocking mon_cb,
		input clk, rst_n
		);
	
	modport dut (
		input clk, rst_n,
		//write address channel
		input awvalid, awaddr,
		output awready,
		//write data channel
		input wdata, wstrb, wvalid,
		output wready,
		//write response channel
		input bready,
		output bresp, bvalid,
		//read address channel
		input arvalid, araddr,
		output arready,
		//read data channel
		input rready,
		output rvalid, rresp, rdata
		);

	endinterface
	`endif
