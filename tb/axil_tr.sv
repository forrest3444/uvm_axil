`ifndef AXIL_TRANSACTION__SV
`define AXIL_TRANSACTION__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum {READ, WRITE}  axil_op;
typedef enum {OKAY, SLVERR, DECERR} axil_resp;

class axil_transaction #(
	parameter DATA_WIDTH=32,
  parameter ADDR_WIDTH=16
) extends uvm_sequence_item;

/*==============================================================================
|                   signals defination 
==============================================================================*/

	rand bit [ADDR_WIDTH-1:0]      addr;
	rand bit [DATA_WIDTH-1:0]      data;
	rand bit [(DATA_WIDTH/8)-1:0]  wstrb;
	rand axil_op                     op;
	     axil_resp                 resp = OKAY;

/*==============================================================================
|                   factory registration 
==============================================================================*/
			 
	`uvm_object_param_utils_begin(axil_transaction #(DATA_WIDTH, ADDR_WIDTH))
	  `uvm_field_enum(axil_op, op, UVM_DEFAULT)
		`uvm_field_enum(axil_resp, resp, UVM_DEFAULT | UVM_NOPRINT)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_int(wstrb, UVM_DEFAULT)
	`uvm_object_utils_end

/*==============================================================================
|                   constraints 
==============================================================================*/

	constraint valid_wstrb {
	 if (op == WRITE)	wstrb != 0;
	 else wstrb == 0;
 }

	function new(string name = "axil_transaction");
		super.new(name);
	endfunction

/*==============================================================================
|                   print function 
==============================================================================*/

	function string convert2string();
		string s, s1;
    case (resp)
      OKAY:   s = "OKAY";
      SLVERR: s = "SLVERR";
      DECERR: s = "DECERR";
    endcase
		if (op == WRITE)
			s1 = $sformatf("WRITE addr=0x%08h data=0x%08h wstrb=0x%1h resp=%s",
		           addr, data, wstrb, s);
		else
			s1 = $sformatf("READ  addr=0x%08h data=0x%08h resp=%s",
		           addr, data, s);
		return s1;
	endfunction

endclass

`endif
