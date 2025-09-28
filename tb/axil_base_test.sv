`ifndef BASE_TEST__SV
`define BASE_TEST__SV

class axil_base_test extends uvm_test;
	`uvm_component_utils(axil_base_test)
	
  axil_env       env;

	function new(string name = "axil_base_test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

/*==============================================================================
|                   build phase 
==============================================================================*/

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = axil_env::type_id::create("env", this);
		uvm_top.set_timeout(100000ns,0);
	endfunction

/*==============================================================================
|                   report phase 
==============================================================================*/

	virtual function void report_phase(uvm_phase phase);
		uvm_report_server server;
		int err_num;
		super.report_phase(phase);

		server = get_report_server();
		err_num = server.get_severity_count(UVM_ERROR);

		if(err_num != 0) begin
			$display("TEST CASE FAILED!!");
		end
		else begin
			$display("TEST CASE PASSED");
		end
	endfunction

endclass

`endif

