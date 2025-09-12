`ifndef AXIL_AGENT__SV
`define AXIL_AGENT__SV

class axil_agent extends uvm_agent;
	axil_driver         drv;
	axil_monitor        mon;
	axil_sequencer      sqr;

	uvm_analysis_port #(axil_transaction)   mon_ap;

	function new(string name = "axil_agent", uvm_component parent = null);
		super.new(name, parent);
		mon_ap = new("mon_ap", this);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

	`uvm_component_utils(axil_agent)
	  
endclass

function void axil_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv = axil_driver::type_id::create("drv", this);
		sqr = axil_sequencer::type_id::create("sqr", this);
	end 
	mon = axi_monitor::type_id::create("mon", this);
	
endfunction

function void axil_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
	end 
	mon.ap.connect(mon_ap);

endfunction

`endif
