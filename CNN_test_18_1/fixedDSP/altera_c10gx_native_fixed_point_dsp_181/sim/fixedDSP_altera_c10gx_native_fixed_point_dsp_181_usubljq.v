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

module  fixedDSP_altera_c10gx_native_fixed_point_dsp_181_usubljq  (








            ax,





            ay,





            bx,





            by,







            resulta);




















            input [17:0] ax;














            input [17:0] ay;














            input [17:0] bx;














            input [17:0] by;














            output [63:0] resulta;
















            wire [63:0] sub_wire0;











            wire [63:0] resulta = sub_wire0[63:0];    









            cyclone10gx_mac        cyclone10gx_mac_component (


























































                                        .ax (ax),





                                        .ay (ay),





                                        .bx (bx),





                                        .by (by),





                                        .resulta (sub_wire0),





                                        .accumulate (),





                                        .aclr (),





                                        .az (),





                                        .bz (),





                                        .chainin (),





                                        .chainout (),





                                        .clk (),





                                        .coefsela (),





                                        .coefselb (),





                                        .dftout (),





                                        .ena (),





                                        .loadconst (),





                                        .negate (),





                                        .resultb (),





                                        .scanin (),





                                        .scanout (),







                                        .sub ());






            defparam










                    cyclone10gx_mac_component.ax_width = 18,








                    cyclone10gx_mac_component.ay_scan_in_width = 18,








                    cyclone10gx_mac_component.bx_width = 18,








                    cyclone10gx_mac_component.by_width = 18,










                    cyclone10gx_mac_component.operation_mode = "m18x18_sumof2",








                    cyclone10gx_mac_component.mode_sub_location = 0,










                    cyclone10gx_mac_component.operand_source_max = "input",










                    cyclone10gx_mac_component.operand_source_may = "input",










                    cyclone10gx_mac_component.operand_source_mbx = "input",










                    cyclone10gx_mac_component.operand_source_mby = "input",










                    cyclone10gx_mac_component.signed_max = "false",










                    cyclone10gx_mac_component.signed_may = "false",










                    cyclone10gx_mac_component.signed_mbx = "false",










                    cyclone10gx_mac_component.signed_mby = "false",










                    cyclone10gx_mac_component.preadder_subtract_a = "false",










                    cyclone10gx_mac_component.preadder_subtract_b = "false",










                    cyclone10gx_mac_component.ay_use_scan_in = "false",










                    cyclone10gx_mac_component.by_use_scan_in = "false",










                    cyclone10gx_mac_component.delay_scan_out_ay = "false",










                    cyclone10gx_mac_component.delay_scan_out_by = "false",










                    cyclone10gx_mac_component.use_chainadder = "false",










                    cyclone10gx_mac_component.enable_double_accum = "false",








                    cyclone10gx_mac_component.load_const_value = 0,








                    cyclone10gx_mac_component.coef_a_0 = 0,








                    cyclone10gx_mac_component.coef_a_1 = 0,








                    cyclone10gx_mac_component.coef_a_2 = 0,








                    cyclone10gx_mac_component.coef_a_3 = 0,








                    cyclone10gx_mac_component.coef_a_4 = 0,








                    cyclone10gx_mac_component.coef_a_5 = 0,








                    cyclone10gx_mac_component.coef_a_6 = 0,








                    cyclone10gx_mac_component.coef_a_7 = 0,








                    cyclone10gx_mac_component.coef_b_0 = 0,








                    cyclone10gx_mac_component.coef_b_1 = 0,








                    cyclone10gx_mac_component.coef_b_2 = 0,








                    cyclone10gx_mac_component.coef_b_3 = 0,








                    cyclone10gx_mac_component.coef_b_4 = 0,








                    cyclone10gx_mac_component.coef_b_5 = 0,








                    cyclone10gx_mac_component.coef_b_6 = 0,








                    cyclone10gx_mac_component.coef_b_7 = 0,










                    cyclone10gx_mac_component.ax_clock = "none",










                    cyclone10gx_mac_component.ay_scan_in_clock = "none",










                    cyclone10gx_mac_component.az_clock = "none",










                    cyclone10gx_mac_component.bx_clock = "none",










                    cyclone10gx_mac_component.by_clock = "none",










                    cyclone10gx_mac_component.bz_clock = "none",










                    cyclone10gx_mac_component.coef_sel_a_clock = "none",










                    cyclone10gx_mac_component.coef_sel_b_clock = "none",










                    cyclone10gx_mac_component.sub_clock = "none",










                    cyclone10gx_mac_component.sub_pipeline_clock = "none",










                    cyclone10gx_mac_component.negate_clock = "none",










                    cyclone10gx_mac_component.negate_pipeline_clock = "none",










                    cyclone10gx_mac_component.accumulate_clock = "none",










                    cyclone10gx_mac_component.accum_pipeline_clock = "none",










                    cyclone10gx_mac_component.load_const_clock = "none",










                    cyclone10gx_mac_component.load_const_pipeline_clock = "none",










                    cyclone10gx_mac_component.input_pipeline_clock = "none",










                    cyclone10gx_mac_component.output_clock = "none",








                    cyclone10gx_mac_component.scan_out_width = 18,










                    cyclone10gx_mac_component.result_a_width = 64;








endmodule




