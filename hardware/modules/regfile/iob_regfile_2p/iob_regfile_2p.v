`timescale 1 ns / 1 ps
`include "iob_utils.vh"

module iob_regfile_2p #(
   parameter N       = 0,           //number of registers
   parameter W       = 0,           //register width
   parameter WDATA_W = 0,           //width of write data
   parameter WADDR_W = 0,           //width of write address
   parameter RDATA_W = 0,           //width of read data
   parameter RADDR_W = 0,           //width of read address
   //cpu interface
   //the address on the cpu side must be a byte address
   parameter DATA_W  = 0,           //width of data
   parameter WSTRB_W = WDATA_W / 8  //width of write strobe
) (
   input                                              clk_i,
   input                                              arst_i,
   input                                              cke_i,
   input                                              wen_i,
   input  [((RADDR_W+WADDR_W)+(WSTRB_W+WDATA_W))-1:0] req_i,
   output [                              RDATA_W-1:0] resp_o
);

   //register file and register file write enable
   wire [(N*W)-1 : 0] regfile;
   wire [      N-1:0] wen;

   //reconstruct write address from waddr_i and wstrb_i
   wire [WSTRB_W-1:0] wstrb = req_i[WDATA_W+:WSTRB_W];
   wire [WADDR_W-1:0] waddr = req_i[WSTRB_W+WDATA_W+:WADDR_W];
   localparam WADDR_INT_W = (WADDR_W > ($clog2(DATA_W / 8) + 1)) ? WADDR_W
                                 : ($clog2(DATA_W / 8) + 1);
   wire [($clog2(DATA_W/8)+1)-1:0] waddr_incr;
   wire [         WADDR_INT_W-1:0] waddr_int = waddr + waddr_incr;

   iob_ctls #(
      .N     (DATA_W / 8),
      .MODE  (0),
      .SYMBOL(0)
   ) iob_ctls_txinst (
      .data_i (wstrb),
      .count_o(waddr_incr)
   );

   //write register file
   wire [WDATA_W-1:0] wdata_int = req_i[WDATA_W-1:0];
   genvar i;
   genvar j;

   localparam LAST_I = (N / WSTRB_W) * WSTRB_W;
   localparam REM_I = (N - LAST_I) + 1;

   generate
      for (i = 0; i < N; i = i + WSTRB_W) begin : g_rows
         for (j = 0; j < ((i == LAST_I) ? REM_I : WSTRB_W); j = j + 1) begin : g_columns

            if ((i + j) < N) begin : g_if
               assign wen[i+j] = wen_i & (waddr_int == (i + j)) & wstrb[j];
               iob_reg_e #(
                  .DATA_W (W),
                  .RST_VAL({W{1'b0}}),
                  .CLKEDGE("posedge")
               ) iob_reg_inst (
                  .clk_i (clk_i),
                  .arst_i(arst_i),
                  .cke_i (cke_i),
                  .en_i  (wen[i+j]),
                  .data_i(wdata_int[(j*8)+:W]),
                  .data_o(regfile[(i+j)*W+:W])
               );
            end
         end
      end
   endgenerate

   //read register file
   generate
      if (RADDR_W > 0) begin : g_read
         wire [RADDR_W-1:0] raddr = req_i[(WSTRB_W+WDATA_W)+WADDR_W+:RADDR_W];
         assign resp_o = regfile[RDATA_W*raddr+:RDATA_W];
      end else begin : g_read
         assign resp_o = regfile;
      end
   endgenerate

endmodule
