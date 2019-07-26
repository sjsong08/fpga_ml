# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# *********************************************************************
# Script for compiling the HDMI Example Design software
#
# *********************************************************************

# Location where BSP is built
BSP_DIR=./../software/tx_control_bsp

# Location where the application is built
APP_DIR=./../software/tx_control

# Location containing all the application source files
APP_SRC_DIR=./../software/tx_control_src

# SOPC file definitions
SOPC_INFO="./../rtl/nios/nios.sopcinfo"
SOPC_TIMER_NAME="wd_timer"
SOPC_CPU_NAME="cpu"
SOPC_CODE_MEMORY_NAME="cpu_ram"

# Various
ELF_NAME=tx_control.elf
OPTIMIZATION_LEVEL="-O0"
APP_FLAGS="--set APP_CFLAGS_OPTIMIZATION $OPTIMIZATION_LEVEL"

# BSP options
SIMULATION_OPTIMIZED_SUPPORT="false"
BSP_TYPE=hal
BSP_FLAGS="--set hal.enable_c_plus_plus 1 \
--set hal.enable_clean_exit 1 \
--set hal.enable_exit 1 \
--set hal.enable_gprof 0 \
--set hal.enable_lightweight_device_driver_api 0 \
--set hal.enable_mul_div_emulation 0 \
--set hal.enable_reduced_device_drivers 1 \
--set hal.enable_runtime_stack_checking 0 \
--set hal.enable_sim_optimize 0 \
--set hal.enable_small_c_library 1 \
--set hal.enable_sopc_sysid_check 1 \
--set hal.enable_sim_optimize $SIMULATION_OPTIMIZED_SUPPORT \
--set hal.make.bsp_cflags_optimization $OPTIMIZATION_LEVEL \
--set hal.linker.allow_code_at_reset 1 \
--set hal.linker.enable_alt_load 1 \
--set hal.linker.enable_alt_load_copy_exceptions 0 \
--set hal.linker.enable_alt_load_copy_rodata 0 \
--set hal.linker.enable_alt_load_copy_rwdata 1 \
--set hal.linker.enable_exception_stack 0 \
--set hal.linker.enable_interrupt_stack 0 \
--set hal.linker.exception_stack_memory_region_name $SOPC_CODE_MEMORY_NAME \
--set hal.linker.interrupt_stack_memory_region_name $SOPC_CODE_MEMORY_NAME \
--set hal.make.ignore_system_derived.debug_core_present 0 \
--set hal.make.ignore_system_derived.fpu_present 0 \
--set hal.make.ignore_system_derived.hardware_divide_present 0 \
--set hal.make.ignore_system_derived.hardware_fp_cust_inst_divider_present 0 \
--set hal.make.ignore_system_derived.hardware_fp_cust_inst_no_divider_present 0 \
--set hal.make.ignore_system_derived.hardware_multiplier_present 0 \
--set hal.make.ignore_system_derived.hardware_mulx_present 0 \
--set hal.make.ignore_system_derived.sopc_simulation_enabled 0 \
--set hal.make.ignore_system_derived.sopc_system_base_address 0 \
--set hal.make.ignore_system_derived.sopc_system_id 0 \
--set hal.make.ignore_system_derived.sopc_system_timestamp 0 \
--set hal.max_file_descriptors 32 \
--set hal.stderr jtag_uart_0 \
--set hal.stdin jtag_uart_0 \
--set hal.stdout jtag_uart_0 \
--set hal.sys_clk_timer $SOPC_TIMER_NAME \
--set hal.timestamp_timer none"
# --set hal.make.ignore_system_derived.big_endian 0 \

# make a copy of standard dp_demo sources
mkdir -p $APP_DIR
cp $APP_SRC_DIR/* $APP_DIR

# generate the BSP in the $BSP_DIR
cmd="nios2-bsp $BSP_TYPE $BSP_DIR $SOPC_INFO $BSP_FLAGS"
$cmd || {
  echo "nios2-bsp failed"
}

# generate the application make file in the $APP_DIR
cmd="nios2-app-generate-makefile --app-dir $APP_DIR --bsp-dir $BSP_DIR --elf-name $ELF_NAME --src-rdir $APP_DIR $APP_FLAGS"
$cmd || {
  echo "nios2-app-generate-makefile failed"
  exit 1
}

# Running make (for application, memory initialization files and the bsp due to dependencies)
cmd="make mem_init_generate --directory=$APP_DIR"
$cmd || {
    echo "make failed"
}
