`ifndef SMOKE_TEST__SV
`define SMOKE_TEST__SV

class smoke_test extends axil_base_test;
	`uvm_component_utils(smoke_test)

	function new(string name = "smoke_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

/*==============================================================================
|                   build phase 
==============================================================================*/

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db #(uvm_object_wrapper)::set(
			this,
			"env.i_agt.seqr.run_phase",
			"default_sequence",
			axil_smoke_seq::type_id::get()
		);
	endfunction

/*==============================================================================
|                   run phase 
==============================================================================*/

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		super.run_phase(phase);
		phase.drop_objection(this);
	endtask

endclass

`endif

