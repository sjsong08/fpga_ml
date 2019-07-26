// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module dcfifo_inst #(
    parameter DEVICE_FAMILY      = "Cyclone 10 GX",
    parameter NUMWORDS           = 32,
    parameter WIDTH              = 102,
    parameter WIDTHU             = 5,
    parameter OVERFLOW_CHECKING  = "OFF",
    parameter UNDERFLOW_CHECKING = "OFF"

) (
    input wire [WIDTH-1:0]   data,
    input wire               rdclk,
    input wire               rdreq,
    input wire               wrclk,
    input wire               wrreq,
    input wire               aclr,
    output wire [WIDTH-1:0]  q,
    output wire              rdempty,
    output wire              wrfull,
    output wire [WIDTHU-1:0] wrusedw,
    output wire [WIDTHU-1:0] rdusedw
);

    dcfifo  dcfifo_component (
      /* I */ .rdclk (rdclk),
      /* I */ .wrclk (wrclk),
      /* I */ .wrreq (wrreq),
      /* I */ .aclr (aclr),
      /* I */ .data (data),
      /* I */ .rdreq (rdreq),
      /* O */ .wrfull (wrfull),
      /* O */ .q (q),
      /* O */ .rdempty (rdempty),
      /* O */ .eccstatus (),
      /* O */ .rdfull (),
      /* O */ .rdusedw (rdusedw),
      /* O */ .wrempty (),
      /* O */ .wrusedw (wrusedw));
    defparam
      dcfifo_component.enable_ecc  = "FALSE",
      dcfifo_component.intended_device_family = DEVICE_FAMILY,
      dcfifo_component.lpm_hint  = "DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
      dcfifo_component.lpm_numwords = NUMWORDS,
      dcfifo_component.lpm_showahead = "OFF",
      dcfifo_component.lpm_type = "dcfifo",
      dcfifo_component.lpm_width = WIDTH,
      dcfifo_component.lpm_widthu = WIDTHU,
      dcfifo_component.overflow_checking = OVERFLOW_CHECKING,
      dcfifo_component.rdsync_delaypipe = 4,
      dcfifo_component.read_aclr_synch = "ON",
      dcfifo_component.underflow_checking = UNDERFLOW_CHECKING,
      dcfifo_component.use_eab = "ON",
      dcfifo_component.write_aclr_synch = "ON",
      dcfifo_component.wrsync_delaypipe = 4;

endmodule



