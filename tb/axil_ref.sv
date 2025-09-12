`ifndef AXIL_REF__SV
`define AXIL_REF__SV

typedef enum {OKAY, SLVERR, DECERR} axil_resp;

class axil_reference_model #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16
) extends uvm_component;

    localparam STRB_WIDTH       = DATA_WIDTH/8;
    localparam VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
    localparam MAX_ADDR         = (1 << VALID_ADDR_WIDTH) - 1;

    `uvm_component_utils(axil_reference_model)

    // ---- UVM port ----
    uvm_blocking_get_port #(axil_transaction)    in_port;
    uvm_analysis_port     #(axil_transaction)   out_port;

    // ---- register model----
    bit [DATA_WIDTH-1:0] mem [0:MAX_ADDR];
    axil_resp last_write_resp = OKAY;
    axil_resp last_read_resp  = OKAY;

    function new(string name = "axil_reference_model", uvm_component parent = null);
        super.new(name, parent);
        in_port  = new("in_port", this);
        out_port = new("out_port", this);
    endfunction

    // ---- main phase ----
    virtual task run_phase(uvm_phase phase);
        axil_transaction tr, rsp;

        forever begin
            in_port.get(tr);
            rsp = tr.clone();

            if (tr.op == WRITE) begin
                write(tr.addr, tr.data, tr.wstrb);
                rsp.resp = last_write_resp;
            end
            else begin
                rsp.data = read(tr.addr);
                rsp.resp = last_read_resp;
            end

            out_port.write(rsp);
        end
    endtask

    // ----write operation ----
    function void write(bit [ADDR_WIDTH-1:0] addr,
                        bit [DATA_WIDTH-1:0] wdata,
                        bit [STRB_WIDTH-1:0] wstrb);
        int unsigned aligned_addr;
        bit [DATA_WIDTH-1:0] current_data;

        aligned_addr = addr[ADDR_WIDTH-1 : $clog2(STRB_WIDTH)];

        if (aligned_addr > MAX_ADDR) begin
            last_write_resp = DECERR; // DECERR
            `uvm_warning("REF_MODEL", $sformatf("Write to invalid addr: 0x%0h", addr))
            return;
        end

        last_write_resp = OKAY;
        current_data = mem[aligned_addr];

        for (int i = 0; i < STRB_WIDTH; i++) begin
            if (wstrb[i])
                current_data[8*i +: 8] = wdata[8*i +: 8];
        end

        mem[aligned_addr] = current_data;

        `uvm_info("REF_MODEL", $sformatf("WRITE @0x%0h: data=0x%0h strb=0x%0h -> mem=0x%0h",
                  addr, wdata, wstrb, current_data), UVM_MEDIUM)
    endfunction

    // ---- read operation ----
    function bit [DATA_WIDTH-1:0] read(bit [ADDR_WIDTH-1:0] addr);
        int unsigned aligned_addr;

        aligned_addr = addr[ADDR_WIDTH-1 : $clog2(STRB_WIDTH)];

        if (aligned_addr > MAX_ADDR) begin
            last_read_resp = DECERR; // DECERR
            `uvm_warning("REF_MODEL", $sformatf("Read from invalid addr: 0x%0h", addr))
            return {DATA_WIDTH{1'b0}};
        end

        last_read_resp = OKAY;
        return mem[aligned_addr];
    endfunction

    // ---- 工具函数 ----
    function void clear();
        foreach (mem[i]) mem[i] = {DATA_WIDTH{1'b0}};
        last_write_resp = OKAY;
        last_read_resp  = OKAY;
    endfunction

    function void dump(int start_addr = 0, int num = 10);
        for (int i = 0; i < num; i++) begin
            int unsigned addr = start_addr + i;
            if (addr <= MAX_ADDR)
                `uvm_info("REF_MODEL", $sformatf("Addr 0x%0h: 0x%0h", addr, mem[addr]), UVM_LOW)
        end
    endfunction

endclass

`endif

