transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/controller.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/alu_controller.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/inst_decode.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/immGen.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/rename.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/processor.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/inst_fetch.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/rs.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/alu.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/ram.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/regFile.sv}
vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/rob.sv}


vlog -sv -work work +incdir+C:/Users/tim/Documents/Quartus/M116C/inst_fetch {C:/Users/tim/Documents/Quartus/M116C/inst_fetch/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
