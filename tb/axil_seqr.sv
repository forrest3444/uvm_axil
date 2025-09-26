`ifndef AXIL_SEQUENCER__SV
`define AXIL_SEQUENCER__SV

class axil_sequencer extends uvm_sequencer #(axil_transaction);
	`uvm_component_utils(axil_sequencer)

	function new(string name = "axil_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void start_of_simulation_phase(uvm_phase phase);
		uvm_object_wrapper  wrapper;
		if(!uvm_config_db #(uvm_object_wrapper)::get(this, "run_phase", "default_sequence", wrapper)) 
			`uvm_fatal("SEQR","Failed to get default_sequence");
	endfunction


endclass

`endif
