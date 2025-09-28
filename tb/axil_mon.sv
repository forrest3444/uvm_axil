`ifndef AXIL_MONITOR__SV
`define AXIL_MONITOR__SV

class axil_monitor extends uvm_monitor;

	virtual axil_if vif;
	
	//broadcast port
	uvm_analysis_port #(axil_transaction) ap;

	`uvm_component_utils(axil_monitor);

	function new(string name = "axil_monitor", uvm_component parent = null);
		super.new(name, parent);
		ap = new("ap", this);
	endfunction

/*==============================================================================
|                   build phase 
==============================================================================*/

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual axil_if)::get(this, "", "vif", vif))
			`uvm_fatal("axil_monitor", "virtual interface must be set for vif!!!")
	endfunction

/*==============================================================================
|                    run phase
==============================================================================*/

	virtual task run_phase(uvm_phase phase);
		fork
			collect_write();
			collect_read();
		join
	endtask

	extern virtual task collect_write();
	extern virtual task collect_read();
	extern virtual task wait_for_reset_release();

endclass	

endtask

task axil_monitor::wait_for_reset_release();
	if(!vif.rst_n) @(posedge vif.rst_n);
	`uvm_info(get_type_name(), "Reset released, starting monitoring", UVM_MEDIUM);
endtask

task axil_monitor::collect_write();
	axil_transaction rd_tr, wr_tr;
	bit aw_got, w_got;
	logic [31:0] awaddr_q;
	logic [31:0] wdata_q;
	logic [3:0]  wstrb_q;

	wait_for_reset_release();

	forever begin
		// 同时监听 AW、W 握手与复位断言
		@(
			vif.mon_cb or negedge vif.rst_n
		);

		if (!vif.rst_n) begin
			// 复位期间清空本地状态，等待复位释放
			aw_got = 0; w_got = 0;
			wait_for_reset_release();
			continue;
		end

		// 捕获 AW
		if (vif.mon_cb.awvalid && vif.mon_cb.awready) begin
			awaddr_q = vif.mon_cb.awaddr;
			aw_got   = 1;
		end

		// 捕获 W
		if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
			wdata_q = vif.mon_cb.wdata;
			wstrb_q = vif.mon_cb.wstrb;
			w_got   = 1;
		end

		// 当 AW 与 W 都齐了，等待 B
		if (aw_got && w_got) begin
			// 等待 B 握手或复位
			do begin
				@(
					vif.mon_cb or negedge vif.rst_n
				);
				if (!vif.rst_n) begin
					aw_got = 0; w_got = 0;
					wait_for_reset_release();
					break;
				end
			end while (!(vif.mon_cb.bvalid && vif.mon_cb.bready));

			if (vif.rst_n && (vif.mon_cb.bvalid && vif.mon_cb.bready)) begin
				wr_tr = axil_transaction#()::type_id::create("wr_tr", this);
				wr_tr.op   = WRITE;
				wr_tr.addr = awaddr_q;
				wr_tr.data = wdata_q;
				wr_tr.wstrb = wstrb_q;
				wr_tr.resp = axil_resp'(vif.mon_cb.bresp);

				`uvm_info(get_type_name(),
					$sformatf("Monitor WRITE: %s", wr_tr.sprint()),
					UVM_MEDIUM)

				ap.write(wr_tr);
			end

			// 准备下一笔
			aw_got = 0; w_got = 0;
		end
	end
endtask

// 读事务：AR -> R（R 不会在 AR 之前完成）
task axil_monitor::collect_read();

	axil_transaction rd_tr;

	wait_for_reset_release();

	forever begin
		// 等待 AR 或复位
		@(
			vif.mon_cb or negedge vif.rst_n
		);

		if (!vif.rst_n) begin
			wait_for_reset_release();
			continue;
		end

		if (vif.mon_cb.arvalid && vif.mon_cb.arready) begin
			logic [31:0] araddr_q = vif.mon_cb.araddr;

			// 等待 R 握手或复位
			do begin
				@(
					vif.mon_cb or negedge vif.rst_n
				);
				if (!vif.rst_n) begin
					wait_for_reset_release();
					break;
				end
			end while (!(vif.mon_cb.rvalid && vif.mon_cb.rready));

			if (vif.rst_n && (vif.mon_cb.rvalid && vif.mon_cb.rready)) begin
				rd_tr = axil_transaction#()::type_id::create("rd_tr", this);
				rd_tr.op   = READ;
				rd_tr.addr = araddr_q;
				rd_tr.data = vif.mon_cb.rdata;
				rd_tr.resp = axil_resp'(vif.mon_cb.rresp);

				`uvm_info(get_type_name(),
					$sformatf("Monitor READ : %s", rd_tr.sprint()),
					UVM_MEDIUM)

				ap.write(rd_tr);
			end
		end
	end
endtask

`endif
