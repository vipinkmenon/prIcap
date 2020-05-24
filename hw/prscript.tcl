#Before running the script the block design should have been already created and floorplanning should have been already saved in the xdc file
open_project imageProcessingVideoDisplay.xpr
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z020clg484-1 -flow {Vivado Synthesis 2017} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
}
set obj [get_runs synth_1]

generate_target all [get_files  D:/VivadoProject/PRwithZycap/imageProcessingVideoDisplay.srcs/sources_1/bd/system/system.bd]
if {![file exists ./imageProcessingVideoDisplay.sdk]} {
      file mkdir imageProcessingVideoDisplay.sdk
}
write_hwdef -force  -file ./imageProcessingVideoDisplay.sdk/system_wrapper.hdf
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1

if {![file exists ./netlists/static]} {
      file mkdir ./netlists/static
}
write_checkpoint -force ./netlists/static/static.dcp

read_checkpoint -cell [get_cells system_i/imageProcess_0/inst/conv] ./netlists/sobel/conv.dcp
opt_design
place_design
route_design
if {![file exists ./netlists/config1]} {
      file mkdir ./netlists/config1
}
write_checkpoint -force ./netlists/config1/config1Routed.dcp

update_design  -cell [get_cells system_i/imageProcess_0/inst/conv] -black_box
lock_design -level routing
write_checkpoint -force ./netlists/static/staticRouted.dcp

read_checkpoint -cell [get_cells system_i/imageProcess_0/inst/conv] ./netlists/sharpen/conv.dcp
opt_design
place_design
route_design
if {![file exists ./netlists/config2]} {
      file mkdir ./netlists/config2
}
write_checkpoint -force ./netlists/config2/config2Routed.dcp

update_design  -cell [get_cells system_i/imageProcess_0/inst/conv] -black_box
read_checkpoint -cell [get_cells system_i/imageProcess_0/inst/conv] ./netlists/blur/conv.dcp
opt_design
place_design
route_design
if {![file exists ./netlists/config3]} {
      file mkdir ./netlists/config3
}
write_checkpoint -force ./netlists/config3/config3Routed.dcp

if {![file exists ./bitstreams]} {
      file mkdir ./bitstreams
}

if {![file exists ./bitstreams/config3]} {
      file mkdir ./bitstreams/config3
}
write_bitstream -force -bin_file ./bitstreams/config3/config3.bit
open_checkpoint ./netlists/config1/config1Routed.dcp
if {![file exists ./bitstreams/config1]} {
      file mkdir ./bitstreams/config1
}
write_bitstream -force -bin_file ./bitstreams/config1/config1.bit
close_design
if {![file exists ./bitstreams/config2]} {
      file mkdir ./bitstreams/config2
}
open_checkpoint ./netlists/config2/config2Routed.dcp
write_bitstream -force -bin_file ./bitstreams/config2/config2.bit
close_design

write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 ./bitstreams/config1/config1_pblock_conv_partial.bit" "./bitstreams/config1/pconfig1.bin"
write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 ./bitstreams/config2/config2_pblock_conv_partial.bit" "./bitstreams/config2/pconfig2.bin"
write_cfgmem -force -format BIN -interface SMAPx32 -loadbit "up 0x0 ./bitstreams/config3/config3_pblock_conv_partial.bit" "./bitstreams/config3/pconfig3.bin"