#	=======================
#	User	configuration
#	=======================

#	仿真器选择：vcs/questa/xrun
SIM					=	vcs

#	顶层模块
TOP					=	top_tb

FLIST				=	flist.f
#	仿真输出目录
OUT_DIR			=	build

#	DUT	源文件
DUT_SRCS	=	\
				dut/axil_ram.v

#	UVM	相关参数
UVM_HOME	?=	$(shell	echo	$$UVM_HOME)			#	如果没设置，就用环境变量
UVM_FLAGS	=	+incdir+$(UVM_HOME)/src	\
												$(UVM_HOME)/src/uvm_pkg.sv

#	编译选项
VCS_FLAGS	=	-sverilog	-full64	-timescale=1ns/1ps	\
						-debug_access+r+w+nomemcbk	-debug_region+cell	\
						-CFLAGS	"-I$(PWD)/debug"	\
						-LDFLAGS	"$(PWD)/debug/pthread_yield_shim.o"	\
						-ntb_opts	uvm-1.2	\
						-kdb -debug_access+all -fsdb

#	运行选项
RUN_FLAGS	=	+UVM_TESTNAME=smoke_test	\
						#+UVM_PHASE_TRACE	\
						+UVM_OBJECTION_TRACE
						#+UVM_VERBOSITY=UVM_DEBUG


#	=======================
#	Targets
#	=======================

all:	compile	run

compile:
	@mkdir	-p	$(OUT_DIR)
	$(SIM)	$(VCS_FLAGS)	\
					-o	$(OUT_DIR)/simv	\
					$(UVM_FLAGS)	\
					$(DUT_SRCS)		\
					-f	$(FLIST)	\
					-top	$(TOP)	\
					-l	$(OUT_DIR)/compile.log

run:
	$(OUT_DIR)/simv	$(RUN_FLAGS)	-l	$(OUT_DIR)/sim.log

clean:
	rm	-rf	$(OUT_DIR)	csrc	ucli.key	simv*	*.daidir	*.vpd	*.log

help:
	@echo	"make	[all]					#	编译并运行"
	@echo	"make	compile			#	只编译"
	@echo	"make	run							#	只运行"
	@echo	"make	clean					#	清理"


