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


module altera_iopll_reconfig_core
#(
    parameter FAMILY        = "Arria 10",
    parameter ADDR_WIDTH    = 9,
    parameter MAX_DATA      = 18,  // Width of largest data input
    parameter DATA_WIDTH    = 32,
    parameter WAIT_FOR_LOCK = 1
) (
    // Inputs
    input   wire                    mgmt_clk,
    input   wire                    mgmt_rst_n,

    // Avalon-MM slave interface
    input   wire [ADDR_WIDTH-1:0]   mgmt_address,
    input   wire                    mgmt_read,
    input   wire                    mgmt_write,
    input   wire [DATA_WIDTH-1:0]   mgmt_writedata,

    output  wire [DATA_WIDTH-1:0]   mgmt_readdata,
    output  wire                    mgmt_waitrequest,

    // PLL signals
    input   wire [63:0]             reconfig_from_pll,
    output  wire [63:0]             reconfig_to_pll
);

    localparam  DPRIO_DATA_WIDTH    =   8;
    localparam  DPRIO_ADDR_WIDTH    =   9;

// -------------------------------------------------------------------------------------------------------
//   USER ADDRESS:
// -------------------------------------------------------------------------------------------------------
//                        ___________________________________________________________________________
//  Counter Reconfig     |   is_dps      |   is_counter  |   M/N/C ID            |   C COUNTER INDEX |  
//                       |   1'b0        |   1'b1        |   3'b                 |   4'b             |  
//                       |---------------+---------------+-----------------------+-------------------|
//  DPS Reconfig         |   is_dps      |   is_counter  |   RSVD                |   C COUNTER INDEX |       
//                       |   1'b1        |   0'b1        |   3'b                 |   4'b             |
//                       |---------------+---------------+-----------------------+-------------------|
//  Analog Reconfig      |   is_dps      |   is_counter  |   BW/CP ID            |   RSVD            |       
//                       |   1'b0        |   1'b0        |   3'b                 |   4'b             |    
//                       |---------------+---------------+-----------------------+-------------------|
//  MIF Streaming        |   is_dps      |   is_counter  |   START_MIF ID        |   RSVD            |  
//                       |   1'b0        |   1'b0        |   3'b                 |   4'b             |    
//                       |---------------+---------------+-----------------------+-------------------|
//  Generic Reconfig     |   is_dps      |   is_counter  |   DPRIO_ADDRESS                           |   
//                       |   1'b         |   1'b         |   7'b                                     |    
//                       '---------------'---------------'-------------------------------------------'     
//
// ------------------
//  Counter reconfig
// ------------------
// M/N/C ID:
//  - M     = 3'b001
//  - N     = 3'b010
//  - C*    = 3'b100
//
// C Counter Index:
//  C0 - C8 = 4'b0000 - 4'b1001
//
// -----------------
//  Analog Reconfig
// -----------------
// BW/CP ID :
//  - BW    = 3'b100
//  - CP    = 3'b010
//
// ---------------
//  MIF Streaming
// ---------------
// START_MIF ID :
//  - MIF   = 3'b001
//
// ------------------
//  Generic Reconfig
// ------------------
// There are at most 70 DPRIO addresses for IOPLL --> 7 bits
//  (7'b000_0000 to 7'b100_0110)
//
// 
// -------------------------------------------------------------------------------------------------------
//   USER DATA:
// -------------------------------------------------------------------------------------------------------
//
// Counter:
//  | odd_duty_en   | bypass_enable     |   hi7 ..  hi0     |   lo7 ..  lo0         |
//  |      17       |       16          |   15  ..  8       |   7   ..  0           |
// DPS:
//  |               RSVD                |   up_dn           |   num_phase_shifts    |
//  |      17       ..       4          |   3               |   2   ..  0           |
// 
//
// Counter div values should be:
//  |   HI_DIV value    |   LO_DIV value    |
//  |   8'b             |   8'b             |
//
// -------------------------------------------------------------------------------------------------------
//   USER DATA:
// -------------------------------------------------------------------------------------------------------
//                        ___________________________________________________________________________
//  Counter Reconfig     | odd_duty_en |  bypass_en  |      hi_div[7:0]      |     lo_div[7:0]       |  
//                       |      17     |     16      |       15  ..  8       |      7  ..  0         |  
//                       '-------------+-------------+-----------------------+-----------------------'
//                        ___________________________________________________________________________
//  DPS Reconfig         |                 RSVD                       |   up_dn   | num_phase_shifts |  
//                       |               17 .. 4                      |     3     |    2  ..  0      | 
//                       '--------------------------------------------+-----------+------------------'
//                        ___________________________________________________________________________
//  Analog Reconfig      |                 RSVD                |     bw_ctrl    |    cp_current      |  
//                       |               17 .. 10              |     9 .. 6     |     5  ..  0       | 
//                       '-------------------------------------+----------------+--------------------'
//                        ___________________________________________________________________________
//  Generic Reconfig     |                    RSVD                    |         DPRIO data           |  
//                       |                  17 .. 8                   |          7  ..  0            | 
//                       '--------------------------------------------+------------------------------'
//
// -------------------------------------------------------------------------------------------------------
//   DPRIO LATENCIES
// -------------------------------------------------------------------------------------------------------
//  READ Latencies:
//  readWaitTime    = 0 (# of extra cycles to hold read high after captured)
//  readLatency     = 2 (# of cycles for valid data)
//                          _______
//  Read:               ___|       |_______________________
//                          ___     ___     ___     ___
//  CLK:                ___|   |___|   |___|   |___|   |___
//
//  CYCLE:                 |   0   |   1   |   2   |
//                                          ________________
//  DPRIO READDATA:     ___________________|    DATAOUT
//
//  WRITE Latencies:
//  writeWaitTime   = 0     (one/current cycle write assert sufficient)
//  writelatency    = n/a   (meaningless, we're not getting data back)
//   
// ------------------------------------------------------------------------------------------------------- 


    // ------------------------------------------------------------------  
    //   Internal Wires
    // ------------------------------------------------------------------  

    // Interface to DPRIO: DPRIO inputs
    wire dprio_clk;
    wire dprio_rst_n;
    wire dprio_read;
    wire dprio_write;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_address;
    wire [DPRIO_DATA_WIDTH-1:0]  dprio_writedata;
    
    // Interface to DPRIO: DPRIO outputs
    wire [DPRIO_DATA_WIDTH-1:0]  dprio_readdata;    
    
    // Interface to PLL
    wire pll_locked;
    wire pll_locked_orig;
   
    // Wires to identify the command type
    wire is_dps;  
    wire is_cntr;  
    wire is_C;
    wire is_N;
    wire is_M;   
    wire is_bw;
    wire is_cp;
    
    // Data FIFO
    wire readreq_data;
    wire empty_data;
    wire full_data;
    wire [MAX_DATA-1:0] q_data;
    wire datafifo_write;

    // Command FIFO
    wire readreq_cmd;
    wire empty_cmd;
    wire full_cmd;
    wire [ADDR_WIDTH-1:0] q_cmd;
    wire cmdfifo_write;
    
    // Master FSM wires
    reg q1;         // s_chk_fifo
    reg q2;         // s_read_fifo
    reg q3;         // s_save_fifo
    reg q4;         // s_do_op
    reg q5;         // s_done
    
    // Wires for counter reconfig
    // Dprio register addresses for counters
    // Need to write to 3 DPRIO registers
    // per (hi + lo) of each counter
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_0;    
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_1;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_cntreg_2;

    // Temp DRPIO addresses for C counters
    // use if needed
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_0;    
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_1;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_c_cntreg_2;

    // Duplicate DPRIO regs for cntr/generic
    reg  [DPRIO_ADDR_WIDTH-1:0]  dprio_address_cnt;
    reg  [DPRIO_DATA_WIDTH-1:0]  dprio_writedata_cnt;
    wire        dprio_write_cnt;
    wire        dprio_read_cnt;
    
    // Dynamic Phase Shift wires
    wire    dps_d0;
    wire    dps_d1;
    reg     dps_q0;
    reg     dps_q1;

    wire    dps_start;
    wire    dps_op_done;
    wire    dps_phase_done;
    wire    [2:0] dps_num_phase_shifts;
    wire    dps_up_dn;
    wire    dps_phase_en;

    // Counter Read/Write FSM wires
    wire    cntr_write_done;
    wire    cntr_write_en;
    wire    cntr_read_done;
    wire    cntr_read_en;
    
    reg     cntr_read1;
    reg     cntr_read2;
    reg     cntr_read3;
    reg     cntr_save1;
    reg     cntr_save2;
    reg     cntr_save3;
    reg     cntr_save4;
    reg     cntr_write1;
    reg     cntr_write2;
    reg     cntr_write3;
    reg     cntr_write4;
    reg     cntr_write5;

    reg     [DATA_WIDTH-1:0]       readdata_cnt;
    reg     [DPRIO_DATA_WIDTH-1:0] dprio_read_reg;

    // DPRIO reg has pattern C counter index x 4, see comments above
    wire [5:0] physical_c_index_x4 /* synthesis keep */;
    wire [6:0] c_cnt_dprio_base;      // Register for Cx_hi[7:1]
    
    // On reads read from mgmt_address, on writes, read the address coming out of the fifo
    wire [3:0] logical_c_index      /* synthesis keep */; 
    wire [3:0] physical_c_index     /* synthesis keep */;
    
    // Analog wires
    wire analog_write_en;
    wire analog_read_en;
    wire analog_write_en_start;
    wire analog_done;
    
    wire dprio_write_analog;
    wire dprio_read_analog;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_address_analog;
    wire [DPRIO_DATA_WIDTH-1:0]  dprio_writedata_analog;
    wire [DATA_WIDTH-1:0]        readdata_analog;
  
    // Generic Read/Write wires
    wire gen_read_en;
    wire gen_write_en;
    wire gen_write_en_start; 
    wire generic_done;
     
    wire dprio_write_gen;
    wire dprio_read_gen;
    wire [DPRIO_ADDR_WIDTH-1:0]  dprio_address_gen;
    wire [DPRIO_DATA_WIDTH-1:0]  dprio_writedata_gen;
    wire [DATA_WIDTH-1:0]        readdata_gen;
    
    // Reconfig IP idle signal for IOPLL bootstrap IP
    wire reconfig_ip_idle;

    // ------------------------------------------------------------------  
    //   PLL Conduit Aassignments
    // ------------------------------------------------------------------  
    
    // To PLL conduit assignments
    assign dprio_clk    = mgmt_clk;
    assign dprio_rst_n  = mgmt_rst_n;

    assign reconfig_to_pll[0]       = dprio_clk;
    assign reconfig_to_pll[1]       = dprio_rst_n;
    assign reconfig_to_pll[2]       = dprio_read;
    assign reconfig_to_pll[3]       = dprio_write;
    assign reconfig_to_pll[12:4]    = dprio_address;
    assign reconfig_to_pll[20:13]   = dprio_writedata;
    assign reconfig_to_pll[24:21]   = physical_c_index;             // directly to cntsel
    assign reconfig_to_pll[27:25]   = dps_num_phase_shifts;
    assign reconfig_to_pll[28]      = dps_up_dn;
    assign reconfig_to_pll[29]      = dps_phase_en;
    assign reconfig_to_pll[30]      = ~reconfig_ip_idle;
    assign reconfig_to_pll[63:31]   = 0;                            // unused bits
    
    // From PLL conduit assignemnts
    assign dprio_readdata   = reconfig_from_pll[7:0];
    assign pll_locked_orig  = reconfig_from_pll[8];
    assign dps_phase_done   = reconfig_from_pll[9];
 

    // ------------------------------------------------------------------  
    //   DPRIO Mux
    // ------------------------------------------------------------------  
    
    // Which sub-FSM controls the DPRIO interface?

    assign dprio_address    =   (cntr_write_en  | cntr_read_en)          ?   dprio_address_cnt         : 
                                (gen_write_en   | gen_read_en)           ?   dprio_address_gen         :
                                (analog_read_en | analog_write_en)       ?   dprio_address_analog      : 9'b0;

    assign dprio_writedata  =   (cntr_write_en  | cntr_read_en)          ?   dprio_writedata_cnt       :
                                (gen_write_en)                           ?   dprio_writedata_gen       : 
                                (analog_read_en | analog_write_en)       ?   dprio_writedata_analog    : 8'b0;

    assign dprio_write      =   (cntr_write_en  | cntr_read_en)          ?   dprio_write_cnt           :
                                (gen_write_en)                           ?   dprio_write_gen           : 
                                (analog_read_en | analog_write_en)       ?   dprio_write_analog        : 1'b0;

    assign dprio_read       =   (cntr_write_en  | cntr_read_en)          ?   dprio_read_cnt            :
                                (gen_read_en)                            ?   dprio_read_gen            : 
                                (analog_read_en | analog_write_en)       ?   dprio_read_analog         : 1'b0;

                                
    // Where does the user's readdata come from?                            
                                
    assign mgmt_readdata    =   (cntr_read_done & cntr_read_en)          ?   readdata_cnt              :
                                (gen_read_en)                            ?   readdata_gen              : 
                                (analog_done & analog_read_en)           ?   readdata_analog           : 8'b0; 
                                
 
    // ------------------------------------------------------------------  
    //   Command Decoder
    // ------------------------------------------------------------------  
    // Check the mgmt_address during a read, and check the queue during a write
 
    assign is_dps     = (mgmt_read) ? (mgmt_address[8] === 1'b1) : (q_cmd[8] === 1'b1); 
    assign is_cntr    = (mgmt_read) ? (mgmt_address[7] === 1'b1) : (q_cmd[7] === 1'b1); 

    // For counter reconfig only (assign only in counter mode)
    assign is_C       = (cntr_read_en) ? mgmt_address[6] : q_cmd[6];
    assign is_N       = (cntr_read_en) ? mgmt_address[5] : q_cmd[5];
    assign is_M       = (cntr_read_en) ? mgmt_address[4] : q_cmd[4]; 
    
    // For analog reconfig only (assign regardless of mode)
    assign is_cp      = (mgmt_read) ? (mgmt_address[5] === 1'b1) : (q_cmd[5] === 1'b1);
    assign is_bw      = (mgmt_read) ? (mgmt_address[6] === 1'b1) : (q_cmd[6] === 1'b1);
     
    
    // ------------------------------------------------------------------  
    //   Master FSM
    // ------------------------------------------------------------------ 
    wire user_start         = mgmt_write & ~(|mgmt_address);                                           // Start = 9'b000000000
    wire done_op            = cntr_write_done & generic_done & dps_op_done & analog_done;              // writes only, if called by MASTER FSM. 
    wire fifo_empty         = empty_cmd;
   
    assign mgmt_waitrequest = (WAIT_FOR_LOCK) ? ~(q5 & pll_locked & cntr_read_done & generic_done & analog_done) : ~(q5 & cntr_read_done & generic_done & analog_done);  
   
    assign reconfig_ip_idle = q5 & cntr_read_done & generic_done & analog_done;  

    // Synchonize locked signal
   altera_std_synchronizer #(
        .depth(3)
    ) altera_std_synchronizer_inst (
        .clk(mgmt_clk),
        .reset_n(mgmt_rst_n), 
        .din(pll_locked_orig),
        .dout(pll_locked)
    );

   
    always @(posedge mgmt_clk)
    begin
        if (~mgmt_rst_n)
        begin
            // Default DONE state
            q1 <= 1'b0;
            q2 <= 1'b0;
            q3 <= 1'b0;
            q4 <= 1'b0;
            q5 <= 1'b1;
        end
        else if (~q1 & ~q2 & ~q3 & ~q4 & ~q5)
        begin
            // Force the IP to its idle state
            q1 <= 1'b0;
            q2 <= 1'b0;
            q3 <= 1'b0;
            q4 <= 1'b0;
            q5 <= 1'b1;           
        end
        else
        begin
            q1 <= (q4 & done_op) | (q5 & user_start);
            q2 <= q1 & ~fifo_empty;
            q3 <= q2;
            q4 <= q3 | (q4 & ~done_op);
            q5 <= (q1 & fifo_empty) | (q5 & ~user_start);
        end
    end    
    
 
    // ------------------------------------------------------------------  
    //   FIFOs
    // ------------------------------------------------------------------ 
    assign datafifo_write   = mgmt_write & ~user_start;
    assign cmdfifo_write    = mgmt_write & ~user_start;

    assign readreq_data     = q2;
    assign readreq_cmd      = q2;

    // Data FIFO
    altera_iopll_reconfig_core_fifo #(
        .FAMILY         (FAMILY),
        .NUM_WORDS      (8),
        .LOG2_NUM_WORDS (3),
        .WORD_WIDTH     (MAX_DATA)
    ) data_fifo (
        .clock       (mgmt_clk),
        .data        (mgmt_writedata),
        .rdreq       (readreq_data),
        .sclr        (~mgmt_rst_n),
        .wrreq       (datafifo_write),
        .almost_full (),
        .empty       (empty_data),
        .full        (full_data),
        .q           (q_data),
        .usedw       ()
    );
    
    // Command FIFO
    altera_iopll_reconfig_core_fifo #(
        .FAMILY         (FAMILY),
        .NUM_WORDS      (8),
        .LOG2_NUM_WORDS (3),
        .WORD_WIDTH     (ADDR_WIDTH)
    ) command_fifo (
        .clock       (mgmt_clk),
        .data        (mgmt_address),
        .rdreq       (readreq_cmd),
        .sclr        (~mgmt_rst_n),
        .wrreq       (cmdfifo_write),
        .almost_full (),
        .empty       (empty_cmd),
        .full        (full_cmd),
        .q           (q_cmd),
        .usedw       ()
    );

    
    // ------------------------------------------------------------------  
    //   Logical to Physical C Counter Translation
    // ------------------------------------------------------------------   

    // Logical to physical C counter translation is only required for
    // counter reconfig.  For dynamic phase shift, there are LCELLs in  
    // the altera_pll wrapper that look after the remapping for us.
    
    assign logical_c_index = (cntr_read_en) ? mgmt_address[3:0] : q_cmd[3:0];
    
    altera_iopll_reconfig_core_logical2physical #(
        .FAMILY   (FAMILY)
    ) c_index_translate (
        .logical  (logical_c_index),
        .physical (physical_c_index)
    );
    
    
    // ------------------------------------------------------------------  
    //   Counter Selection Logic
    // ------------------------------------------------------------------    

    assign physical_c_index_x4[5:2] = physical_c_index[3:0];    // mult by 4
    assign physical_c_index_x4[1:0] = 2'b0;    
    
    assign dprio_cntreg_0 = (is_C == 1'b1) ? dprio_c_cntreg_0   :
                            (is_N == 1'b1) ? 8'd0               :
                            (is_M == 1'b1) ? 8'd4               :
                            8'bx;

    assign dprio_cntreg_1 = (is_C == 1'b1) ? dprio_c_cntreg_1   :
                            (is_N == 1'b1) ? 8'd1               :
                            (is_M == 1'b1) ? 8'd5               :
                            8'bx;

    assign dprio_cntreg_2 = (is_C == 1'b1) ? dprio_c_cntreg_2   :
                            (is_N == 1'b1) ? 8'd2               :
                            (is_M == 1'b1) ? 8'd6               :
                            8'bx;
 
    // Find the DPRIO addresses of C counters
    assign dprio_c_cntreg_0 = physical_c_index_x4 + 8'd27;   // 9 bit result
    assign dprio_c_cntreg_1 = physical_c_index_x4 + 8'd28;
    assign dprio_c_cntreg_2 = physical_c_index_x4 + 8'd29;


    // ------------------------------------------------------------------  
    //   Ccounter Reconfig FSM
    // ------------------------------------------------------------------ 
    
    //bit settings
    assign  cntr_write_en   = is_cntr & ~is_dps & (q3|q4);
    assign  cntr_write_done = (cntr_write_en) ? cntr_write5 : 1'b1;      // Last state

    assign  cntr_read_en    = is_cntr & ~is_dps & mgmt_read;
    assign  cntr_read_done  = (cntr_read_en) ? cntr_write5 : 1'b1;

    // Read logic
    assign dprio_read_cnt   = cntr_read2 & ~cntr_save4;            // one cycle behind the dprio_address reg

    // Write logic
    assign dprio_write_cnt  = cntr_write2 & ~cntr_write_done;        // one cycle behind the dprio_address reg

    // M/N/C Counter read-modify-write state machine
    always @(posedge mgmt_clk)
    begin
        if (mgmt_rst_n == 1'b0)
        begin
            cntr_read1      <= 1'b0;
            cntr_read2      <= 1'b0;
            cntr_read3      <= 1'b0;
            cntr_save1      <= 1'b0;
            cntr_save2      <= 1'b0;
            cntr_save3      <= 1'b0;
            cntr_save4      <= 1'b0;
            cntr_write1     <= 1'b0;
            cntr_write2     <= 1'b0;
            cntr_write3     <= 1'b0;
            cntr_write4     <= 1'b0;
            cntr_write5     <= 1'b0;
            readdata_cnt    <= 32'b0;
        end
        else
          begin
            if (cntr_write_en != 1'b1 && cntr_read_en != 1'b1)
            begin
                cntr_read1      <= 1'b0;
                cntr_read2      <= 1'b0;
                cntr_read3      <= 1'b0;
                cntr_save1      <= 1'b0;
                cntr_save2      <= 1'b0;
                cntr_save3      <= 1'b0;
                cntr_save4      <= 1'b0;
                cntr_write1     <= 1'b0;
                cntr_write2     <= 1'b0;
                cntr_write3     <= 1'b0;
                cntr_write4     <= 1'b0;
                cntr_write5     <= 1'b0;
                readdata_cnt    <= 32'b0;
            end
            else
            begin
                cntr_read1      <= (cntr_write_en != 1'b1 && cntr_read_en != 1'b1)    ? 1'b0 : 1'b1;
                cntr_read2      <= cntr_read1;
                cntr_read3      <= cntr_read2;
                cntr_save1      <= cntr_read3;
                cntr_save2      <= cntr_save1;
                cntr_save3      <= cntr_save2;
                cntr_save4      <= cntr_save3;
                cntr_write1     <= cntr_save4   & cntr_write_en;
                cntr_write2     <= cntr_write1  & cntr_write_en;
                cntr_write3     <= cntr_write2  & cntr_write_en;
                cntr_write4     <= cntr_write3  & cntr_write_en;
                cntr_write5     <= (cntr_write_en) ? cntr_write4 : cntr_save4;
                
                // Read reg A+2 for the lo1,lo0 register only
                if (cntr_read1  == 1'b1 && cntr_read2 == 1'b0)                          // reg0
                begin
                    dprio_address_cnt   <= dprio_cntreg_0;                              // hi[7:1], bypass_enable
                end
                if (cntr_read2  == 1'b1 && cntr_read3 == 1'b0)                          // reg1
                begin
                    dprio_address_cnt   <= dprio_cntreg_1;                              // lo[7:2], odd_duty_en, hi[0]
                end
                if (cntr_read3  == 1'b1 && cntr_save1 == 1'b0)                          // reg2
                begin
                    dprio_address_cnt   <= dprio_cntreg_2;                              // lo[1:0]
                end
                // Capture from dprio after 3 cyles of read latency
                if (cntr_save1 == 1'b1 && cntr_save2 == 1'b0)
                begin
                    dprio_read_reg      <= dprio_readdata;
                    readdata_cnt[16]    <= dprio_readdata[0];                           // bypass_en
                    readdata_cnt[15:9]  <= dprio_readdata[7:1];                         // hi[7:1]
                end
                if (cntr_save2 == 1'b1 && cntr_save3 == 1'b0)
                begin
                    dprio_read_reg <= dprio_readdata;
                    readdata_cnt[8]     <= dprio_readdata[0];                           // hi[0]
                    readdata_cnt[17]    <= dprio_readdata[1];                           // odd_duty_en
                    readdata_cnt[7:2]   <= dprio_readdata[7:2];                         // lo[7:2]
                end
                if (cntr_save4 == 1'b1 && cntr_write1 == 1'b0)
                begin
                    dprio_read_reg      <= dprio_readdata; 
                    readdata_cnt[1:0]   <= dprio_readdata[1:0];                         // lo[1:0]
                end
                // Write register 1 2 3 for hi[7:0] and lo[7:0]
                if (cntr_write1 == 1'b1 && cntr_write2 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_0;
                    dprio_writedata_cnt <= {q_data[15:9],q_data[16]};                   // hi7..hi1,byps_enable
                end
                if (cntr_write2 == 1'b1 && cntr_write3 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_1;
                    dprio_writedata_cnt <= {q_data[7:2],q_data[17],q_data[8]};          // lo7..lo2,odd_duty_en,hi0 
                end
                if (cntr_write3 == 1'b1 && cntr_write4 == 1'b0)
                begin
                    dprio_address_cnt   <= dprio_cntreg_2;
                    dprio_writedata_cnt <= {dprio_read_reg[7:2],q_data[1:0]};           // (don't change),lo1..lo0
                end
            end
        end
    end
    // -- END COUNTER RECONFIG READ/WRITE FSM

    // ------------------------------------------------------------------  
    //   Generic Address Reconfig FSM
    // ------------------------------------------------------------------  
    assign  gen_read_en  = mgmt_read & is_cntr & is_dps;
    assign  gen_write_en = (q3|q4)   & is_cntr & is_dps;
    assign  gen_write_en_start  = q3 & is_cntr & is_dps;  // Possibly unnecessary
    
    wire [6:0] user_address = gen_read_en ? mgmt_address[6:0] : q_cmd[6:0];
    
    altera_iopll_reconfig_core_generic_fsm #(
        .FAMILY           (FAMILY),
        .DPRIO_ADDR_WIDTH (DPRIO_ADDR_WIDTH),
        .DPRIO_DATA_WIDTH (DPRIO_DATA_WIDTH)
    ) generic_fsm_inst (
        .clk              (mgmt_clk),   
        .rst_n            (mgmt_rst_n),
        .user_read        (gen_read_en),
        .user_write       (gen_write_en_start),
        .generic_done     (generic_done),
        
        .user_address     ({2'b00, user_address}),
        .user_writedata   (q_data[7:0]),
        .user_readdata    (readdata_gen[7:0]),
        
        .dprio_readdata   (dprio_readdata),          // input from PLL
        .dprio_address    (dprio_address_gen),       // output to PLL
        .dprio_writedata  (dprio_writedata_gen),     // output to PLL
        .dprio_write      (dprio_write_gen),         // output to PLL
        .dprio_read       (dprio_read_gen)           // output to PLL
    );
 
    // Set upper 24 bits of readdata_gen to 0
    assign readdata_gen[DATA_WIDTH-1:8] = 'b0; 
    
    // ------------------------------------------------------------------  
    //   Analog Reconfig FSM
    // ------------------------------------------------------------------ 
    assign analog_read_en  = mgmt_read & ~is_cntr & ~is_dps & (is_cp | is_bw);
    assign analog_write_en = (q3|q4)   & ~is_cntr & ~is_dps & (is_cp | is_bw);
    assign analog_write_en_start = q3  & ~is_cntr & ~is_dps & (is_cp | is_bw);  // This is is probably unnecessary
    
    altera_iopll_reconfig_core_analog_fsm #(
        .FAMILY           (FAMILY),
        .USER_DATA_WIDTH  (DATA_WIDTH),
        .DPRIO_ADDR_WIDTH (DPRIO_ADDR_WIDTH),
        .DPRIO_DATA_WIDTH (DPRIO_DATA_WIDTH)
    ) analog_fsm_inst (
        .clk              (mgmt_clk),   
        .rst_n            (mgmt_rst_n),
        .user_write       (analog_write_en_start),
        .user_read        (analog_read_en),
        .is_bw            (is_bw),                   // is_bw = 1 for BW, is_bw = 0 for CP
        .analog_done      (analog_done),
        .user_writedata   (q_data),
        .user_readdata    (readdata_analog),
        .dprio_readdata   (dprio_readdata),          // input from PLL
        .dprio_address    (dprio_address_analog),    // output to PLL
        .dprio_writedata  (dprio_writedata_analog),  // output to PLL
        .dprio_write      (dprio_write_analog),      // output to PLL
        .dprio_read       (dprio_read_analog)        // output to PLL
    );

    // ------------------------------------------------------------------  
    //   Dynamic Reconfig FSM
    // ------------------------------------------------------------------ 
    assign dps_start = ~is_cntr & is_dps & (q3|q4);
    assign dps_phase_en = ~dps_q1 & dps_q0;
    assign dps_num_phase_shifts = q_data[2:0];
    assign dps_up_dn = q_data[3];
    assign dps_op_done = ~dps_d0 & ~dps_d1;     // next state != done

    assign dps_d0 = (dps_start & (~(dps_q1 | dps_q0))) | (dps_q1 & ~dps_q0) | (dps_q1 & dps_q0 & ~dps_phase_done);
    assign dps_d1 = (~dps_q1 & dps_q0) | (dps_q1 & ~dps_q0) | (dps_q1 & dps_q0 & ~dps_phase_done);

    always @(posedge mgmt_clk)
    begin
        if (~mgmt_rst_n)
        begin
            // Default DPS_DONE state
            dps_q0 <= 1'b0;
            dps_q1 <= 1'b0;
        end
        else
        begin
            dps_q0 <= dps_d0;
            dps_q1 <= dps_d1;
        end
    end

endmodule


module altera_iopll_reconfig_core_analog_fsm
#(
    parameter FAMILY              = "Arria 10",
    parameter USER_DATA_WIDTH     = 32,
    parameter DPRIO_ADDR_WIDTH    = 9,
    parameter DPRIO_DATA_WIDTH    = 8
) (   
    // Signals to/from the master FSM
    input  wire clk,            // the master FSM's clock
    input  wire rst_n,          // active low, synchronous reset
    input  wire user_write,     // initiates an analog reconfig write operation
    input  wire user_read,      // command to perform an analog read
    input  wire is_bw,          // (is_bw) ? (reconfigure bandwidth) : (reconfigure CP current)
    output reg  analog_done,    // signals the return to idle state on completion
   
    input  wire [USER_DATA_WIDTH-1:0] user_writedata,   // user's desired write data
    output reg  [USER_DATA_WIDTH-1:0] user_readdata,    // user's requested read data
    
    // Signals to/from the IOPLL DPRIO
    input  wire [DPRIO_DATA_WIDTH-1:0] dprio_readdata,  // data read from the DPRIO
    output reg  [DPRIO_ADDR_WIDTH-1:0] dprio_address,   // DPRIO register address for read or write
    output reg  [DPRIO_DATA_WIDTH-1:0] dprio_writedata, // write data to the DPRIO
    
    output reg  dprio_write,    // initiates a DPRIO write 
    output reg  dprio_read      // initiates a DPRIO read
 );

    // Notes:
    // Inputs is_bw, user_read, and user_writedata are assumed to remain stable from "analog_start" until "done"
    // Output user_readdata is held stable from "done" until the next assertion of "analog_start"
    //
    // In simulation, some DPRIO reads return "x" values.  This is a simulation-only issue; it works properly in hardware.
    
    // Bandwidth & charge pump DPRIO register addresses
    localparam BW_ADDRESS_0 = 8'h0a;  // bits [6:3] <-> cr_bwctrl[3:0]
    localparam CP_ADDRESS_0 = 8'h09;  // bits [6:4] <-> cr_isel[2:0]
    localparam CP_ADDRESS_1 = 8'h3f;  // bits [5]   <-> cr_icp_high[0]
    localparam CP_ADDRESS_2 = 8'h40;  // bits [3]   <-> cr_icp_high[1]
    localparam CP_ADDRESS_3 = 8'h41;  // bits [1]   <-> cr_icp_high[2]
    
    // States
    localparam IDLE        = 4'd0,  // Idle state, with "analog_done" asserted
               READ0       = 4'd1,  // Send reg0 read command
               READ1       = 4'd2,  // Send reg1 read command
               READ2_SAVE0 = 4'd3,  // Send reg2 read command & save reg0 read data
               READ3_SAVE1 = 4'd4,  // Send reg3 read command & save reg1 read data 
               SAVE2       = 4'd5,  // Save reg2 read data 
               SAVE3       = 4'd6,  // Save reg3 read data
               READ_DONE   = 4'd7,  // Maintain user_readdata until read signal is deasserted
               WRITE0      = 4'd8,  // Send reg0 write command
               WRITE1      = 4'd9,  // Send reg1 write command
               WRITE2      = 4'd10,  // Send reg2 write command
               WRITE3      = 4'd11; // Send reg3 write command
    
    // FSM current and next states
    reg [3:0] state, next;     
              
    // To store read data
    reg [DPRIO_DATA_WIDTH-1:0]  old_dprio_data [0:3];

    integer i;
    
    // State update
    always @(posedge clk) begin
        if (rst_n == 1'b0)    state <= IDLE;   
        else                  state <= next; 
    end
    
    
    // Next-state logic and output logic
    always @(*) begin
        // Default next state 
        next = 'bx;   // All don't care
        
        // DPRIO signal default values
        dprio_address    = 1'bx;  // All don't care
        dprio_writedata  = 1'bx;  // All don't care
        dprio_write      = 1'b0;
        dprio_read       = 1'b0;
        
        // Output signal default values
        user_readdata    = 'bx;  // All don't care

        // Master FSM signal default values
        analog_done      = 1'b0;
        
        case (state)
            IDLE :       begin
                            analog_done = 1'b1;                           
                            if (user_write | user_read) next = READ0;  // Either a read or write command starts the FSM
                            else                        next = IDLE;
                         end     
                         
            READ0 :      begin
                            dprio_address = (is_bw) ? BW_ADDRESS_0 : CP_ADDRESS_0;
                            dprio_read    = 1'b1;
                            next = READ1;
                         end
                         
            READ1 :      begin
                            dprio_address = CP_ADDRESS_1;
                            dprio_read    = 1'b1;
                            next = READ2_SAVE0;
                         end
                         
            READ2_SAVE0: begin // Reg0 readdata comes back from DPRIO
                            dprio_address = CP_ADDRESS_2;
                            dprio_read    = 1'b1;
                            if (is_bw)  // For BW, we only need reg0
                               if (user_read) next = READ_DONE;   // user_read supercedes user_write
                               else           next = WRITE0;
                            else // CP current
                               next = READ3_SAVE1;
                         end
                         
            READ3_SAVE1: begin // Reg1 readdata comes back from DPRIO
                            dprio_address = CP_ADDRESS_3;
                            dprio_read    = 1'b1;            
                            next = SAVE2;
                         end
                         
            SAVE2 :      begin // Reg2 readdata comes back from DPRIO
                            next = SAVE3;
                         end
                         
            SAVE3 :      begin // Reg3 readdata comes back from DPRIO
                            if (user_read) next = READ_DONE; // Done read cycle
                            else           next = WRITE0;    // Begin write cycle
                         end 
 
            READ_DONE :  begin 
                            analog_done = 1'b1;   
                            if (is_bw)  user_readdata = { 22'b0, old_dprio_data[0][6:3], 6'b0}; // BW
                            else        user_readdata = { 26'b0, old_dprio_data[0][6:4], old_dprio_data[3][1], old_dprio_data[2][3], old_dprio_data[1][5] }; // CP                          
                            
                            if (user_read) next = READ_DONE;  // Hold user readdata
                            else           next = IDLE;       // Return to idle state
                         end 
 
            WRITE0 :     begin
                            dprio_address   = (is_bw) ? BW_ADDRESS_0 : CP_ADDRESS_0;
                            dprio_writedata = old_dprio_data[0];                   // 8 bits of old data
                            if (is_bw) dprio_writedata[6:3] = user_writedata[9:6]; // overwrite these bits if BW
                            else       dprio_writedata[6:4] = user_writedata[5:3]; // overwrite these bits if CP
                            
                            dprio_write = 1'b1;
                            if (is_bw) next = IDLE;         // For BW, only need reg0
                            else       next = WRITE1;                            
                         end
                         
            WRITE1 :     begin
                            dprio_address      = CP_ADDRESS_1;
                            dprio_writedata    = old_dprio_data[1];  // 8 bits of old data
                            dprio_writedata[5] = user_writedata[0];  // overwrite this bit for CP
                            dprio_write = 1'b1;                            
                            next = WRITE2;
                         end
                         
            WRITE2 :     begin
                            dprio_address     = CP_ADDRESS_2;
                            dprio_writedata    = old_dprio_data[2];  // 8 bits of old data
                            dprio_writedata[3] = user_writedata[1];  // overwrite this bit for CP
                            dprio_write = 1'b1;
                            next = WRITE3;
                         end
                         
            WRITE3 :     begin
                            dprio_address      = CP_ADDRESS_3;
                            dprio_writedata    = old_dprio_data[3];  // 8 bits of old data
                            dprio_writedata[1] = user_writedata[2];  // overwrite this bit for CP 
                            dprio_write = 1'b1;           
                            next = IDLE;
                         end
        endcase
    end
 
    
    // Store old_dprio_data
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            for (i=0; i<4; i=i+1)
                old_dprio_data[i] <= 1'bx; // All don't care
        end
        else begin      
            old_dprio_data[0] <= (state == READ2_SAVE0) ? dprio_readdata : old_dprio_data[0];
            old_dprio_data[1] <= (state == READ3_SAVE1) ? dprio_readdata : old_dprio_data[1];
            old_dprio_data[2] <= (state == SAVE2)       ? dprio_readdata : old_dprio_data[2];
            old_dprio_data[3] <= (state == SAVE3)       ? dprio_readdata : old_dprio_data[3];
        end
    end
    
 
 endmodule
 
 
 module altera_iopll_reconfig_core_fifo #(
    parameter FAMILY            = "Arria 10",
    parameter NUM_WORDS         = 8,
    parameter LOG2_NUM_WORDS    = 3,
    parameter WORD_WIDTH        = 32
) (
    input wire                       clock,
    input wire [WORD_WIDTH-1:0]      data,
    input wire                       rdreq,
    input wire                       sclr,
    input wire                       wrreq,

    output wire                      almost_full,
    output wire                      empty,
    output wire                      full,
    output wire [WORD_WIDTH-1:0]     q,
    output wire [LOG2_NUM_WORDS-1:0] usedw
);

    scfifo    scfifo_component (
                .clock        (clock),
                .sclr         (sclr),
                .wrreq        (wrreq),
                .data         (data),
                .rdreq        (rdreq),
                .usedw        (usedw),
                .empty        (empty),
                .full         (full),
                .q            (q),
                .almost_full  (almost_full),
                .aclr         (),
                .almost_empty ()
              );
    defparam
        scfifo_component.add_ram_output_register = "OFF",
        scfifo_component.almost_full_value = NUM_WORDS-2,
        scfifo_component.intended_device_family = FAMILY,
        scfifo_component.lpm_numwords = NUM_WORDS,
        scfifo_component.lpm_showahead = "OFF",
        scfifo_component.lpm_type = "scfifo",
        scfifo_component.lpm_width = WORD_WIDTH,
        scfifo_component.lpm_widthu = LOG2_NUM_WORDS,    // ceil(log2(num_words))
        scfifo_component.overflow_checking = "ON",
        scfifo_component.underflow_checking = "ON",
        scfifo_component.use_eab = "ON";

endmodule


module altera_iopll_reconfig_core_generic_fsm
#(
    parameter FAMILY              = "Arria 10",
    parameter DPRIO_ADDR_WIDTH    = 9,
    parameter DPRIO_DATA_WIDTH    = 8
) (
    // Signals to/from the master FSM
    input  wire clk,            // the master FSM's clock
    input  wire rst_n,          // active low, synchronous reset
    input  wire user_read,      // request a generic DPRIO read
    input  wire user_write,     // initiate a generic reconfig write operation
    output reg  generic_done,   // signals the return to idle state on completion of read or write
   
    input  wire [DPRIO_ADDR_WIDTH-1:0] user_address,    // user-specified DPRIO address
    input  wire [DPRIO_DATA_WIDTH-1:0] user_writedata,  // user's desired write data
    output wire [DPRIO_DATA_WIDTH-1:0] user_readdata,   // user's requested read data
    
    // Signals to/from the IOPLL DPRIO
    input  wire [DPRIO_DATA_WIDTH-1:0] dprio_readdata,  // data read from the DPRIO
    output wire [DPRIO_ADDR_WIDTH-1:0] dprio_address,   // DPRIO register address for read or write
    output wire [DPRIO_DATA_WIDTH-1:0] dprio_writedata, // write data to the DPRIO
    
    output reg  dprio_write,    // initiates a DPRIO write 
    output wire dprio_read      // initiates a DPRIO read
 );
 
    // Generic read/write give the user what is effectively direct access to the DPRIO, which allows them
    // to read from or write to any DPRIO address.
    //
    // Thus, the user inputs can be hooked up almost directly to the DPRIO outputs, with a few subtleties:
    //     - We must not assert generic_done until the read data has come back from the DPRIO
    //     - We must handle the fact that the write command comes from the Master FSM, not from the user directly

    
    // States
    localparam IDLE        = 2'd0,  // Idle state, with "generic_done" asserted
               WRITE       = 2'd1,  // For a write, assert DPRIO write command
               WAIT        = 2'd2,  // For a read, insert an extra cycle of delay
               DATA_RDY    = 2'd3;  // Announces that read data is ready
    
    // FSM current and next states
    reg [1:0] state, next;     

    // State update
    always @(posedge clk) begin
        if (rst_n == 1'b0)    state <= IDLE;   
        else                  state <= next; 
    end
    
    
    // Next-state logic
    always @(*) begin
        // Default next state 
        next         = IDLE; 

        // State machine-dependent outputs 
        generic_done = 1'b0;
        dprio_write  = 1'b0;
        
        case (state)
            IDLE :    begin
                          generic_done = 1'b1;
                          if (user_write)       next = WRITE;
                          else if (user_read)   next = WAIT;   // DPRIO read has already been asserted 
                          else                  next = IDLE;
                      end     
                         
            WRITE :   begin
                          dprio_write = 1'b1;
                          next = IDLE;
                      end
                         
            WAIT :    begin
                          if (user_read)        next = DATA_RDY;
                          else                  next = IDLE;
                      end  
                         
            DATA_RDY: begin 
                          generic_done = 1'b1;
                          if (user_read)        next = DATA_RDY;
                          else                  next = IDLE;
                      end
        endcase
    end

    // Direct feed-through of user inputs to DPRIO
    assign dprio_read      = user_read;
    assign dprio_address   = user_address;
    assign dprio_writedata = user_writedata;
    
    // Direct feed-through of DPRIO readdata to user output
    assign user_readdata   = dprio_readdata;
   
endmodule
 
 
 // Translate logical to physical C counters for counter rotations
module altera_iopll_reconfig_core_logical2physical #(
    parameter FAMILY = "Arria 10"
) (
    input  wire [3:0] logical,
    output wire [3:0] physical
);    
    // Quartus rotates 5 luts, just use LSB 4

    // LCELLS
    lcell_counter_remap lcell_cnt_sel_0 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[0]));
    defparam lcell_cnt_sel_0.lut_mask = 64'hAAAAAAAAAAAAAAAA;
    defparam lcell_cnt_sel_0.dont_touch = "on";
    defparam lcell_cnt_sel_0.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_1 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[1]));
    defparam lcell_cnt_sel_1.lut_mask = 64'hCCCCCCCCCCCCCCCC;
    defparam lcell_cnt_sel_1.dont_touch = "on";
    defparam lcell_cnt_sel_1.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_2 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[2]));
    defparam lcell_cnt_sel_2.lut_mask = 64'hF0F0F0F0F0F0F0F0;
    defparam lcell_cnt_sel_2.dont_touch = "on";
    defparam lcell_cnt_sel_2.family = FAMILY;
    lcell_counter_remap lcell_cnt_sel_3 (
        .dataa(logical[0]),
        .datab(logical[1]),
        .datac(logical[2]),
        .datad(logical[3]),
        .combout (physical[3]));
    defparam lcell_cnt_sel_3.lut_mask = 64'hFF00FF00FF00FF00;
    defparam lcell_cnt_sel_3.dont_touch = "on";
    defparam lcell_cnt_sel_3.family = FAMILY;
    // -- END LCELLS

endmodule


(* altera_attribute = "-name ADV_NETLIST_OPT_ALLOWED OFF" *) module lcell_counter_remap 
#(
    //parameter
    parameter family             = "Arria 10",
    parameter lut_mask           = 64'hAAAAAAAAAAAAAAAA,
    parameter dont_touch         = "on"
) ( 
    input wire      dataa,
    input wire      datab,
    input wire      datac,
    input wire      datad,
    output wire     combout
);
    
    wire gnd /*synthesis keep*/;
    assign gnd = 1'b0;

    generate
        if (family == "Arria 10")
        begin
            twentynm_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(gnd),
                    .dataf(gnd),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end // if (family == "Arria 10")
        else if (family == "Cyclone 10 GX")
        begin
            cyclone10gx_lcell_comb lcell_inst (
                    .dataa(dataa),
                    .datab(datab),
                    .datac(datac),
                    .datad(datad),
                    .datae(gnd),
                    .dataf(gnd),
                    .combout (combout));
            defparam lcell_inst.lut_mask = lut_mask;
            defparam lcell_inst.dont_touch = dont_touch;
        end
    endgenerate
endmodule

