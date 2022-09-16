`timescale 1ns / 1ps

module iob_piso_reg_are
  #(
    parameter DATA_W = 32
    )
   (

    input              clk,
    input              arst,

    input              ld,
    input              en,

    // parallel input
    input [DATA_W-1:0] p_in,

    // serial output
    output             s_out
    );

   reg [DATA_W-1:0]    data_reg;
   
   always @(posedge clk, posedge arst)
     if (arst)
       data_reg <= 1'b0;
     else if (ld)
       data_reg <= p_in;
     else if (en)
       data_reg <= data_reg << 1;

   assign s_out = data_reg[DATA_W-1];
   
endmodule
