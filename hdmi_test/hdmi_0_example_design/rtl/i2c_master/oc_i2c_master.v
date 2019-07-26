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


module oc_i2c_master (
    inout scl_pad_io ,
    inout sda_pad_io ,

    output wb_ack_o ,
    input [2:0] wb_adr_i  ,
    input wb_clk_i ,
    //input wb_cyc_i ,
    input [7:0] wb_dat_i ,
    output [7:0] wb_dat_o ,
    //wb_err_o ,
    input wb_rst_i ,
    input wb_stb_i,
    input wb_we_i,
    output wb_inta_o 
  );


    wire scl_pad_i ;
    wire scl_pad_o ;
    wire scl_padoen_o ;
    wire sda_pad_i ;
    wire sda_pad_o ;
    wire sda_padoen_o ;
    wire arst_i ;
    wire [2:0] temp_wb_adr_i ;


  assign temp_wb_adr_i = wb_adr_i;

  i2c_master_top i2c_top_inst (
                .wb_clk_i  (wb_clk_i),  
                .wb_rst_i  (wb_rst_i),  
                .arst_i    (arst_i),    
                .wb_adr_i  (temp_wb_adr_i),  
                .wb_dat_i  (wb_dat_i),  
                .wb_dat_o  (wb_dat_o),  
                .wb_we_i   (wb_we_i),   
                .wb_stb_i  (wb_stb_i),  
                .wb_cyc_i  (1'b1),
                .wb_ack_o  (wb_ack_o),  
                .wb_inta_o (wb_inta_o), 

                // i2c lines
                .scl_pad_i     (scl_pad_i),   
                .scl_pad_o     (scl_pad_o),   
                .scl_padoen_o  (scl_padoen_o),
                .sda_pad_i     (sda_pad_i),   
                .sda_pad_o     (sda_pad_o),   
                .sda_padoen_o  (sda_padoen_o)
  );

  assign arst_i = 1'd1;
  //assign scl_pad_io  =  ((scl_padoen_o) != 1'b0) ? 1'bZ : scl_pad_o;
  //assign sda_pad_io  =  ((sda_padoen_o) != 1'b0) ? 1'bZ : sda_pad_o;
  //assign scl_pad_i = scl_pad_io;
  //assign sda_pad_i = sda_pad_io;

  //output_buf_i2c u_scl_io (
  // /* I */ .datain (scl_pad_o),
  // /* B */ .dataio (scl_pad_io), 
  // /* I */ .oe (~scl_padoen_o),
  // /* O */ .dataout (scl_pad_i)
  //);
  
  //output_buf_i2c u_sda_io (
  // /* I */ .datain (sda_pad_o),
  // /* B */ .dataio (sda_pad_io), 
  // /* I */ .oe (~sda_padoen_o),
  // /* O */ .dataout (sda_pad_i)
  //);

  altera_gpio #(
    .SIZE                (1),
    .PIN_TYPE            ("bidir"),
    .REGISTER_MODE       ("none"),
    .HALF_RATE           ("false"),
    .SEPARATE_I_O_CLOCKS ("false"),
    .BUFFER_TYPE         ("single-ended"),
    .PSEUDO_DIFF         ("false"),
    .ARESET_MODE         ("none"),
    .SRESET_MODE         ("none"),
    .OPEN_DRAIN          ("true"),
    .BUS_HOLD            ("false"),
    .ENABLE_OE           ("false"),
    .ENABLE_CKE          ("false"),
    .ENABLE_TERM         ("false")
  ) u_scl_io (
    .dout                       (scl_pad_i),            //   dout.export
    .din                        (scl_pad_o),            //    din.export
    .oe                         (~scl_padoen_o),        //     oe.export
    .pad_io                     (scl_pad_io),           // pad_io.export
    .cke                        (1'b1),                 // (terminated)
    .ck_fr_in                   (1'b0),                 // (terminated)
    .ck_fr_out                  (1'b0),                 // (terminated)
    .ck_in                      (1'b0),                 // (terminated)
    .ck_out                     (1'b0),                 // (terminated)
    .ck_fr                      (1'b0),                 // (terminated)
    .ck                         (1'b0),                 // (terminated)
    .ck_hr_in                   (1'b0),                 // (terminated)
    .ck_hr_out                  (1'b0),                 // (terminated)
    .ck_hr                      (1'b0),                 // (terminated)
    .pad_io_b                   (),                     // (terminated)
    .pad_in                     (1'b0),                 // (terminated)
    .pad_in_b                   (1'b0),                 // (terminated)
    .pad_out                    (),                     // (terminated)
    .pad_out_b                  (),                     // (terminated)
    .seriesterminationcontrol   (16'b0000000000000000), // (terminated)
    .parallelterminationcontrol (16'b0000000000000000), // (terminated)
    .aclr                       (1'b0),                 // (terminated)
    .aset                       (1'b0),                 // (terminated)
    .sclr                       (1'b0),                 // (terminated)
    .sset                       (1'b0)                  // (terminated)
  );

  altera_gpio #(
    .SIZE                (1),
    .PIN_TYPE            ("bidir"),
    .REGISTER_MODE       ("none"),
    .HALF_RATE           ("false"),
    .SEPARATE_I_O_CLOCKS ("false"),
    .BUFFER_TYPE         ("single-ended"),
    .PSEUDO_DIFF         ("false"),
    .ARESET_MODE         ("none"),
    .SRESET_MODE         ("none"),
    .OPEN_DRAIN          ("true"),
    .BUS_HOLD            ("false"),
    .ENABLE_OE           ("false"),
    .ENABLE_CKE          ("false"),
    .ENABLE_TERM         ("false")
  ) u_sda_io (
    .dout                       (sda_pad_i),            //   dout.export
    .din                        (sda_pad_o),            //    din.export
    .oe                         (~sda_padoen_o),        //     oe.export
    .pad_io                     (sda_pad_io),           // pad_io.export
    .cke                        (1'b1),                 // (terminated)
    .ck_fr_in                   (1'b0),                 // (terminated)
    .ck_fr_out                  (1'b0),                 // (terminated)
    .ck_in                      (1'b0),                 // (terminated)
    .ck_out                     (1'b0),                 // (terminated)
    .ck_fr                      (1'b0),                 // (terminated)
    .ck                         (1'b0),                 // (terminated)
    .ck_hr_in                   (1'b0),                 // (terminated)
    .ck_hr_out                  (1'b0),                 // (terminated)
    .ck_hr                      (1'b0),                 // (terminated)
    .pad_io_b                   (),                     // (terminated)
    .pad_in                     (1'b0),                 // (terminated)
    .pad_in_b                   (1'b0),                 // (terminated)
    .pad_out                    (),                     // (terminated)
    .pad_out_b                  (),                     // (terminated)
    .seriesterminationcontrol   (16'b0000000000000000), // (terminated)
    .parallelterminationcontrol (16'b0000000000000000), // (terminated)
    .aclr                       (1'b0),                 // (terminated)
    .aset                       (1'b0),                 // (terminated)
    .sclr                       (1'b0),                 // (terminated)
    .sset                       (1'b0)                  // (terminated)
  );
endmodule


