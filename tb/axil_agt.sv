`ifndef AXIL_AGENT__SV
`define AXIL_AGENT__SV


class axil_agent extends uvm_agent;
	`uvm_component_utils(axil_agent)

	axil_monitor        mon;
	axil_driver         drv;
	axil_sequencer     seqr;

	virtual axil_if vif;

	uvm_analysis_port #(axil_transaction)   mon_ap;

	function new(string name = "axil_agent", uvm_component parent = null);
		super.new(name, parent);
		mon_ap = new("mon_ap", this);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);

endclass

function void axil_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(virtual axil_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", $sformatf("%s has no vif set", get_full_name()));


	if(is_active == UVM_ACTIVE) begin
		drv = axil_driver::type_id::create("drv", this);
		seqr = axil_sequencer::type_id::create("seqr", this);
	end 

	mon = axil_monitor::type_id::create("mon", this);
	
	if(is_active == UVM_ACTIVE) begin
		uvm_config_db #(virtual axil_if.drv)::set(this, "drv", "vif", vif);
	end

	uvm_config_db #(virtual axil_if.mon)::set(this, "mon", "vif", vif);

endfunction

function void axil_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(seqr.seq_item_export);
	end 
	mon.ap.connect(mon_ap);

endfunction

`endif
