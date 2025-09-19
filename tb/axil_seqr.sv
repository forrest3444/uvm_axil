`ifndef AXIL_SEQUENCER__SV
`define AXIL_SEQUENCER__SV

class axil_sequencer extends uvm_sequencer #(axil_transaction);

	function new(string name = "axil_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	`uvm_component_utils(axil_sequencer)
endclass

`endif
