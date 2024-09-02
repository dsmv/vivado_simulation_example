#vivado -source g_run.tcl -tclargs no_close_sim
#vivado -source g_run.tcl 
xsim -gui tb_behav  -tclbatch g_run.tcl
