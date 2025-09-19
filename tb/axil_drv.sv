`ifndef AXIL_DRIVER__SV
`define AXIL_DRIVER__SV

class axil_driver extends uvm_driver#(axil_transaction);

	virtual axil_if.drv vif;

	`uvm_component_utils(axil_driver)

	function new(string name = "axil_driver", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info("axil_driver", "new is called", UVM_LOW);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
	extern virtual task drive_one_pkg(axil_transaction tr);
	extern virtual task reset_signals();

endclass

function void axil_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual axil_if.drv)::get(this, "", "vif",vif))
		`uvm_fatal("axil_driver", "virtual interface must be set for axil_if!!!")
endfunction

task axil_driver::reset_signals();
    // Drive all signals to idle state
    vif.master_cb.awaddr  <= '0;
    vif.master_cb.awvalid <= '0;
    vif.master_cb.wdata   <= '0;
    vif.master_cb.wstrb   <= '0;
    vif.master_cb.wvalid  <= '0;
    vif.master_cb.bready  <= '0;
    vif.master_cb.araddr  <= '0;
    vif.master_cb.arvalid <= '0;
    vif.master_cb.rready  <= '0;
		repeat (2) @(vif.master_cb);
endtask

task axil_driver::drive_one_pkg(axil_transaction tr);
	if (tr.op == WRITE) begin
		//write operation: AW->W->B
		//drive write address and awvalid
		vif.master_cb.awaddr <= tr.addr;
		vif.master_cb.awvalid <= 1'b1;

		//wait slave address ready
		@(vif.master_cb iff vif.master_cb.awready);
		@(vif.master_cb);
		vif.master_cb.awvalid <= 1'b0;//write address channel handshake done

		//drive write data and strb,valid
		vif.master_cb.wdata <= tr.data;
		vif.master_cb.wstrb <= tr.wstrb;
		vif.master_cb.wvalid <= 1'b1;

		//wait slave wready
		@(vif.master_cb iff vif.master_cb.wready);
		@(vif.master_cb);
		vif.master_cb.wvalid <= 1'b0;//write data channel handshake done

		vif.master_cb.bready <= 1'b1;
		@(vif.master_cb iff vif.master_cb.bvalid);
		tr.resp = axil_resp'(vif.master_cb.bresp);
		@(vif.master_cb);
		vif.master_cb.bready <= 1'b0;
	end
	else begin
		//read operation: AR->R
		//drive raddr and rvalid
		vif.master_cb.araddr <= tr.addr;
		vif.master_cb.arvalid <= 1'b1;

		//wait slave arready
		@(vif.master_cb iff vif.master_cb.arready);
		@(vif.master_cb);
		vif.master_cb.arvalid <= 1'b0;//read address channel handshake done

		//wait read data and response
		vif.master_cb.rready <= 1'b1;
		@(vif.master_cb iff vif.master_cb.rvalid);
		tr.data = vif.master_cb.rdata;
		tr.resp = axil_resp'(vif.master_cb.rresp);
		@(vif.master_cb);
		vif.master_cb.rready <= 1'b0;
	end

endtask

task axil_driver::run_phase(uvm_phase phase);
	axil_transaction tr;

	//initial
	reset_signals();
	@(posedge vif.rst_n);

	forever begin
		if(!vif.rst_n) begin
			reset_signals();
			@(posedge vif.rst_n);
		end
		//get next transaction from sequencer
		seq_item_port.get_next_item(tr);
		`uvm_info(get_type_name(), $sformatf("Driving transaction: %s", tr.sprint()), UVM_MEDIUM);
		//drive one package
		drive_one_pkg(tr);
		seq_item_port.item_done();
	end
endtask

`endif


