`ifndef AXIL_SMOKE_SEQ__SV
`define AXIL_SMOKE_SEQ__SV

class axil_smoke_seq extends uvm_sequence #(axil_transaction);
	`uvm_object_utils(axil_smoke_seq)

	axil_transaction   tr;
	
	function new(string name = "axil_smoke_seq");
		super.new(name);
	endfunction

	virtual task body();

		if(starting_phase != null)
			starting_phase.raise_objection(this);

			for (int i = 0; i < 4; i++) begin
				tr = axil_transaction#()::type_id::create("tr");
				tr.op = WRITE;
				tr.addr = i * 4;
				tr.data = i * 32'h11111111;
				tr.wstrb = 4'hF;

				`uvm_info(get_type_name(), $sformatf("Sending WRITE: addr=0x%0h data=0x%0h", tr.addr, tr.data), UVM_MEDIUM)
				start_item(tr);
				finish_item(tr);
			end

			for (int i = 0; i < 4; i++) begin
				tr = axil_transaction#()::type_id::create("tr");
				tr.op = READ;
				tr.addr = i * 4;
				tr.wstrb = 0;

				`uvm_info(get_type_name(), $sformatf("Sending READ: addr=0x%0h", tr.addr), UVM_MEDIUM);
				start_item(tr);
				finish_item(tr);
			end

			if(starting_phase != null)
				starting_phase.drop_objection(this);

	endtask

endclass

`endif
