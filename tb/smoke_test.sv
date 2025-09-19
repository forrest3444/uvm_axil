`ifndef SMOKE_TEST__SV
`define SMOKE_TEST__SV

class smoke_test extends axil_base_test;

	`uvm_component_utils(smoke_test)

	function new(string name = "axil_smoke_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phas(uvm_phase phase);
	super.build_phase(phase);

	if(!env) begin
		`uvm_fatal("NO_ENV", "Environment not created!")
		end
	endfunction

	virtual task run_phase(uvm_phase phase);

	  axil_smoke_seq  smoke_seq;
		`uvm_info(get_type_name(), "Starting Smoke Test Sequence", UVM_MEDIUM)

		smoke_seq = axil_smoke_seq::type_id::create("smoke_seq");
		smoke_seq.start(env.i_agt.seqr);

		`uvm_info(get_type_name(), "Smoke Test Sequence Finished", UVM_MEDIUM)

	endtask
endclass

`endif

