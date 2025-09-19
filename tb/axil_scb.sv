`ifndef AXIL_SCB__SV
`define AXIL_SCB__SV

class axil_scoreboard extends uvm_scoreboard;

	axil_transaction      exp_q[$];
	//axil_transaction      act_q[$];

	uvm_blocking_get_port #(axil_transaction)  exp_port;
	uvm_blocking_get_port #(axil_transaction)  act_port;

	`uvm_component_utils(axil_scoreboard)

	extern function new(string name = "axil_scoreboard", uvm_component parent = null);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);

endclass

function axil_scoreboard::new(string name = "axil_scoreboard", uvm_component parent = null);
	super.new(name, parent);
	exp_port = new("exp_port", this);
	act_port = new("act_port", this);
endfunction

function void axil_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task axil_scoreboard::run_phase(uvm_phase phase);
	axil_transaction  exp_tr, act_tr, tmp_tr;
	bit result;

	super.run_phase(phase);
	fork
		while (1) begin
			//receive expected transaction and wait
			exp_port.get(exp_tr);
			exp_q.push_back(exp_tr);
		end
		while (1) begin
			act_port.get(act_tr);
			if(exp_q.size() > 0) begin
				tmp_tr = exp_q.pop_front();
				result = tmp_tr.compare(act_tr);
				if(result) begin
					`uvm_info("axil_scoreboard", "Compare SUCCESS", UVM_LOW);
				end
				else begin
					`uvm_error("axil_scoreboard", "Compare FAILED");
					$display("the expect pkg is:");
					tmp_tr.print();
					$display("the actual pkg is:");
					act_tr.print();
				end
			end
			else begin
				`uvm_error("axil_scoreboard", "Received from DUT, while Expect Queue is empty");
				$display("the unexpected pkg is");
				act_tr.print();
			end
		end
	join
endtask

`endif
