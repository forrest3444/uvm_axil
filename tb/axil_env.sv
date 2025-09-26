`ifndef AXIL_ENV__SV
`define AXIL_ENV__SV

class axil_env extends uvm_env;
  `uvm_component_utils(axil_env);

	axil_agent                     i_agt;
	axil_agent                     o_agt;
	axil_reference_model           mdl;
	axil_scoreboard                scb;

	uvm_tlm_analysis_fifo #(axil_transaction) o_agt_scb_fifo;
	uvm_tlm_analysis_fifo #(axil_transaction) i_agt_mdl_fifo;
	uvm_tlm_analysis_fifo #(axil_transaction) mdl_scb_fifo;

	function new(string name = "axil_env", uvm_component parent);
		super.new(name, parent);
		o_agt_scb_fifo = new("o_agt_scb_fifo", this);
		i_agt_mdl_fifo = new("i_agt_mdl_fifo", this);
		mdl_scb_fifo = new("mdl_scb_fifo", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

    i_agt = axil_agent::type_id::create("i_agt", this);
		o_agt = axil_agent::type_id::create("o_agt", this);
		mdl   = axil_reference_model#()::type_id::create("mdl", this);
		scb   = axil_scoreboard::type_id::create("scb", this);

		uvm_config_db #(uvm_active_passive_enum)::set(this, "i_agt", "is_active", UVM_ACTIVE);
		uvm_config_db #(uvm_active_passive_enum)::set(this, "o_agt", "is_active", UVM_PASSIVE);

  endfunction 

	extern virtual function void connect_phase(uvm_phase phase);
	
endclass

function void axil_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	//i_agt to model
	i_agt.mon_ap.connect(i_agt_mdl_fifo.analysis_export);
	mdl.in_port.connect(i_agt_mdl_fifo.blocking_get_export);
	//model to scoreboard
	mdl.out_port.connect(mdl_scb_fifo.analysis_export);
	scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
	//o_agt to scoreboard
	o_agt.mon_ap.connect(o_agt_scb_fifo.analysis_export);
	scb.act_port.connect(o_agt_scb_fifo.blocking_get_export);

endfunction
	
`endif
