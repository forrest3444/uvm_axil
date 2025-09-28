`ifndef AXIL_SMOKE_SEQ__SV
`define AXIL_SMOKE_SEQ__SV

class axil_smoke_seq extends uvm_sequence #(axil_transaction);
	`uvm_object_utils(axil_smoke_seq)

	axil_transaction   tr;
	
	function new(string name = "axil_smoke_seq");
		super.new(name);
	endfunction

/*==============================================================================
|                   task body----smoke_test 
==============================================================================*/

	virtual task body();
		uvm_phase    phase; 
		phase = get_starting_phase();
		`uvm_info(get_type_name(),
							$sformatf("phase=%p", phase),
						 	UVM_LOW);

		if(phase != null) begin 
			`uvm_info(get_type_name(), "RAISE", UVM_LOW);
			phase.raise_objection(this);
		end

		#100ns;
		for (int i = 0; i < 4; i++) begin
			tr = axil_transaction#()::type_id::create("tr");
      start_item(tr);
			tr.op = WRITE;
			tr.addr = i * 4;
			tr.data = i * 32'h11111111;
			tr.wstrb = 4'hF;
			`uvm_info(get_type_name(),
								$sformatf("Sending WRITE: addr=0x%0h data=0x%0h", tr.addr, tr.data),
							 	UVM_MEDIUM);
			finish_item(tr);
			#10ns;
		end

		for (int i = 0; i < 4; i++) begin
			tr = axil_transaction#()::type_id::create("tr");
      start_item(tr);
			tr.op = READ;
			tr.addr = i * 4;
			tr.wstrb = 0;
			`uvm_info(get_type_name(), $sformatf("Sending READ: addr=0x%0h", tr.addr), UVM_MEDIUM);
			finish_item(tr);
			#10ns;
		end
		#100ns

		if(phase != null) begin
			`uvm_info(get_type_name(), "DROP", UVM_LOW);
			phase.drop_objection(this);
		end

	endtask

endclass

`endif
