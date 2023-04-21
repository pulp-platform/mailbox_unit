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

// Parametric number of mailboxes (= mailbox unit)

`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"
`include "axi/assign.svh"
`include "axi/typedef.svh"

module mailbox_unit import mailbox_reg_pkg::*; #(
  parameter type         reg_req_t = logic,
  parameter type         reg_rsp_t = logic,
  parameter int unsigned NumMbox = 4,
  parameter bit          AlignPage = 0 // whether mailboxes addresses should be 4k aligned
) (
  input logic                clk_i,
  input logic                rst_ni,

  input  reg_req_t           reg_req_i,
  output reg_rsp_t           reg_rsp_o,

  output logic [NumMbox-1:0] snd_irq_o,
  output logic [NumMbox-1:0] rcv_irq_o
);

  if (NumMbox > 128)
    $fatal(1, "maximum number supported mailboxes is 128");

  if (AlignPage == 1)
    $fatal(1, "not implemented yet");


  mailbox_reg2hw_t [NumMbox-1:0] mbox_reg2hw;
  mailbox_hw2reg_t [NumMbox-1:0] mbox_hw2reg;

  reg_req_t [NumMbox-1:0] reg_int_req;
  reg_rsp_t [NumMbox-1:0] reg_int_rsp;

  logic [15:0] which_mbox;

  // Top level address decoding and bux muxing
  // All mailbox registers are 32 bits wide
  // Each mailbox reserves 256 bytes of address space
  always_comb begin : mailbox_unit_addr_decode
    which_mbox = reg_req_i.addr[15:8];

    reg_int_req = '0;
    reg_rsp_o   = '0;

    reg_int_req[which_mbox] = reg_req_i;
    reg_int_req[which_mbox].addr = reg_req_i.addr[7:0];
    reg_rsp_o = reg_int_rsp[which_mbox];
  end

  logic [NumMbox-1:0] snd_irq_d, snd_irq_q;
  logic [NumMbox-1:0] rcv_irq_d, rcv_irq_q;

  for (genvar i = 0; i < NumMbox; i++) begin : gen_mailbox
    mailbox_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
    ) i_mailbox_reg_top (
      .clk_i,
      .rst_ni,

      .reg2hw (mbox_reg2hw[i]),
      .hw2reg (mbox_hw2reg[i]),

      .reg_req_i(reg_int_req[i]),
      .reg_rsp_o(reg_int_rsp[i]),

      .devmode_i(1'b1)
    );

    always_comb begin : update_snd_irq
      snd_irq_d[i] = snd_irq_q[i];

      if (mbox_reg2hw[i].irq_snd_clr.clr.qe && mbox_reg2hw[i].irq_snd_clr.clr.q == 1'b1)
        snd_irq_d[i] = 1'b0;

      if (mbox_reg2hw[i].irq_snd_set.set.qe && mbox_reg2hw[i].irq_snd_set.set.q == 1'b1)
        snd_irq_d[i] = 1'b1;
    end

    always_comb begin : update_rcv_irq
      rcv_irq_d[i] = rcv_irq_q[i];

      if (mbox_reg2hw[i].irq_rcv_clr.clr.qe && mbox_reg2hw[i].irq_rcv_clr.clr.q == 1'b1)
        rcv_irq_d[i] = 1'b0;

      if (mbox_reg2hw[i].irq_rcv_set.set.qe && mbox_reg2hw[i].irq_rcv_set.set.q == 1'b1)
        rcv_irq_d[i] = 1'b1;
    end

    assign mbox_hw2reg[i].irq_snd_stat.stat.d = snd_irq_q[i];
    assign mbox_hw2reg[i].irq_rcv_stat.stat.d = rcv_irq_q[i];

    assign snd_irq_o[i] = snd_irq_q[i] & mbox_reg2hw[i].irq_snd_en.en.q;
    assign rcv_irq_o[i] = rcv_irq_q[i] & mbox_reg2hw[i].irq_rcv_en.en.q;

    always_ff @(posedge clk_i or negedge rst_ni) begin : irq_lines
      if (!rst_ni) begin
        snd_irq_q <= '0;
        rcv_irq_q <= '0;
      end else begin
        snd_irq_q <= snd_irq_d;
        rcv_irq_q <= rcv_irq_d;
      end
    end
  end

endmodule // mailbox_unit
