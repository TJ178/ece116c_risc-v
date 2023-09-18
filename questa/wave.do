onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/pc
add wave -noupdate /testbench/cpu/rn/free
add wave -noupdate /testbench/cpu/reservationStation/resStation
add wave -noupdate -radix binary /testbench/cpu/reservationStation/FUStatus
add wave -noupdate -radix binary /testbench/cpu/reservationStation/readyReg
add wave -noupdate -expand -group alu1 -radix unsigned /testbench/cpu/alu1/en
add wave -noupdate -expand -group alu1 -radix unsigned /testbench/cpu/rr_alusrc1
add wave -noupdate -expand -group alu1 -radix unsigned /testbench/cpu/alu1_d1
add wave -noupdate -expand -group alu1 -radix unsigned /testbench/cpu/alu1_d2
add wave -noupdate -expand -group alu1 -radix unsigned /testbench/cpu/alu1_out
add wave -noupdate -expand -group alu2 -radix unsigned /testbench/cpu/alu2/en
add wave -noupdate -expand -group alu2 -radix unsigned /testbench/cpu/rr_alusrc2
add wave -noupdate -expand -group alu2 -radix unsigned /testbench/cpu/alu2_d1
add wave -noupdate -expand -group alu2 -radix unsigned /testbench/cpu/alu2_d2
add wave -noupdate -expand -group alu2 -radix unsigned /testbench/cpu/alu2_out
add wave -noupdate /testbench/cpu/r_mem_out
add wave -noupdate -radix unsigned /testbench/cpu/regFw1
add wave -noupdate -radix unsigned /testbench/cpu/regFw2
add wave -noupdate -radix unsigned /testbench/cpu/regFw3
add wave -noupdate -radix unsigned /testbench/cpu/regFWData1
add wave -noupdate -radix unsigned /testbench/cpu/regFWData2
add wave -noupdate -radix unsigned /testbench/cpu/regFWData3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 280
configure wave -valuecolwidth 254
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {29 ps}
