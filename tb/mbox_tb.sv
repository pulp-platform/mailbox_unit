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

   semaphore lock;

   parameter int   AW = 64;   
   parameter int   DW = 64;  
   parameter int   AX_MIN_WAIT_CYCLES = 0;   
   parameter int   AX_MAX_WAIT_CYCLES = 1;   
   parameter int   W_MIN_WAIT_CYCLES = 0;   
   parameter int   W_MAX_WAIT_CYCLES = 1;   
   parameter int   RESP_MIN_WAIT_CYCLES = 0;
   parameter int   RESP_MAX_WAIT_CYCLES = 1;
   parameter int   NUM_BEATS = 100;

   localparam int unsigned SW = DW / 8;
   
   typedef logic [AW-1:0] addr_t;
   typedef logic [DW-1:0] data_t;
   typedef logic [SW-1:0] strb_t;
      
   typedef axi_test::axi_lite_rand_master #(  
     .AW(AW),
     .DW(DW),
     .TA(TA),
     .TT(TT),
     .AX_MIN_WAIT_CYCLES(AX_MIN_WAIT_CYCLES),
     .AX_MAX_WAIT_CYCLES(AX_MAX_WAIT_CYCLES),
     .W_MIN_WAIT_CYCLES(W_MIN_WAIT_CYCLES),
     .W_MAX_WAIT_CYCLES(W_MAX_WAIT_CYCLES),
     .RESP_MIN_WAIT_CYCLES(RESP_MIN_WAIT_CYCLES),
     .RESP_MAX_WAIT_CYCLES(RESP_MAX_WAIT_CYCLES),
     .MIN_ADDR(32'h 00000000),
     .MAX_ADDR(32'h 0000000A)
  ) axi_lite_ran_master;
   
   AXI_LITE #(
     .AXI_ADDR_WIDTH(AW),
     .AXI_DATA_WIDTH(DW)
   ) axi_lite_master ();

   AXI_LITE_DV #(
     .AXI_ADDR_WIDTH(AW),
     .AXI_DATA_WIDTH(DW)
   ) axi_lite (clk_i);
   
   `AXI_LITE_TYPEDEF_AW_CHAN_T (axi_lite_aw_t, addr_t)
   `AXI_LITE_TYPEDEF_W_CHAN_T  (axi_lite_w_t, data_t, strb_t)
   `AXI_LITE_TYPEDEF_B_CHAN_T  (axi_lite_b_t)
   `AXI_LITE_TYPEDEF_AR_CHAN_T (axi_lite_ar_t, addr_t)
   `AXI_LITE_TYPEDEF_R_CHAN_T  (axi_lite_r_t, data_t)
   
   `AXI_LITE_TYPEDEF_REQ_T     (axi_lite_req_t, axi_lite_aw_t, axi_lite_w_t, axi_lite_ar_t)
   `AXI_LITE_TYPEDEF_RESP_T    (axi_lite_resp_t, axi_lite_b_t, axi_lite_r_t)
   
   axi_lite_req_t  axi_lite_req_dec; //this is a struct driven by the master execpt for the address, that is driven by a decoder (mst addrs are not aligned)
   axi_lite_req_t  axi_lite_req;
   axi_lite_resp_t axi_lite_rsp;
        
   axi_lite_ran_master axi_lite_rand_master = new(axi_lite, "testing");
   
   `AXI_LITE_ASSIGN (axi_lite_master, axi_lite)

   `AXI_LITE_ASSIGN_TO_REQ     (axi_lite_req, axi_lite_master)
   `AXI_LITE_ASSIGN_FROM_RESP  (axi_lite_master, axi_lite_rsp)
   
   
   assign axi_lite_req_dec.w_valid = axi_lite_req.w_valid;
   assign axi_lite_req_dec.w.data  = axi_lite_req.w.data;
   
   // strobe must be always 4'b1111, regfile is protected against partial writes. This cannot be imposed to the rand master class, it must be fixed
   assign axi_lite_req_dec.w.strb  = 4'h F;
   
   assign axi_lite_req_dec.b_ready = axi_lite_req.b_ready;
   
   assign axi_lite_req_dec.r_ready = axi_lite_req.r_ready;
  
   assign axi_lite_req_dec.ar.prot  = axi_lite_req.ar.prot;
   assign axi_lite_req_dec.ar_valid = axi_lite_req.ar_valid;
   assign axi_lite_req.ar_ready     = axi_lite_req_dec.ar_ready;

   assign axi_lite_req_dec.aw.prot  = axi_lite_req.aw.prot;
   assign axi_lite_req_dec.aw_valid = axi_lite_req.aw_valid;
   assign axi_lite_req.aw_ready     = axi_lite_req_dec.aw_ready;
   
     
 /////////////////////dut/////////////////////

   axi_scmi_mailbox #(
      .AXI_ADDR_WIDTH(64),
      .AXI_SLV_PORT_DATA_WIDTH(64),
      .axi_lite_req_t(axi_lite_req_t),
      .axi_lite_resp_t(axi_lite_resp_t)
   ) u_dut (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .axi_mbox_req(axi_lite_req_dec),
      .axi_mbox_rsp(axi_lite_rsp),
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

   // The random address provided by the rand master is not aligned, thus the following "decoder" from 0->10 to the offsets
   
   always_comb begin :read_addr_decode //(maps 64bit rnd addr into the 10 regs addr)
    if(~rst_ni)
      axi_lite_req_dec.ar.addr = '0;
    else begin
      if(axi_lite_req.ar.addr[3:0] <= 4'h 1)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000000;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 2)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000004;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 3)
        axi_lite_req_dec.ar.addr = 64'h 000000000000000C;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 4)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000008;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 5)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000010;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 6)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000014;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 7)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000018; 
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 8)
        axi_lite_req_dec.ar.addr = 64'h 000000000000001C;
      else if(axi_lite_req.ar.addr[3:0] <= 4'h 9)
        axi_lite_req_dec.ar.addr = 64'h 0000000000000020;
      else
        axi_lite_req_dec.ar.addr = 64'h 0000000000000024;
     end
   end // block: read_addr_decode

   always_comb begin :write_addr_decode //(maps 64bit rnd addr into the 10 regs addr)
    if(~rst_ni)
      axi_lite_req_dec.aw.addr = '0;
    else begin
      if(axi_lite_req.aw.addr[3:0] <= 4'h 1)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000000;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 2)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000008;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 3)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000004;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 4)
        axi_lite_req_dec.aw.addr = 64'h 000000000000000C;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 5)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000010;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 6)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000014;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 7)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000018; 
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 8)
        axi_lite_req_dec.aw.addr = 64'h 000000000000001C;
      else if(axi_lite_req.aw.addr[3:0] <= 4'h 9)
        axi_lite_req_dec.aw.addr = 64'h 0000000000000020;
      else
        axi_lite_req_dec.aw_addr = 64'h 0000000000000024;
     end
   end
   
   initial begin  : axi_lite_master_process
      
     @(posedge rst_ni);

     repeat ($urandom_range(10,15)) @(posedge clk_i);
     axi_lite_rand_master.reset();  
     repeat ($urandom_range(10,15)) @(posedge clk_i);
  
     $display("Run for Reads %0d, Writes %0d", NUM_BEATS, NUM_BEATS);
      
     fork
       axi_lite_rand_master.send_aws(NUM_BEATS);
       axi_lite_rand_master.send_ws (NUM_BEATS);
       axi_lite_rand_master.recv_bs (NUM_BEATS);
     join

     repeat ($urandom_range(10,15)) @(posedge clk_i);
      
     fork
       axi_lite_rand_master.send_ars(NUM_BEATS);   
       axi_lite_rand_master.recv_rs (NUM_BEATS);
     join
      
     repeat ($urandom_range(10,15)) @(posedge clk_i);
     $finish;
      
   end
   
endmodule
  
