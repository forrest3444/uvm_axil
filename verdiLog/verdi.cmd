debImport "-full64"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 {/home/wwh/github/uvm_axil/top_tb.fsdb}
wvSelectGroup -win $_nWave2 {G1}
wvSelectGroup -win $_nWave2 {G1}
nsMsgSwitchTab -tab general
debImport "/home/wwh/github/uvm_axil/dut/axil_ram.v" "-sv" -path \
          {/home/wwh/github/uvm_axil}
debImport "/home/wwh/github/uvm_axil/dut/axil_ram.v" \
          "/home/wwh/github/uvm_axil/tb/axil_agt.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_base_test.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_drv.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_env.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_if.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_mon.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_ref.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_scb.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_seqr.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_smoke_seq.sv" \
          "/home/wwh/github/uvm_axil/tb/axil_tr.sv" \
          "/home/wwh/github/uvm_axil/tb/smoke_test.sv" \
          "/home/wwh/github/uvm_axil/tb/top_tb.sv" "-sv" -path \
          {/home/wwh/github/uvm_axil}
nsMsgSwitchTab -tab general
nsMsgSwitchTab -tab trace
nsMsgSwitchTab -tab search
nsMsgSwitchTab -tab intercon
nsMsgSwitchTab -tab cmpl
srcHBSelect "top_tb.axil_if0" -win $_nTrace1
srcSetScope -win $_nTrace1 "top_tb.axil_if0" -delim "."
srcHBSelect "top_tb.axil_if0" -win $_nTrace1
srcHBSelect "top_tb.ram" -win $_nTrace1
srcHBSelect "top_tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "top_tb" -delim "."
srcHBSelect "top_tb" -win $_nTrace1
nsMsgSwitchTab -tab general
nsMsgSwitchTab -tab trace
verdiDockWidgetSetCurTab -dock windowDock_OneSearch
verdiDockWidgetSetCurTab -dock widgetDock_<Message>
wvCreateWindow
debExit
