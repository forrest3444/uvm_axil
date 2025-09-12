`ifndef AXIL_TRANSACTION__SV
`define AXIL_TRANSACTION__SV

typedef enum {READ, WRITE}  axil_op;
typedef enum {OKAY, SLVERR, DECERR} axi_resp;

class axil_transaction #(int ADDR_WIDTH=16, int DATA_WIDTH=32) extends uvm_sequence_item;
	rand bit [ADDR_WIDTH-1:0]      addr;
	rand bit [DATA_WIDTH-1:0]      data;
	rand bit [(DATA_WIDTH/8)-1:0]  wstrb;
	rand axil_op                     op;
	     axil_resp                 resp = OKAY;

  //--------------------factory registration
	`uvm_object_param_utils_begin(axil_transaction #(ADDR_WIDTH, DATA_WIDTH))
	  `uvm_field_enum(axil_op, op, UVM_DEFAULT)
		`uvm_field_enum(axil_resp, resp, UVM_DEFAULT | UVM_NOPRINT)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_int(wstrb, UVM_DEFAULT)
	`uvm_object_utils_end

	 //-------------------constraint
	constraint valid_wstrb {
	 if (op == WRITE)	wstrb != 0;
	 else wstrb == 0;
 }
	constraint align_addr { addr % (DATA_WIDTH/8) == 0; }

	function new(string name = "axil_transaction");
		super.new(name);
	endfunction

	function string convert2string();
		string s;
    case (resp)
      OKAY:   s = "OKAY";
      SLVERR: s = "SLVERR";
      DECERR: s = "DECERR";
    endcase
		if (op == WRITE)
			$sformat(s, "WRITE addr=0x%08h data=0x%08h wstrb=0x%1h resp=%s",
		           addr, data, wstrb, s);
		else
			$sformat(s, "READ  addr=0x%08h data=0x%08h resp=%s",
		           addr, data, s);
		return s;
	endfunction

	virtual function void do_copy(uvm_object rhs);
		axil_transaction tr;
		if(!$cast(tr, rhs)) begin
			`uvm_fatal("COPY_ERR", "do_copy: rhs is not axil_transaction")
		end

		this.addr = tr.addr;
		this.data = tr.data;
		this.wstrb = tr.wstrb;
		this.op = tr.op;
		this.resp = tr.resp;
	endfunction

endclass

`endif
