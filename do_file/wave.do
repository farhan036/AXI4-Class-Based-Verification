onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/axi_vif/ACLK
add wave -noupdate -expand -group WRT_ADDR -color Firebrick /top/axi_vif/ARESETn
add wave -noupdate -expand -group WRT_ADDR -color {Spring Green} -radix unsigned /top/axi_vif/AWADDR
add wave -noupdate -expand -group WRT_ADDR -color {Spring Green} -radix unsigned /top/axi_vif/AWLEN
add wave -noupdate -expand -group WRT_ADDR -color {Spring Green} /top/axi_vif/AWSIZE
add wave -noupdate -expand -group WRT_ADDR -color {Spring Green} /top/axi_vif/AWVALID
add wave -noupdate -expand -group WRT_ADDR -color {Spring Green} /top/axi_vif/AWREADY
add wave -noupdate -expand -group WRT_DATA -color {Sky Blue} /top/axi_vif/WDATA
add wave -noupdate -expand -group WRT_DATA -color {Sky Blue} /top/axi_vif/WVALID
add wave -noupdate -expand -group WRT_DATA -color {Sky Blue} /top/axi_vif/WLAST
add wave -noupdate -expand -group WRT_DATA -color {Sky Blue} /top/axi_vif/WREADY
add wave -noupdate -expand -group WRT_RESP -color Orange /top/axi_vif/BRESP
add wave -noupdate -expand -group WRT_RESP -color Orange /top/axi_vif/BVALID
add wave -noupdate -expand -group WRT_RESP -color Orange /top/axi_vif/BREADY
add wave -noupdate -expand -group READ_ADDR -color Yellow -radix decimal /top/axi_vif/ARADDR
add wave -noupdate -expand -group READ_ADDR -color Yellow /top/axi_vif/ARLEN
add wave -noupdate -expand -group READ_ADDR -color Yellow /top/axi_vif/ARSIZE
add wave -noupdate -expand -group READ_ADDR -color Green /top/axi_vif/ARVALID
add wave -noupdate -expand -group READ_ADDR -color Yellow /top/axi_vif/ARREADY
add wave -noupdate -expand -group {Read Operation} -color {Violet Red} /top/axi_vif/RDATA
add wave -noupdate -expand -group {Read Operation} -color {Violet Red} /top/axi_vif/RRESP
add wave -noupdate -expand -group {Read Operation} -color {Violet Red} /top/axi_vif/RVALID
add wave -noupdate -expand -group {Read Operation} -color {Violet Red} /top/axi_vif/RLAST
add wave -noupdate -expand -group {Read Operation} -color {Dark Slate Blue} /top/axi_vif/RREADY
add wave -noupdate -expand -group Memory -radix unsigned /top/axi_vif/mem_inst/mem_addr
add wave -noupdate -expand -group Memory /top/axi_vif/mem_inst/mem_en
add wave -noupdate -expand -group Memory /top/axi_vif/mem_inst/mem_rdata
add wave -noupdate -expand -group Memory /top/axi_vif/mem_inst/mem_wdata
add wave -noupdate -expand -group Memory /top/axi_vif/mem_inst/mem_we
add wave -noupdate -expand -group Memory /top/axi_vif/mem_inst/memory
add wave -noupdate -color Turquoise /top/axi_vif/write_state
add wave -noupdate -color Turquoise /top/axi_vif/read_state
add wave -noupdate /top/axi_vif/read_boundary_cross
add wave -noupdate /top/axi_vif/write_boundary_cross
add wave -noupdate /top/axi_vif/read_burst_cnt
add wave -noupdate /top/axi_vif/write_burst_cnt
add wave -noupdate /top/axi_vif/Assertion_bvalid_after_last
add wave -noupdate /top/axi_vif/Assertion_rready_after_last
add wave -noupdate /top/axi_vif/Assertion_awready_after_awvalid
add wave -noupdate /top/axi_vif/Assertion_WLAST_AND_RLAST
add wave -noupdate /top/axi_vif/Assertion_WLAST_AND_AWREADY
add wave -noupdate /top/axi_vif/Assertion_RLAST_AND_ARREADY
add wave -noupdate /top/axi_vif/Assertion_WLAST_AND_AWVALID
add wave -noupdate /top/axi_vif/Assertion_RLAST_AND_ARVALID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {211193 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {322770 ns}
