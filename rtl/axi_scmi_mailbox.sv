// Copyright (c) 2022 ETH Zurich and University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
//

`include "../include/assign.svh"
`include "../include/typedef.svh"
`include "../include/axi_assign.svh"
`include "../include/axi_typedef.svh"

module axi_scmi_mailbox 
   import scmi_reg_pkg::*;
#(
   parameter int unsigned AXI_ADDR_WIDTH          = 64,
   parameter int unsigned AXI_SLV_PORT_DATA_WIDTH = 64,
   parameter type axi_lite_req_t                       = logic,
   parameter type axi_lite_resp_t                      = logic
)  (
   input  logic            clk_i, // Clock
   input  logic            rst_ni, // Asynchronous reset active low

   input  axi_lite_req_t   axi_mbox_req, 
   output axi_lite_resp_t  axi_mbox_rsp,
   
   output logic            irq_ariane_o, // interrupt output for Ariane
   output logic            irq_ibex_o
);
   parameter int unsigned  AXI_MST_PORT_DATA_WIDTH = 32;
    
   typedef logic [AXI_ADDR_WIDTH-1:0]            addr_t;
   typedef logic [AXI_MST_PORT_DATA_WIDTH-1:0]   data_t;
   typedef logic [AXI_MST_PORT_DATA_WIDTH/8-1:0] strb_t;
  
  `REG_BUS_TYPEDEF_REQ(reg_req_t, addr_t, data_t, strb_t)
  `REG_BUS_TYPEDEF_RSP(reg_rsp_t, data_t)
   
  `AXI_LITE_TYPEDEF_AW_CHAN_T(axi_lite_aw_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T (axi_lite_w_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T (axi_lite_b_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(axi_lite_ar_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T (axi_lite_r_t, data_t)
   
  `AXI_LITE_TYPEDEF_REQ_T    (axi_lite32_req_t, axi_lite_aw_t, axi_lite_w_t, axi_lite_ar_t)
  `AXI_LITE_TYPEDEF_RESP_T   (axi_lite32_resp_t, axi_lite_b_t, axi_lite_r_t)
   
   reg_req_t reg_req;
   reg_rsp_t reg_rsp;

   axi_lite32_req_t  axi32_mbox_req;
   axi_lite32_resp_t axi32_mbox_rsp;

   scmi_reg_pkg::scmi_reg2hw_t reg2hw;

   assign axi_mbox_rsp.ar_ready = axi32_mbox_rsp.ar_ready;
   assign axi32_mbox_req.ar.addr  = axi_mbox_req.ar.addr;
   assign axi32_mbox_req.ar_valid = axi_mbox_req.ar_valid;
   assign axi32_mbox_req.ar.prot  = axi_mbox_req.ar.prot;

   assign axi_mbox_rsp.aw_ready = axi32_mbox_rsp.aw_ready;
   assign axi32_mbox_req.aw.addr  = axi_mbox_req.aw.addr;
   assign axi32_mbox_req.aw_valid = axi_mbox_req.aw_valid;
   assign axi32_mbox_req.aw.prot  = axi_mbox_req.aw.prot;
 
   assign axi_mbox_rsp.w_ready = axi32_mbox_rsp.w_ready;
   assign axi32_mbox_req.w_valid = axi_mbox_req.w_valid;
   
   assign axi32_mbox_req.b_ready = axi_mbox_req.b_ready;
   assign axi_mbox_rsp.b.resp  = axi32_mbox_rsp.b.resp;
   assign axi_mbox_rsp.b_valid = axi32_mbox_rsp.b_valid;

   assign axi32_mbox_req.r_ready = axi_mbox_req.r_ready;
   assign axi_mbox_rsp.r.resp  = axi32_mbox_rsp.r.resp; 
   assign axi_mbox_rsp.r_valid = axi32_mbox_rsp.r_valid;
   
   assign irq_ibex_o   = reg2hw.doorbell.intr.q;
   assign irq_ariane_o = reg2hw.completion_interrupt.intr.q;
   
   always_comb begin : DataWidth_Conversion
      
     axi_mbox_rsp.r.data= '0;
     axi32_mbox_req.w.data = '0;
     axi32_mbox_req.w.strb = '0; 
         
     if(AXI_SLV_PORT_DATA_WIDTH > AXI_MST_PORT_DATA_WIDTH) begin
        axi_mbox_rsp.r.data[AXI_MST_PORT_DATA_WIDTH-1:0] = axi32_mbox_rsp.r.data;
        axi32_mbox_req.w.data = axi_mbox_req.w.data[AXI_MST_PORT_DATA_WIDTH-1:0];
        axi32_mbox_req.w.strb = axi_mbox_req.w.strb[AXI_MST_PORT_DATA_WIDTH/8-1:0];
        
     end else if(AXI_SLV_PORT_DATA_WIDTH  < AXI_MST_PORT_DATA_WIDTH) begin
        axi_mbox_rsp.r.data = axi32_mbox_rsp.r.data[AXI_SLV_PORT_DATA_WIDTH-1:0];
        axi32_mbox_req.w.data[AXI_SLV_PORT_DATA_WIDTH-1:0] = axi_mbox_req.w.data;
        axi32_mbox_req.w.strb[AXI_SLV_PORT_DATA_WIDTH-1:0] = axi_mbox_req.w.strb;
        
     end else if(AXI_SLV_PORT_DATA_WIDTH == AXI_MST_PORT_DATA_WIDTH) begin
        axi_mbox_rsp.r.data = axi32_mbox_rsp.r.data;
        axi32_mbox_req.w.data = axi_mbox_req.w.data;
        axi32_mbox_req.w.strb = axi_mbox_req.w.strb;
                  
     end
       
   end // block: DataWidth_Conversion

   axi_lite_to_reg #(
     .ADDR_WIDTH(AXI_ADDR_WIDTH),
     .DATA_WIDTH(AXI_MST_PORT_DATA_WIDTH),
     .BUFFER_DEPTH(1),
     .DECOUPLE_W(0),
     .axi_lite_req_t(axi_lite32_req_t),
     .axi_lite_rsp_t(axi_lite32_resp_t),
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_axi2reg_intf (
     .clk_i,
     .rst_ni,
     .axi_lite_req_i(axi32_mbox_req),
     .axi_lite_rsp_o(axi32_mbox_rsp),
     .reg_req_o(reg_req),
     .reg_rsp_i(reg_rsp)
   );

   scmi_reg_top #(
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_shared_memory (
     .clk_i,
     .rst_ni,
     .reg2hw,
     .reg_req_i(reg_req),
     .reg_rsp_o(reg_rsp),
     .devmode_i(1'b0)
   );


endmodule // axi_scmi_mailbox
