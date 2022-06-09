// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

`include "../include/axi_assign.svh"
`include "../include/axi_typedef.svh"

module mbox_tb #();

   import axi_pkg::*;

   localparam time TA   = 1ns;
   localparam time TT   = 2ns;
   localparam int unsigned RTC_CLOCK_PERIOD = 30.517us;

   logic rst_ni;
   logic clk_i;

   logic irq_ibex, irq_ariane;

   logic [63:0]  start_address = 64'h 0000000_00000000;
   logic [63:0]  end_address   = 64'h 0000000_00000024; 

   semaphore lock;

   parameter int   AW = 64;   
   parameter int   DW = 64;  
   parameter int   IW = 8;   
   parameter int   UW = 1;
   parameter bit   RAND_RESP = 0; 
   parameter int   AX_MIN_WAIT_CYCLES = 0;   
   parameter int   AX_MAX_WAIT_CYCLES = 1;   
   parameter int   W_MIN_WAIT_CYCLES = 0;   
   parameter int   W_MAX_WAIT_CYCLES = 1;   
   parameter int   RESP_MIN_WAIT_CYCLES = 0;
   parameter int   RESP_MAX_WAIT_CYCLES = 1;
   parameter int   NUM_BEATS = 100;

   localparam int unsigned SW = DW / 8;
   
   typedef logic [AW-1:0] axi_addr_t;
   typedef logic [DW-1:0] axi_data_t;
   typedef logic [IW-1:0] axi_id_t;
   typedef logic [SW-1:0] axi_strb_t;
   typedef logic [UW-1:0] axi_user_t;

   logic  aw_done, ar_done;
   
      
   typedef axi_test::axi_rand_master #(  
     .AW(AW),
     .DW(DW),
     .IW(IW),
     .UW(UW),
     .TA(TA),
     .TT(TT),
     .AX_MIN_WAIT_CYCLES(AX_MIN_WAIT_CYCLES),
     .AX_MAX_WAIT_CYCLES(AX_MAX_WAIT_CYCLES),
     .W_MIN_WAIT_CYCLES(W_MIN_WAIT_CYCLES),
     .W_MAX_WAIT_CYCLES(W_MAX_WAIT_CYCLES),
     .RESP_MIN_WAIT_CYCLES(RESP_MIN_WAIT_CYCLES),
     .RESP_MAX_WAIT_CYCLES(RESP_MAX_WAIT_CYCLES),
     .AXI_MAX_BURST_LEN (1),
     .AXI_BURST_FIXED(1),
     .AXI_BURST_INCR(0)
  ) axi_ran_master;
   
   AXI_BUS #(
     .AXI_ADDR_WIDTH(AW),
     .AXI_DATA_WIDTH(DW),
     .AXI_ID_WIDTH(IW),
     .AXI_USER_WIDTH(UW)
   ) axi_master ();

   AXI_BUS_DV #(
     .AXI_ADDR_WIDTH(AW),
     .AXI_DATA_WIDTH(DW),
     .AXI_ID_WIDTH(IW),
     .AXI_USER_WIDTH(UW)
   ) axi (clk_i);
   
   `AXI_TYPEDEF_AW_CHAN_T (axi_aw_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_W_CHAN_T  (axi_w_t, axi_data_t, axi_strb_t, axi_user_t)
   `AXI_TYPEDEF_B_CHAN_T  (axi_b_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_AR_CHAN_T (axi_ar_t, axi_addr_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_R_CHAN_T  (axi_r_t, axi_data_t, axi_id_t, axi_user_t)
   `AXI_TYPEDEF_REQ_T     (axi_req_t, axi_aw_t, axi_w_t, axi_ar_t)
   `AXI_TYPEDEF_RESP_T    (axi_resp_t, axi_b_t, axi_r_t)
   
   axi_req_t  axi_req_dec;
   axi_req_t  axi_req;
   axi_resp_t axi_rsp;
        
   axi_ran_master axi_rand_master = new(axi);
   
   `AXI_ASSIGN (axi_master, axi)

   `AXI_ASSIGN_TO_REQ     (axi_req, axi_master)
   `AXI_ASSIGN_FROM_RESP  (axi_master, axi_rsp)
   
 /////////////////////dut/////////////////////

   axi_scmi_mailbox #(
      .AXI_ADDR_WIDTH(64),
      .AXI_SLV_PORT_DATA_WIDTH(64),
      .axi_req_t(axi_req_t),
      .axi_resp_t(axi_resp_t)
   ) u_scmi_shared_memory (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .axi_mbox_req(axi_req_dec),
      .axi_mbox_rsp(axi_rsp),
      .irq_ibex_o(irq_ibex),
      .irq_ariane_o(irq_ariane)
   );

 /////////////////////////////////////////////
   
   initial begin  : clock_rst_process
    lock = new(1);
    clk_i  = 1'b0;
    rst_ni = 1'b0;
    repeat (10)
      #(RTC_CLOCK_PERIOD/2) clk_i = 1'b0;
      rst_ni = 1'b1;
    forever
      #(RTC_CLOCK_PERIOD/2) clk_i = ~clk_i;
   end

   assign axi_req_dec.aw_valid  = axi_req.aw_valid;
   assign axi_req_dec.ar_valid  = axi_req.ar_valid;
   assign axi_req_dec.b_ready   = axi_req.b_ready;
   assign axi_req_dec.r_ready   = axi_req.r_ready;
   assign axi_req_dec.w_valid   = axi_req.w_valid;

   assign axi_req_dec.w.data    = axi_req.w.data;
   assign axi_req_dec.w.strb    = axi_req.w.strb;
   assign axi_req_dec.w.last    = axi_req.w.last;
   assign axi_req_dec.w.user    = axi_req.w.user;

   assign axi_req_dec.ar.id     = axi_req.ar.id;
   //assign axi_req_dec.ar.addr   = 32'h 00000004;
   assign axi_req_dec.ar.len    = axi_req.ar.len;
   assign axi_req_dec.ar.size   = axi_req.ar.size; 
   assign axi_req_dec.ar.burst  = axi_req.ar.burst;//axi_pkg::BURST_INCR;//
   assign axi_req_dec.ar.lock   = axi_req.ar.lock;
   assign axi_req_dec.ar.cache  = axi_req.ar.cache;
   assign axi_req_dec.ar.prot   = axi_req.ar.prot;
   assign axi_req_dec.ar.qos    = axi_req.ar.qos;
   assign axi_req_dec.ar.region = axi_req.ar.region;
   assign axi_req_dec.ar.user   = axi_req.ar.user;

   assign axi_req_dec.aw.id     = axi_req.aw.id;
   //assign axi_req_dec.aw.addr   = 32'h 00000004;
   assign axi_req_dec.aw.len    = axi_req.aw.len;
   assign axi_req_dec.aw.size   = axi_req.aw.size; 
   assign axi_req_dec.aw.burst  = axi_req.aw.burst;//axi_pkg::BURST_INCR;//
   assign axi_req_dec.aw.lock   = axi_req.aw.lock;
   assign axi_req_dec.aw.cache  = axi_req.aw.cache;
   assign axi_req_dec.aw.prot   = axi_req.aw.prot;
   assign axi_req_dec.aw.qos    = axi_req.aw.qos;
   assign axi_req_dec.aw.region = axi_req.aw.region;
   assign axi_req_dec.aw.atop   = axi_req.aw.atop;
   assign axi_req_dec.aw.user   = axi_req.aw.user;
  
   always_comb begin :read_addr_decode //(maps 64bit rnd addr into the 9 regs addr)
    if(~rst_ni)
      axi_req_dec.ar.addr <= '0;
    else begin
      if(axi_req.ar.addr[3:0] <= 4'h 1)
        axi_req_dec.ar.addr = 64'h 0000000000000000;
      else if(axi_req.ar.addr[3:0] <= 4'h 2)
        axi_req_dec.ar.addr = 64'h 0000000000000004;
      else if(axi_req.ar.addr[3:0] <= 4'h 3)
        axi_req_dec.ar.addr = 64'h 000000000000000C;
      else if(axi_req.ar.addr[3:0] <= 4'h 4)
        axi_req_dec.ar.addr = 64'h 0000000000000008;
      else if(axi_req.ar.addr[3:0] <= 4'h 5)
        axi_req_dec.ar.addr = 64'h 0000000000000010;
      else if(axi_req.ar.addr[3:0] <= 4'h 6)
        axi_req_dec.ar.addr = 64'h 0000000000000014;
      else if(axi_req.ar.addr[3:0] <= 4'h 7)
        axi_req_dec.ar.addr = 64'h 0000000000000018; 
      else if(axi_req.ar.addr[3:0] <= 4'h 8)
        axi_req_dec.ar.addr = 64'h 000000000000001C;
      else if(axi_req.ar.addr[3:0] <= 4'h 9)
        axi_req_dec.ar.addr = 64'h 0000000000000020;
      else
        axi_req_dec.ar.addr = 64'h 0000000000000024;
     end
   end // block: read_addr_decode

      always_comb begin :write_addr_decode //(maps 64bit rnd addr into the 10 regs addr)
    if(~rst_ni)
      axi_req_dec.aw.addr <= '0;
    else begin
      if(axi_req.aw.addr[3:0] <= 4'h 1)
        axi_req_dec.aw.addr = 64'h 0000000000000000;
      else if(axi_req.aw.addr[3:0] <= 4'h 2)
        axi_req_dec.aw.addr = 64'h 0000000000000008;
      else if(axi_req.aw.addr[3:0] <= 4'h 3)
        axi_req_dec.aw.addr = 64'h 0000000000000004;
      else if(axi_req.aw.addr[3:0] <= 4'h 4)
        axi_req_dec.aw.addr = 64'h 000000000000000C;
      else if(axi_req.aw.addr[3:0] <= 4'h 5)
        axi_req_dec.aw.addr = 64'h 0000000000000010;
      else if(axi_req.aw.addr[3:0] <= 4'h 6)
        axi_req_dec.aw.addr = 64'h 0000000000000014;
      else if(axi_req.aw.addr[3:0] <= 4'h 7)
        axi_req_dec.aw.addr = 64'h 0000000000000018; 
      else if(axi_req.aw.addr[3:0] <= 4'h 8)
        axi_req_dec.aw.addr = 64'h 000000000000001C;
      else if(axi_req.aw.addr[3:0] <= 4'h 9)
        axi_req_dec.aw.addr = 64'h 0000000000000020;
      else
        axi_req_dec.aw_addr = 64'h 0000000000000024;
     end
   end
   
   initial begin  : axi_master_process
      
    @(posedge rst_ni);
      
    axi_rand_master.reset();
      
    repeat ($urandom_range(10,15)) @(posedge clk_i);
    axi_rand_master.add_memory_region(64'h 0000000000000000, 64'h 0000000000000010, axi_pkg::DEVICE_NONBUFFERABLE); // NORMAL_NONCACHEABLE_BUFFERABLE);
    repeat ($urandom_range(10,15)) @(posedge clk_i);

    //axi_rand_master.run(NUM_BEATS, NUM_BEATS);
      
    ar_done = 1'b0;  
    aw_done = 1'b0;
      

    fork
      begin
        axi_rand_master.create_aws(NUM_BEATS);
        aw_done = 1'b1;
      end
      axi_rand_master.send_aws(aw_done);
      axi_rand_master.send_ws(aw_done);
      axi_rand_master.recv_bs(aw_done);
    join

    repeat ($urandom_range(10,15)) @(posedge clk_i);
      
    fork
      begin
       axi_rand_master.send_ars(NUM_BEATS);
       ar_done = 1'b1;
      end
      axi_rand_master.recv_rs(ar_done, aw_done);
    join
      
    repeat ($urandom_range(10,15)) @(posedge clk_i);
    $finish;
      
   end
   
endmodule
  
