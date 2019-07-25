## # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
  set QSYS_SIMDIR C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/
# #
# # Source the generated IP simulation script.
  source C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/mentor/msim_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
 dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
 com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #

vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/testing_tb.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/sim-cnn.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/sim-CNN_test.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/sim-conv_layer.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/sim-test_bram.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/sim-mid_bram.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/fixedDSP/sim/fixedDSP.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/paral_add/sim/paral_add.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/para_add/sim/para_add.v
vlog -vlog01compat -work work C:/intelFPGA_pro/18.1/Projects/fpga_ml/CNN_test_18_1/bram_1port/sim/bram_1port.v

# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
 set TOP_LEVEL_NAME tb
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
 elab
# #
# # Run the simulation.
# run -a
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END



