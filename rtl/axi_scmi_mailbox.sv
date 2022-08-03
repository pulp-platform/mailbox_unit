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

`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"
`include "axi/assign.svh"
`include "axi/typedef.svh"

module axi_scmi_mailbox 
   import scmi_reg_pkg::*;
#(
   parameter int unsigned AXI_ADDR_WIDTH = 64,
   parameter type axi_lite_req_t         = logic,
   parameter type axi_lite_resp_t        = logic
)  (
   input  logic            clk_i, 
   input  logic            rst_ni, 

   input  axi_lite_req_t   axi_mbox_req, 
   output axi_lite_resp_t  axi_mbox_rsp,
   
   output logic            doorbell_irq_o, 
   output logic            completion_irq_o
);
   parameter int unsigned  AXI_DATA_WIDTH = 32;
    
   typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
   typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
   typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;

   logic [3:0]                          unused;
   
  
  `REG_BUS_TYPEDEF_REQ(reg_req_t, addr_t, data_t, strb_t)
  `REG_BUS_TYPEDEF_RSP(reg_rsp_t, data_t)
   
   reg_req_t reg_req;
   reg_rsp_t reg_rsp;

   scmi_reg_pkg::scmi_reg2hw_t reg2hw;

   sync_wedge #(
     .STAGES(2)
   ) doorbell_synch (
     .clk_i,
     .rst_ni,  
     .en_i(1'b1),  
     .serial_i(reg2hw.doorbell.intr.q),// && reg2hw.channel_flags.intr_enable.q),
     .r_edge_o(doorbell_irq_o),
     .f_edge_o(unused[0]),
     .serial_o(unused[1])
   );

   sync_wedge #(
     .STAGES(2)
   ) completion_synch (
     .clk_i,
     .rst_ni,  
     .en_i(1'b1),  
     .serial_i(reg2hw.completion_interrupt.intr.q),// && reg2hw.channel_flags.intr_enable.q),
     .r_edge_o(completion_irq_o),
     .f_edge_o(unused[2]),
     .serial_o(unused[3])
   );
   
   axi_lite_to_reg #(
     .ADDR_WIDTH(AXI_ADDR_WIDTH),
     .DATA_WIDTH(AXI_DATA_WIDTH),
     .BUFFER_DEPTH(1),
     .DECOUPLE_W(0),
     .axi_lite_req_t(axi_lite_req_t),
     .axi_lite_rsp_t(axi_lite_resp_t),
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_axi2reg_intf (
     .clk_i,
     .rst_ni,
     .axi_lite_req_i(axi_mbox_req),
     .axi_lite_rsp_o(axi_mbox_rsp),
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
