`ifndef AXIL_TRANSACTION__SV
`define AXIL_TRANSACTION__SV

typedef enum {READ, WRITE}  axil_op;
typedef enum {OKAY, SLVERR} axi_resp;

class axil_transaction extends uvm_sequence_item #(int ADDR_WIDTH=32, int DATA_WIDTH=32);
	rand bit [ADDR_WIDTH-1:0]      addr;
	rand bit [DATA_WIDTH-1:0]      data;
	rand bit [(DATA_WIDTH/8)-1:0]  strb;
	rand axil_op                     op;
	     axil_resp                 resp = OKAY;

  //factory register
	`uvm_object_param_utils_begin(axil_transaction #(ADDR_WIDTH, DATA_WIDTH))
	  `uvm_field_enum(axil_op, op, UVM_DEFAULT)
		`uvm_field_enum(axil_resp, resp, UVM_DEFAULT | UVM_NOPRINT)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_int(strb, UVM_DEFAULT)
	`uvm_object_utils_end

	 //constraint
	constraint valid_strb {
	 if (op == WRITE)	strb != 0;
	 else strb == 0;
 }
	constraint align_addr { addr % (DATA_WIDTH/8) == 0; }

	function new(string name = "axil_transaction");
		super.new(name);
	endfunction

	function string convert2string();
		string s;
		if (op == WRITE)
			$sformat(s, "WRITE addr=0x%08h data=0x%08h strb=0x%1h resp=%s",
		           addr, data, strb, (resp==OKAY)?"OKAY":"SLAVERR");
		else
			$sformat(s, "READ  addr=0x%08h data=0x%08h resp=%s",
		           addr, data, (resp==OKAY)?"OKAY":"SLAVERR");
		return s;
	endfunction

endclass

`endif
