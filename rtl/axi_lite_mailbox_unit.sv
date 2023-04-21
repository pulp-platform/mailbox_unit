// Copyright (c) 2023 ETH Zurich and University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Maicol Ciani <maicol.ciani@unibo.it>
// Robert Balas <balasr@iis.ee.ethz.ch>

// Convenience Wrapper for AXI Lite

`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"
`include "axi/assign.svh"
`include "axi/typedef.svh"

module axi_lite_mailbox_unit import mailbox_reg_pkg::*; #(
  parameter int unsigned AXI_ADDR_WIDTH = 64,
  parameter type         axi_lite_req_t = logic,
  parameter type         axi_lite_resp_t = logic,
  parameter int unsigned NumMbox = 4,
  parameter bit          AlignPage = 0 // whether mailboxes addresses should be 4k aligned
)(
  input logic                clk_i,
  input logic                rst_ni,

  input  axi_lite_req_t      axi_lite_req_i,
  output axi_lite_resp_t     axi_lite_rsp_o,

  output logic [NumMbox-1:0] snd_irq_o,
  output logic [NumMbox-1:0] rcv_irq_o
);

  localparam int unsigned  AXI_DATA_WIDTH = 32;

  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;


  `REG_BUS_TYPEDEF_REQ(reg_req_t, addr_t, data_t, strb_t)
  `REG_BUS_TYPEDEF_RSP(reg_rsp_t, data_t)

  reg_req_t reg_req;
  reg_rsp_t reg_rsp;

  axi_lite_to_reg #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .BUFFER_DEPTH(1),
    .DECOUPLE_W(0),
    .axi_lite_req_t(axi_lite_req_t),
    .axi_lite_rsp_t(axi_lite_resp_t),
    .reg_req_t(reg_req_t),
    .reg_rsp_t(reg_rsp_t)
  ) i_axi_lite_to_reg (
    .clk_i,
    .rst_ni,
    .axi_lite_req_i,
    .axi_lite_rsp_o,
    .reg_req_o(reg_req),
    .reg_rsp_i(reg_rsp)
  );

  mailbox_unit #(
    .reg_req_t(reg_req_t),
    .reg_rsp_t(reg_rsp_t),
    .NumMbox  (NumMbox),
    .AlignPage(AlignPage)  // whether mailboxes addresses should be 4k aligned
  ) i_mailbox_unit (
    .clk_i,
    .rst_ni,
    .reg_req_i(reg_req),
    .reg_rsp_o(reg_rsp),
    .snd_irq_o,
    .rcv_irq_o
  );

endmodule // axi_lite_mailbox_unit
