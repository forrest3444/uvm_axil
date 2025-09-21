`ifndef SMOKE_TEST__SV
`define SMOKE_TEST__SV

class smoke_test extends axil_base_test;
	`uvm_component_utils(smoke_test)

	function new(string name = "smoke_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!env) begin
			`uvm_fatal("NO_ENV", "Environment not created!")
		end

		uvm_config_db #(uvm_object_wrapper)::set(
			this, 
			"env.i_agt.seqr.run_phase", 
			"default_sequence",
			axil_smoke_seq::type_id::get()
		);

	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this, "Main test objection");

		@(posedge env.i_agt.drv.vif.rst_n);
		`uvm_info(get_type_name(), "Default smoke_seq will start automatically", UVM_MEDIUM)
		#50000ns;

		phase.drop_objection(this, "Finish test");

	endtask
endclass

`endif

