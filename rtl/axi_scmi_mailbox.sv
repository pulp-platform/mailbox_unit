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


`include "axi/assign.svh"
`include "axi/typedef.svh"
`include "register_interface/typedef.svh"
`include "register_interface/assign.svh"

module axi_scmi_mailbox
  import scmi_reg_pkg::*;
#(
  parameter int unsigned NumChannels             = 1,
  parameter int unsigned AxiIdWidth              = 8,
  parameter int unsigned AxiAddrWidth            = 64,
  parameter int unsigned AxiSlvPortDataWidth     = 64,
  parameter int unsigned AxiUserWidth            = 1,
  parameter int unsigned AxiMaxReads             = 1,
  parameter type axi_req_t                       = logic,
  parameter type axi_resp_t                      = logic,
  localparam int unsigned AxiMstPortDataWidth = 32
) (
  input  logic       clk_i, // Clock
  input  logic       rst_ni, // Asynchronous reset active low

  input  axi_req_t   axi_mbox_req,
  output axi_resp_t  axi_mbox_rsp,

  output [NumChannels-1:0]        irq_completion_o, // completion interrupt platform to agent
  output [NumChannels-1:0]        irq_doorbell_o    // doorbell interrupt agent to platform
);

  typedef logic [AxiAddrWidth-1:0]            addr_t;
  typedef logic [AxiMstPortDataWidth-1:0]   data_t;
  typedef logic [AxiMstPortDataWidth/8-1:0] strb_t;

  typedef logic [AxiIdWidth-1:0] id_t                   ;
  typedef logic [AxiMstPortDataWidth-1:0] mst_data_t  ;
  typedef logic [AxiMstPortDataWidth/8-1:0] mst_strb_t;
  typedef logic [AxiSlvPortDataWidth-1:0] slv_data_t  ;
  typedef logic [AxiSlvPortDataWidth/8-1:0] slv_strb_t;
  typedef logic [AxiUserWidth-1:0] user_t               ;


  `REG_BUS_TYPEDEF_REQ(reg_req_t, addr_t, data_t, strb_t)
  `REG_BUS_TYPEDEF_RSP(reg_rsp_t, data_t)

  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(mst_w_chan_t, mst_data_t, mst_strb_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(slv_w_chan_t, slv_data_t, slv_strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(mst_r_chan_t, mst_data_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(slv_r_chan_t, slv_data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(mst_req_t, aw_chan_t, mst_w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(mst_resp_t, b_chan_t, mst_r_chan_t)
  `AXI_TYPEDEF_REQ_T(slv_req_t, aw_chan_t, slv_w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(slv_resp_t, b_chan_t, slv_r_chan_t)

  reg_req_t reg_req;
  reg_rsp_t reg_rsp;

  mst_req_t  axi32_mbox_req;
  mst_resp_t axi32_mbox_rsp;

  scmi_reg_pkg::scmi_reg2hw_t reg2hw;

  assign irq_doorbell_o[0]   = reg2hw.doorbell_c0.intr.q;
  assign irq_completion_o[0] = reg2hw.completion_interrupt_c0.intr.q;
  assign irq_doorbell_o[1]   = reg2hw.doorbell_c1.intr.q;
  assign irq_completion_o[1] = reg2hw.completion_interrupt_c1.intr.q;
  assign irq_doorbell_o[2]   = reg2hw.doorbell_c2.intr.q;
  assign irq_completion_o[2] = reg2hw.completion_interrupt_c2.intr.q;
  assign irq_doorbell_o[3]   = reg2hw.doorbell_c3.intr.q;
  assign irq_completion_o[3] = reg2hw.completion_interrupt_c3.intr.q;
  assign irq_doorbell_o[4]   = reg2hw.doorbell_c4.intr.q;
  assign irq_completion_o[4] = reg2hw.completion_interrupt_c4.intr.q;
  assign irq_doorbell_o[5]   = reg2hw.doorbell_c5.intr.q;
  assign irq_completion_o[5] = reg2hw.completion_interrupt_c5.intr.q;
  assign irq_doorbell_o[6]   = reg2hw.doorbell_c6.intr.q;
  assign irq_completion_o[6] = reg2hw.completion_interrupt_c6.intr.q;
  assign irq_doorbell_o[7]   = reg2hw.doorbell_c7.intr.q;
  assign irq_completion_o[7] = reg2hw.completion_interrupt_c7.intr.q;
  assign irq_doorbell_o[8]   = reg2hw.doorbell_c8.intr.q;
  assign irq_completion_o[8] = reg2hw.completion_interrupt_c8.intr.q;
  assign irq_doorbell_o[9]   = reg2hw.doorbell_c9.intr.q;
  assign irq_completion_o[9] = reg2hw.completion_interrupt_c9.intr.q;
  assign irq_doorbell_o[10]   = reg2hw.doorbell_c10.intr.q;
  assign irq_completion_o[10] = reg2hw.completion_interrupt_c10.intr.q;
  assign irq_doorbell_o[11]   = reg2hw.doorbell_c11.intr.q;
  assign irq_completion_o[11] = reg2hw.completion_interrupt_c11.intr.q;
  assign irq_doorbell_o[12]   = reg2hw.doorbell_c12.intr.q;
  assign irq_completion_o[12] = reg2hw.completion_interrupt_c12.intr.q;
  assign irq_doorbell_o[13]   = reg2hw.doorbell_c13.intr.q;
  assign irq_completion_o[13] = reg2hw.completion_interrupt_c13.intr.q;
  assign irq_doorbell_o[14]   = reg2hw.doorbell_c14.intr.q;
  assign irq_completion_o[14] = reg2hw.completion_interrupt_c14.intr.q;
  assign irq_doorbell_o[15]   = reg2hw.doorbell_c15.intr.q;
  assign irq_completion_o[15] = reg2hw.completion_interrupt_c15.intr.q;
  assign irq_doorbell_o[16]   = reg2hw.doorbell_c16.intr.q;
  assign irq_completion_o[16] = reg2hw.completion_interrupt_c16.intr.q;
  assign irq_doorbell_o[17]   = reg2hw.doorbell_c17.intr.q;
  assign irq_completion_o[17] = reg2hw.completion_interrupt_c17.intr.q;
  assign irq_doorbell_o[18]   = reg2hw.doorbell_c18.intr.q;
  assign irq_completion_o[18] = reg2hw.completion_interrupt_c18.intr.q;
  assign irq_doorbell_o[19]   = reg2hw.doorbell_c19.intr.q;
  assign irq_completion_o[19] = reg2hw.completion_interrupt_c19.intr.q;
  assign irq_doorbell_o[20]   = reg2hw.doorbell_c20.intr.q;
  assign irq_completion_o[20] = reg2hw.completion_interrupt_c20.intr.q;
  assign irq_doorbell_o[21]   = reg2hw.doorbell_c21.intr.q;
  assign irq_completion_o[21] = reg2hw.completion_interrupt_c21.intr.q;
  assign irq_doorbell_o[22]   = reg2hw.doorbell_c22.intr.q;
  assign irq_completion_o[22] = reg2hw.completion_interrupt_c22.intr.q;
  assign irq_doorbell_o[23]   = reg2hw.doorbell_c23.intr.q;
  assign irq_completion_o[23] = reg2hw.completion_interrupt_c23.intr.q;
  assign irq_doorbell_o[24]   = reg2hw.doorbell_c24.intr.q;
  assign irq_completion_o[24] = reg2hw.completion_interrupt_c24.intr.q;
  assign irq_doorbell_o[25]   = reg2hw.doorbell_c25.intr.q;
  assign irq_completion_o[25] = reg2hw.completion_interrupt_c25.intr.q;
  assign irq_doorbell_o[26]   = reg2hw.doorbell_c26.intr.q;
  assign irq_completion_o[26] = reg2hw.completion_interrupt_c26.intr.q;
  assign irq_doorbell_o[27]   = reg2hw.doorbell_c27.intr.q;
  assign irq_completion_o[27] = reg2hw.completion_interrupt_c27.intr.q;
  assign irq_doorbell_o[28]   = reg2hw.doorbell_c28.intr.q;
  assign irq_completion_o[28] = reg2hw.completion_interrupt_c28.intr.q;
  assign irq_doorbell_o[29]   = reg2hw.doorbell_c29.intr.q;
  assign irq_completion_o[29] = reg2hw.completion_interrupt_c29.intr.q;
  assign irq_doorbell_o[30]   = reg2hw.doorbell_c30.intr.q;
  assign irq_completion_o[30] = reg2hw.completion_interrupt_c30.intr.q;
  assign irq_doorbell_o[31]   = reg2hw.doorbell_c31.intr.q;
  assign irq_completion_o[31] = reg2hw.completion_interrupt_c31.intr.q;
  assign irq_doorbell_o[32]   = reg2hw.doorbell_c32.intr.q;
  assign irq_completion_o[32] = reg2hw.completion_interrupt_c32.intr.q;
  assign irq_doorbell_o[33]   = reg2hw.doorbell_c33.intr.q;
  assign irq_completion_o[33] = reg2hw.completion_interrupt_c33.intr.q;
  assign irq_doorbell_o[34]   = reg2hw.doorbell_c34.intr.q;
  assign irq_completion_o[34] = reg2hw.completion_interrupt_c34.intr.q;
  assign irq_doorbell_o[35]   = reg2hw.doorbell_c35.intr.q;
  assign irq_completion_o[35] = reg2hw.completion_interrupt_c35.intr.q;
  assign irq_doorbell_o[36]   = reg2hw.doorbell_c36.intr.q;
  assign irq_completion_o[36] = reg2hw.completion_interrupt_c36.intr.q;
  assign irq_doorbell_o[37]   = reg2hw.doorbell_c37.intr.q;
  assign irq_completion_o[37] = reg2hw.completion_interrupt_c37.intr.q;
  assign irq_doorbell_o[38]   = reg2hw.doorbell_c38.intr.q;
  assign irq_completion_o[38] = reg2hw.completion_interrupt_c38.intr.q;
  assign irq_doorbell_o[39]   = reg2hw.doorbell_c39.intr.q;
  assign irq_completion_o[39] = reg2hw.completion_interrupt_c39.intr.q;
  assign irq_doorbell_o[40]   = reg2hw.doorbell_c40.intr.q;
  assign irq_completion_o[40] = reg2hw.completion_interrupt_c40.intr.q;
  assign irq_doorbell_o[41]   = reg2hw.doorbell_c41.intr.q;
  assign irq_completion_o[41] = reg2hw.completion_interrupt_c41.intr.q;
  assign irq_doorbell_o[42]   = reg2hw.doorbell_c42.intr.q;
  assign irq_completion_o[42] = reg2hw.completion_interrupt_c42.intr.q;
  assign irq_doorbell_o[43]   = reg2hw.doorbell_c43.intr.q;
  assign irq_completion_o[43] = reg2hw.completion_interrupt_c43.intr.q;
  assign irq_doorbell_o[44]   = reg2hw.doorbell_c44.intr.q;
  assign irq_completion_o[44] = reg2hw.completion_interrupt_c44.intr.q;
  assign irq_doorbell_o[45]   = reg2hw.doorbell_c45.intr.q;
  assign irq_completion_o[45] = reg2hw.completion_interrupt_c45.intr.q;
  assign irq_doorbell_o[46]   = reg2hw.doorbell_c46.intr.q;
  assign irq_completion_o[46] = reg2hw.completion_interrupt_c46.intr.q;
  assign irq_doorbell_o[47]   = reg2hw.doorbell_c47.intr.q;
  assign irq_completion_o[47] = reg2hw.completion_interrupt_c47.intr.q;
  assign irq_doorbell_o[48]   = reg2hw.doorbell_c48.intr.q;
  assign irq_completion_o[48] = reg2hw.completion_interrupt_c48.intr.q;
  assign irq_doorbell_o[49]   = reg2hw.doorbell_c49.intr.q;
  assign irq_completion_o[49] = reg2hw.completion_interrupt_c49.intr.q;
  assign irq_doorbell_o[50]   = reg2hw.doorbell_c50.intr.q;
  assign irq_completion_o[50] = reg2hw.completion_interrupt_c50.intr.q;
  assign irq_doorbell_o[51]   = reg2hw.doorbell_c51.intr.q;
  assign irq_completion_o[51] = reg2hw.completion_interrupt_c51.intr.q;
  assign irq_doorbell_o[52]   = reg2hw.doorbell_c52.intr.q;
  assign irq_completion_o[52] = reg2hw.completion_interrupt_c52.intr.q;
  assign irq_doorbell_o[53]   = reg2hw.doorbell_c53.intr.q;
  assign irq_completion_o[53] = reg2hw.completion_interrupt_c53.intr.q;
  assign irq_doorbell_o[54]   = reg2hw.doorbell_c54.intr.q;
  assign irq_completion_o[54] = reg2hw.completion_interrupt_c54.intr.q;
  assign irq_doorbell_o[55]   = reg2hw.doorbell_c55.intr.q;
  assign irq_completion_o[55] = reg2hw.completion_interrupt_c55.intr.q;
  assign irq_doorbell_o[56]   = reg2hw.doorbell_c56.intr.q;
  assign irq_completion_o[56] = reg2hw.completion_interrupt_c56.intr.q;
  assign irq_doorbell_o[57]   = reg2hw.doorbell_c57.intr.q;
  assign irq_completion_o[57] = reg2hw.completion_interrupt_c57.intr.q;
  assign irq_doorbell_o[58]   = reg2hw.doorbell_c58.intr.q;
  assign irq_completion_o[58] = reg2hw.completion_interrupt_c58.intr.q;
  assign irq_doorbell_o[59]   = reg2hw.doorbell_c59.intr.q;
  assign irq_completion_o[59] = reg2hw.completion_interrupt_c59.intr.q;
  assign irq_doorbell_o[60]   = reg2hw.doorbell_c60.intr.q;
  assign irq_completion_o[60] = reg2hw.completion_interrupt_c60.intr.q;
  assign irq_doorbell_o[61]   = reg2hw.doorbell_c61.intr.q;
  assign irq_completion_o[61] = reg2hw.completion_interrupt_c61.intr.q;
  assign irq_doorbell_o[62]   = reg2hw.doorbell_c62.intr.q;
  assign irq_completion_o[62] = reg2hw.completion_interrupt_c62.intr.q;
  assign irq_doorbell_o[63]   = reg2hw.doorbell_c63.intr.q;
  assign irq_completion_o[63] = reg2hw.completion_interrupt_c63.intr.q;
  assign irq_doorbell_o[64]   = reg2hw.doorbell_c64.intr.q;
  assign irq_completion_o[64] = reg2hw.completion_interrupt_c64.intr.q;
  assign irq_doorbell_o[65]   = reg2hw.doorbell_c65.intr.q;
  assign irq_completion_o[65] = reg2hw.completion_interrupt_c65.intr.q;
  assign irq_doorbell_o[66]   = reg2hw.doorbell_c66.intr.q;
  assign irq_completion_o[66] = reg2hw.completion_interrupt_c66.intr.q;
  assign irq_doorbell_o[67]   = reg2hw.doorbell_c67.intr.q;
  assign irq_completion_o[67] = reg2hw.completion_interrupt_c67.intr.q;
  assign irq_doorbell_o[68]   = reg2hw.doorbell_c68.intr.q;
  assign irq_completion_o[68] = reg2hw.completion_interrupt_c68.intr.q;
  assign irq_doorbell_o[69]   = reg2hw.doorbell_c69.intr.q;
  assign irq_completion_o[69] = reg2hw.completion_interrupt_c69.intr.q;
  assign irq_doorbell_o[70]   = reg2hw.doorbell_c70.intr.q;
  assign irq_completion_o[70] = reg2hw.completion_interrupt_c70.intr.q;
  assign irq_doorbell_o[71]   = reg2hw.doorbell_c71.intr.q;
  assign irq_completion_o[71] = reg2hw.completion_interrupt_c71.intr.q;
  assign irq_doorbell_o[72]   = reg2hw.doorbell_c72.intr.q;
  assign irq_completion_o[72] = reg2hw.completion_interrupt_c72.intr.q;
  assign irq_doorbell_o[73]   = reg2hw.doorbell_c73.intr.q;
  assign irq_completion_o[73] = reg2hw.completion_interrupt_c73.intr.q;
  assign irq_doorbell_o[74]   = reg2hw.doorbell_c74.intr.q;
  assign irq_completion_o[74] = reg2hw.completion_interrupt_c74.intr.q;
  assign irq_doorbell_o[75]   = reg2hw.doorbell_c75.intr.q;
  assign irq_completion_o[75] = reg2hw.completion_interrupt_c75.intr.q;
  assign irq_doorbell_o[76]   = reg2hw.doorbell_c76.intr.q;
  assign irq_completion_o[76] = reg2hw.completion_interrupt_c76.intr.q;
  assign irq_doorbell_o[77]   = reg2hw.doorbell_c77.intr.q;
  assign irq_completion_o[77] = reg2hw.completion_interrupt_c77.intr.q;
  assign irq_doorbell_o[78]   = reg2hw.doorbell_c78.intr.q;
  assign irq_completion_o[78] = reg2hw.completion_interrupt_c78.intr.q;
  assign irq_doorbell_o[79]   = reg2hw.doorbell_c79.intr.q;
  assign irq_completion_o[79] = reg2hw.completion_interrupt_c79.intr.q;
  assign irq_doorbell_o[80]   = reg2hw.doorbell_c80.intr.q;
  assign irq_completion_o[80] = reg2hw.completion_interrupt_c80.intr.q;
  assign irq_doorbell_o[81]   = reg2hw.doorbell_c81.intr.q;
  assign irq_completion_o[81] = reg2hw.completion_interrupt_c81.intr.q;
  assign irq_doorbell_o[82]   = reg2hw.doorbell_c82.intr.q;
  assign irq_completion_o[82] = reg2hw.completion_interrupt_c82.intr.q;
  assign irq_doorbell_o[83]   = reg2hw.doorbell_c83.intr.q;
  assign irq_completion_o[83] = reg2hw.completion_interrupt_c83.intr.q;
  assign irq_doorbell_o[84]   = reg2hw.doorbell_c84.intr.q;
  assign irq_completion_o[84] = reg2hw.completion_interrupt_c84.intr.q;
  assign irq_doorbell_o[85]   = reg2hw.doorbell_c85.intr.q;
  assign irq_completion_o[85] = reg2hw.completion_interrupt_c85.intr.q;
  assign irq_doorbell_o[86]   = reg2hw.doorbell_c86.intr.q;
  assign irq_completion_o[86] = reg2hw.completion_interrupt_c86.intr.q;
  assign irq_doorbell_o[87]   = reg2hw.doorbell_c87.intr.q;
  assign irq_completion_o[87] = reg2hw.completion_interrupt_c87.intr.q;
  assign irq_doorbell_o[88]   = reg2hw.doorbell_c88.intr.q;
  assign irq_completion_o[88] = reg2hw.completion_interrupt_c88.intr.q;
  assign irq_doorbell_o[89]   = reg2hw.doorbell_c89.intr.q;
  assign irq_completion_o[89] = reg2hw.completion_interrupt_c89.intr.q;
  assign irq_doorbell_o[90]   = reg2hw.doorbell_c90.intr.q;
  assign irq_completion_o[90] = reg2hw.completion_interrupt_c90.intr.q;
  assign irq_doorbell_o[91]   = reg2hw.doorbell_c91.intr.q;
  assign irq_completion_o[91] = reg2hw.completion_interrupt_c91.intr.q;
  assign irq_doorbell_o[92]   = reg2hw.doorbell_c92.intr.q;
  assign irq_completion_o[92] = reg2hw.completion_interrupt_c92.intr.q;
  assign irq_doorbell_o[93]   = reg2hw.doorbell_c93.intr.q;
  assign irq_completion_o[93] = reg2hw.completion_interrupt_c93.intr.q;
  assign irq_doorbell_o[94]   = reg2hw.doorbell_c94.intr.q;
  assign irq_completion_o[94] = reg2hw.completion_interrupt_c94.intr.q;
  assign irq_doorbell_o[95]   = reg2hw.doorbell_c95.intr.q;
  assign irq_completion_o[95] = reg2hw.completion_interrupt_c95.intr.q;
  assign irq_doorbell_o[96]   = reg2hw.doorbell_c96.intr.q;
  assign irq_completion_o[96] = reg2hw.completion_interrupt_c96.intr.q;
  assign irq_doorbell_o[97]   = reg2hw.doorbell_c97.intr.q;
  assign irq_completion_o[97] = reg2hw.completion_interrupt_c97.intr.q;
  assign irq_doorbell_o[98]   = reg2hw.doorbell_c98.intr.q;
  assign irq_completion_o[98] = reg2hw.completion_interrupt_c98.intr.q;
  assign irq_doorbell_o[99]   = reg2hw.doorbell_c99.intr.q;
  assign irq_completion_o[99] = reg2hw.completion_interrupt_c99.intr.q;
  assign irq_doorbell_o[100]   = reg2hw.doorbell_c100.intr.q;
  assign irq_completion_o[100] = reg2hw.completion_interrupt_c100.intr.q;
  assign irq_doorbell_o[101]   = reg2hw.doorbell_c101.intr.q;
  assign irq_completion_o[101] = reg2hw.completion_interrupt_c101.intr.q;
  assign irq_doorbell_o[102]   = reg2hw.doorbell_c102.intr.q;
  assign irq_completion_o[102] = reg2hw.completion_interrupt_c102.intr.q;
  assign irq_doorbell_o[103]   = reg2hw.doorbell_c103.intr.q;
  assign irq_completion_o[103] = reg2hw.completion_interrupt_c103.intr.q;
  assign irq_doorbell_o[104]   = reg2hw.doorbell_c104.intr.q;
  assign irq_completion_o[104] = reg2hw.completion_interrupt_c104.intr.q;
  assign irq_doorbell_o[105]   = reg2hw.doorbell_c105.intr.q;
  assign irq_completion_o[105] = reg2hw.completion_interrupt_c105.intr.q;
  assign irq_doorbell_o[106]   = reg2hw.doorbell_c106.intr.q;
  assign irq_completion_o[106] = reg2hw.completion_interrupt_c106.intr.q;
  assign irq_doorbell_o[107]   = reg2hw.doorbell_c107.intr.q;
  assign irq_completion_o[107] = reg2hw.completion_interrupt_c107.intr.q;
  assign irq_doorbell_o[108]   = reg2hw.doorbell_c108.intr.q;
  assign irq_completion_o[108] = reg2hw.completion_interrupt_c108.intr.q;
  assign irq_doorbell_o[109]   = reg2hw.doorbell_c109.intr.q;
  assign irq_completion_o[109] = reg2hw.completion_interrupt_c109.intr.q;
  assign irq_doorbell_o[110]   = reg2hw.doorbell_c110.intr.q;
  assign irq_completion_o[110] = reg2hw.completion_interrupt_c110.intr.q;
  assign irq_doorbell_o[111]   = reg2hw.doorbell_c111.intr.q;
  assign irq_completion_o[111] = reg2hw.completion_interrupt_c111.intr.q;
  assign irq_doorbell_o[112]   = reg2hw.doorbell_c112.intr.q;
  assign irq_completion_o[112] = reg2hw.completion_interrupt_c112.intr.q;
  assign irq_doorbell_o[113]   = reg2hw.doorbell_c113.intr.q;
  assign irq_completion_o[113] = reg2hw.completion_interrupt_c113.intr.q;
  assign irq_doorbell_o[114]   = reg2hw.doorbell_c114.intr.q;
  assign irq_completion_o[114] = reg2hw.completion_interrupt_c114.intr.q;
  assign irq_doorbell_o[115]   = reg2hw.doorbell_c115.intr.q;
  assign irq_completion_o[115] = reg2hw.completion_interrupt_c115.intr.q;
  assign irq_doorbell_o[116]   = reg2hw.doorbell_c116.intr.q;
  assign irq_completion_o[116] = reg2hw.completion_interrupt_c116.intr.q;
  assign irq_doorbell_o[117]   = reg2hw.doorbell_c117.intr.q;
  assign irq_completion_o[117] = reg2hw.completion_interrupt_c117.intr.q;
  assign irq_doorbell_o[118]   = reg2hw.doorbell_c118.intr.q;
  assign irq_completion_o[118] = reg2hw.completion_interrupt_c118.intr.q;
  assign irq_doorbell_o[119]   = reg2hw.doorbell_c119.intr.q;
  assign irq_completion_o[119] = reg2hw.completion_interrupt_c119.intr.q;
  assign irq_doorbell_o[120]   = reg2hw.doorbell_c120.intr.q;
  assign irq_completion_o[120] = reg2hw.completion_interrupt_c120.intr.q;
  assign irq_doorbell_o[121]   = reg2hw.doorbell_c121.intr.q;
  assign irq_completion_o[121] = reg2hw.completion_interrupt_c121.intr.q;
  assign irq_doorbell_o[122]   = reg2hw.doorbell_c122.intr.q;
  assign irq_completion_o[122] = reg2hw.completion_interrupt_c122.intr.q;
  assign irq_doorbell_o[123]   = reg2hw.doorbell_c123.intr.q;
  assign irq_completion_o[123] = reg2hw.completion_interrupt_c123.intr.q;
  assign irq_doorbell_o[124]   = reg2hw.doorbell_c124.intr.q;
  assign irq_completion_o[124] = reg2hw.completion_interrupt_c124.intr.q;
  assign irq_doorbell_o[125]   = reg2hw.doorbell_c125.intr.q;
  assign irq_completion_o[125] = reg2hw.completion_interrupt_c125.intr.q;
  assign irq_doorbell_o[126]   = reg2hw.doorbell_c126.intr.q;
  assign irq_completion_o[126] = reg2hw.completion_interrupt_c126.intr.q;
  assign irq_doorbell_o[127]   = reg2hw.doorbell_c127.intr.q;
  assign irq_completion_o[127] = reg2hw.completion_interrupt_c127.intr.q;
  assign irq_doorbell_o[128]   = reg2hw.doorbell_c128.intr.q;
  assign irq_completion_o[128] = reg2hw.completion_interrupt_c128.intr.q;
  assign irq_doorbell_o[129]   = reg2hw.doorbell_c129.intr.q;
  assign irq_completion_o[129] = reg2hw.completion_interrupt_c129.intr.q;
  assign irq_doorbell_o[130]   = reg2hw.doorbell_c130.intr.q;
  assign irq_completion_o[130] = reg2hw.completion_interrupt_c130.intr.q;
  assign irq_doorbell_o[131]   = reg2hw.doorbell_c131.intr.q;
  assign irq_completion_o[131] = reg2hw.completion_interrupt_c131.intr.q;
  assign irq_doorbell_o[132]   = reg2hw.doorbell_c132.intr.q;
  assign irq_completion_o[132] = reg2hw.completion_interrupt_c132.intr.q;
  assign irq_doorbell_o[133]   = reg2hw.doorbell_c133.intr.q;
  assign irq_completion_o[133] = reg2hw.completion_interrupt_c133.intr.q;
  assign irq_doorbell_o[134]   = reg2hw.doorbell_c134.intr.q;
  assign irq_completion_o[134] = reg2hw.completion_interrupt_c134.intr.q;
  assign irq_doorbell_o[135]   = reg2hw.doorbell_c135.intr.q;
  assign irq_completion_o[135] = reg2hw.completion_interrupt_c135.intr.q;
  assign irq_doorbell_o[136]   = reg2hw.doorbell_c136.intr.q;
  assign irq_completion_o[136] = reg2hw.completion_interrupt_c136.intr.q;
  assign irq_doorbell_o[137]   = reg2hw.doorbell_c137.intr.q;
  assign irq_completion_o[137] = reg2hw.completion_interrupt_c137.intr.q;
  assign irq_doorbell_o[138]   = reg2hw.doorbell_c138.intr.q;
  assign irq_completion_o[138] = reg2hw.completion_interrupt_c138.intr.q;
  assign irq_doorbell_o[139]   = reg2hw.doorbell_c139.intr.q;
  assign irq_completion_o[139] = reg2hw.completion_interrupt_c139.intr.q;
  assign irq_doorbell_o[140]   = reg2hw.doorbell_c140.intr.q;
  assign irq_completion_o[140] = reg2hw.completion_interrupt_c140.intr.q;
  assign irq_doorbell_o[141]   = reg2hw.doorbell_c141.intr.q;
  assign irq_completion_o[141] = reg2hw.completion_interrupt_c141.intr.q;
  assign irq_doorbell_o[142]   = reg2hw.doorbell_c142.intr.q;
  assign irq_completion_o[142] = reg2hw.completion_interrupt_c142.intr.q;
  assign irq_doorbell_o[143]   = reg2hw.doorbell_c143.intr.q;
  assign irq_completion_o[143] = reg2hw.completion_interrupt_c143.intr.q;
  assign irq_doorbell_o[144]   = reg2hw.doorbell_c144.intr.q;
  assign irq_completion_o[144] = reg2hw.completion_interrupt_c144.intr.q;
  assign irq_doorbell_o[145]   = reg2hw.doorbell_c145.intr.q;
  assign irq_completion_o[145] = reg2hw.completion_interrupt_c145.intr.q;
  assign irq_doorbell_o[146]   = reg2hw.doorbell_c146.intr.q;
  assign irq_completion_o[146] = reg2hw.completion_interrupt_c146.intr.q;

  scmi_reg_top #(
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_shared_memory (
     .clk_i,
     .rst_ni,
     .reg2hw,
     .reg_req_i(reg_req),
     .reg_rsp_o(reg_rsp),
     .devmode_i(1'b1)
   );

   axi_dw_converter #(
    .AxiMaxReads        ( AxiMaxReads             ),
    .AxiSlvPortDataWidth( AxiSlvPortDataWidth     ),
    .AxiMstPortDataWidth( AxiMstPortDataWidth     ),
    .AxiAddrWidth       ( AxiAddrWidth            ),
    .AxiIdWidth         ( AxiIdWidth              ),
    .aw_chan_t          ( aw_chan_t               ),
    .mst_w_chan_t       ( mst_w_chan_t            ),
    .slv_w_chan_t       ( slv_w_chan_t            ),
    .b_chan_t           ( b_chan_t                ),
    .ar_chan_t          ( ar_chan_t               ),
    .mst_r_chan_t       ( mst_r_chan_t            ),
    .slv_r_chan_t       ( slv_r_chan_t            ),
    .axi_mst_req_t      ( mst_req_t               ),
    .axi_mst_resp_t     ( mst_resp_t              ),
    .axi_slv_req_t      ( slv_req_t               ),
    .axi_slv_resp_t     ( slv_resp_t              )
   ) i_axi_dw_converter_scmi (
    .clk_i      ( clk_i    ),
    .rst_ni     ( rst_ni   ),
    // slave port
    .slv_req_i  ( axi_mbox_req  ),
    .slv_resp_o ( axi_mbox_rsp  ),
    // master port
    .mst_req_o  ( axi32_mbox_req  ),
    .mst_resp_i ( axi32_mbox_rsp  )
  );

   axi_to_reg #(
     .ADDR_WIDTH(AxiAddrWidth),
     .DATA_WIDTH(AxiMstPortDataWidth),
     .ID_WIDTH(AxiIdWidth),
     .USER_WIDTH(AxiUserWidth),
     .AXI_MAX_WRITE_TXNS(1),
     .AXI_MAX_READ_TXNS(1),
     .DECOUPLE_W(0),
     .axi_req_t(mst_req_t),
     .axi_rsp_t(mst_resp_t),
     .reg_req_t(reg_req_t),
     .reg_rsp_t(reg_rsp_t)
   ) u_axi2reg_intf (
     .clk_i,
     .rst_ni,
     .testmode_i(1'b0),
     .axi_req_i(axi32_mbox_req),
     .axi_rsp_o(axi32_mbox_rsp),
     .reg_req_o(reg_req),
     .reg_rsp_i(reg_rsp)
   );

endmodule // axi_scmi_mailbox

