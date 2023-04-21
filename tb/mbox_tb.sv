// Copyright 2022 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wolfgang Roenninger <wroennin@iis.ee.ethz.ch>
// Maicol Ciani <maicol.ciani@unibo.it>
// Robert Balas <balasr@iis.ee.ethz.ch>

// mailbox unit basic testbench

`include "axi/assign.svh"
`include "axi/typedef.svh"

module mbox_tb import axi_pkg::*; #(
  parameter int NumMbox = 128
)(
);

 // timing parameters
  localparam time CyclTime = 10ns;
  localparam time ApplTime =  2ns;
  localparam time TestTime =  8ns;

  // axi configuration
  localparam int unsigned AxiAddrWidth      =  32'd32;    // Axi Address Width
  localparam int unsigned AxiDataWidth      =  32'd32;    // Axi Data Width

  typedef logic [AxiAddrWidth-1:0] addr_t;
  typedef logic [AxiDataWidth-1:0] data_t;
  typedef logic [AxiDataWidth/8-1:0] strb_t;

  typedef enum addr_t {
    IRQ_SND_STAT = addr_t'(0 * AxiDataWidth/8),
    IRQ_SND_SET  = addr_t'(1 * AxiDataWidth/8),
    IRQ_SND_CLR  = addr_t'(2 * AxiDataWidth/8),
    IRQ_SND_EN   = addr_t'(3 * AxiDataWidth/8),
    IRQ_RCV_STAT = addr_t'(16 * AxiDataWidth/8),
    IRQ_RCV_SET  = addr_t'(17 * AxiDataWidth/8),
    IRQ_RCV_CLR  = addr_t'(18 * AxiDataWidth/8),
    IRQ_RCV_EN   = addr_t'(19 * AxiDataWidth/8),
    LETTER0      = addr_t'(32 * AxiDataWidth/8),
    LETTER1      = addr_t'(33 * AxiDataWidth/8)
  } reg_addr_e;

  typedef axi_test::axi_lite_rand_master #(
    // AXI interface parameters
    .AW ( AxiAddrWidth        ),
    .DW ( AxiDataWidth        ),
    // Stimuli application and test time
    .TA ( ApplTime            ),
    .TT ( TestTime            ),
    .MIN_ADDR ( 32'h0000_0000 ),
    .MAX_ADDR ( 32'h0001_3000 ),
    .MAX_READ_TXNS  ( 10 ),
    .MAX_WRITE_TXNS ( 10 )
  ) rand_lite_master_t;

  // DUT signals
  logic               clk;
  logic               rst_n;
  logic               end_of_sim;
  logic [NumMbox-1:0] rcv_irq;
  logic [NumMbox-1:0] snd_irq;

  int unsigned test_failed;

  // AXI Interfaces
  AXI_LITE #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth      ),
    .AXI_DATA_WIDTH ( AxiDataWidth      )
  ) master ();
  AXI_LITE_DV #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth      ),
    .AXI_DATA_WIDTH ( AxiDataWidth      )
  ) master_dv (clk);

  `AXI_LITE_ASSIGN(master, master_dv)

  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(axi_lite_req_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)
  `AXI_LITE_TYPEDEF_RESP_T(axi_lite_resp_t, b_chan_lite_t, r_chan_lite_t)

  axi_lite_req_t axi_lite_req;
  axi_lite_resp_t axi_lite_resp;

  `AXI_LITE_ASSIGN_TO_REQ(axi_lite_req, master)
  `AXI_LITE_ASSIGN_FROM_RESP(master, axi_lite_resp)

  // DUT
  axi_lite_mailbox_unit #(
    .AXI_ADDR_WIDTH(32),
    .axi_lite_req_t(axi_lite_req_t),
    .axi_lite_resp_t(axi_lite_resp_t),
    .NumMbox(NumMbox),
    .AlignPage(0) // whether mailboxes addresses should be 4k aligned
  ) i_dut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .axi_lite_req_i(axi_lite_req),
    .axi_lite_rsp_o(axi_lite_resp),
    .rcv_irq_o(rcv_irq),
    .snd_irq_o(snd_irq)
  );

  clk_rst_gen #(
    .ClkPeriod    ( CyclTime ),
    .RstClkCycles ( 5        )
  ) i_clk_gen (
    .clk_o (clk),
    .rst_no(rst_n)
  );

`define TEST_READ_REG(ADDR, EXPECTED) \
    $display(`"%0t MST_0> Read register ``ADDR `", $time()); \
    lite_axi_master.read(``ADDR, axi_pkg::prot_t'('0), data, resp); \
    assert (data == data_t'(``EXPECTED)) else begin test_failed++; $error("Unexpected result"); end \
    assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end

`define TEST_WRITE_READ_REG(ADDR, EXPECTED) \
    $display(`"%0t MST_0> write/read register ``ADDR `", $time()); \
    lite_axi_master.write(``ADDR, axi_pkg::prot_t'('0), data_t'(``EXPECTED), 4'hf, resp);  \
    assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end \
    lite_axi_master.read(``ADDR, axi_pkg::prot_t'('0), data, resp); \
    assert (data == data_t'(``EXPECTED)) else begin test_failed++; $error("Unexpected result"); end \
    assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end

`define TEST_W1S_REG(ADDR) \
    $display(`"%0t MST_0> w1s register ``ADDR `", $time()); \
    lite_axi_master.write(``ADDR, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);  \
    assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end \
    lite_axi_master.read(``ADDR, axi_pkg::prot_t'('0), data, resp); \
    assert (data == data_t'(32'h0)) else begin test_failed++; $error("Unexpected result"); end \
    assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end

  initial begin : proc_master
    automatic rand_lite_master_t lite_axi_master = new ( master_dv, "MST_0");
    automatic data_t          data = '0;
    automatic axi_pkg::resp_t resp = axi_pkg::RESP_SLVERR;
    automatic addr_t          mbox_base = '0;
    end_of_sim <= 1'b0;
    lite_axi_master.reset();
    @(posedge rst_n);

    for (int k = 0; k < NumMbox; k++ ) begin
      mbox_base = 256 * k; // each mailbox occupies 256 bytes
      // Read all registers and compare their results
      $info("Initial test by reading each register");
      `TEST_READ_REG(mbox_base + IRQ_SND_STAT, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_SND_SET, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_SND_CLR, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_SND_EN, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_RCV_STAT, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_RCV_SET, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_RCV_CLR, 32'h0);
      `TEST_READ_REG(mbox_base + IRQ_RCV_EN, 32'h0);
      `TEST_READ_REG(mbox_base + LETTER0, 32'h0);
      `TEST_READ_REG(mbox_base + LETTER1, 32'h0);

      // write read scratchpad registers
      $info("write/read tests");
      `TEST_WRITE_READ_REG(mbox_base + LETTER0, 32'hcafedead);
      `TEST_WRITE_READ_REG(mbox_base + LETTER0, 32'hffffffff);
      `TEST_WRITE_READ_REG(mbox_base + LETTER1, 32'hcafedead);
      `TEST_WRITE_READ_REG(mbox_base + LETTER1, 32'hffffffff);

      `TEST_WRITE_READ_REG(mbox_base + LETTER0, 32'h00000000);
      `TEST_WRITE_READ_REG(mbox_base + LETTER1, 32'h00000000);

      // Test w1s
      `TEST_W1S_REG(mbox_base + IRQ_SND_SET);
      `TEST_W1S_REG(mbox_base + IRQ_SND_CLR);
      `TEST_W1S_REG(mbox_base + IRQ_RCV_SET);
      `TEST_W1S_REG(mbox_base + IRQ_RCV_CLR);

      // test send and receive interrupt
      // set irq, check stat, check irq line low, enable mask, check irq line high, 
      // clear, check irq line low, check stat
      lite_axi_master.write(mbox_base + IRQ_SND_SET, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      `TEST_READ_REG(mbox_base + IRQ_SND_STAT, 32'h1);
      assert(snd_irq[k] == 1'b0) else begin test_failed++; $error("Unexpected result"); end
      lite_axi_master.write(mbox_base + IRQ_SND_EN, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      assert (snd_irq[k] == 1'b1) else begin test_failed++; $error("Unexpected result"); end

      lite_axi_master.write(mbox_base + IRQ_SND_CLR, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      assert (snd_irq[k] == 1'b0) else begin test_failed++; $error("Unexpected result"); end
      `TEST_READ_REG(mbox_base + IRQ_SND_STAT, 32'h0);

      // same for rcv
      lite_axi_master.write(mbox_base + IRQ_RCV_SET, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      `TEST_READ_REG(mbox_base + IRQ_RCV_STAT, 32'h1);
      assert(rcv_irq[k] == 1'b0) else begin test_failed++; $error("Unexpected result"); end
      lite_axi_master.write(mbox_base + IRQ_RCV_EN, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      assert (rcv_irq[k] == 1'b1) else begin test_failed++; $error("Unexpected result"); end

      lite_axi_master.write(mbox_base + IRQ_RCV_CLR, axi_pkg::prot_t'('0), data_t'(32'h1), 4'hf, resp);
      assert (resp == axi_pkg::RESP_OKAY) else begin test_failed++; $error("Unexpected result"); end
      assert (rcv_irq[k] == 1'b0) else begin test_failed++; $error("Unexpected result"); end
      `TEST_READ_REG(mbox_base + IRQ_RCV_STAT, 32'h0);
    end

    end_of_sim <= 1'b1;
  end

  initial begin : proc_monitor_irq_0
    forever begin
      @(posedge snd_irq);
      $info("Received SND interrupt");
    end
  end

  initial begin : proc_monitor_irq_1
    forever begin
      @(posedge rcv_irq);
      $info("Received RCV interrupt");
    end
  end

  initial begin : proc_stop_sim
    wait (end_of_sim);
    repeat (50) @(posedge clk);
    $display("Number of failed tests: %0d", test_failed);
    if (test_failed > 0) begin
        $fatal(1, "Assertion errors. Failure!");
    end else begin
        $info("Success.",);
    end
    $stop();
  end

endmodule
