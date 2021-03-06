//--------------------------------------------------
//--                                          
//-- version 1.6 
//--                                          
//--------------------------------------------------
//--------------------------------------------------
//  
//      Verilog code generated by Visual Elite
//
//  Design Unit:
//  ------------
//      Unit    Name  :  fifo_manager
//      Library Name  :  L1_DCL
//  
//      Creation Date :  Mon Nov 28 11:01:12 2011
//      Version       :  2011.02 v4.3.0 build 24. Date: Mar 21 2011. License: 2011.3
//  
//  Options Used:
//  -------------
//      Target
//         Language   :  Verilog
//         Purpose    :  Synthesis
//         Vendor     :  Leonardo
//  
//      Style
//         Use tasks                      :  No
//         Code Destination               :  Combined file
//         Attach Directives              :  Yes
//         Structural                     :  No
//         IF for state selection         :  No
//         Error (default) state          :  Yes
//         String typed state variable    :  No
//         Next state assignments         :  Non blocking
//         Free text style                :  / / ...
//         Preserve spacing for free text :  Yes
//         Declaration alignment          :  No
//         Sort Ports by mode             :  No
//         New line for each Port         :  No
//         Attach comment to Port         :  No
//
//--------------------------------------------------
//--------------------------------------------------
//  
//  Library Name :  L1_DCL
//  Unit    Name :  fifo_manager
//  Unit    Type :  State Machine
//  
//----------------------------------------------------
 
 
`timescale 1ns/100ps
module fifo_manager (clk, rst_b, L1_BCids, packet, fifowr, fifo_full,
                     datavalid, next_hit, mcluster, ch, hit0, hit1, hit2, hit3,
                     finished, wtdg_rstrt
                     );
 
  input clk;
  wire clk;
  input rst_b;
  wire rst_b;
  input [15:0] L1_BCids;
  wire [15:0] L1_BCids;
  output [50:0] packet;
  wire [50:0] packet;
  output fifowr;
  reg fifowr;
  input fifo_full;
  wire fifo_full;
  input datavalid;
  wire datavalid;
  output next_hit;
  reg next_hit;
  input mcluster;
  wire mcluster;
  input [7:0] ch;
  wire [7:0] ch;
  input [2:0] hit0;
  wire [2:0] hit0;
  input [2:0] hit1;
  wire [2:0] hit1;
  input [2:0] hit2;
  wire [2:0] hit2;
  input [2:0] hit3;
  wire [2:0] hit3;
  input finished;
  wire finished;
  output wtdg_rstrt;
  reg wtdg_rstrt;
  reg [7:0] clst1_ch;
  reg [7:0] clst2_ch;
  reg [7:0] clst3_ch;
  reg [2:0] clst1_hit0;
  reg [2:0] clst1_hit1;
  reg [2:0] clst1_hit2;
  reg [2:0] clst1_hit3;
  reg clst2_hit1;
  reg clst2_hit2;
  reg clst2_hit3;
  reg clst3_hit1;
  reg clst3_hit2;
  reg clst3_hit3;
  reg empty_pkt;
  reg last_pkt;
 
  parameter WAIT      = 4'b0000,
            LD_C1     = 4'b0001,
            LD_C2     = 4'b0010,
            LD_C3     = 4'b0011,
            NXT_EVNT  = 4'b1000,
            REL1      = 4'b0100,
            REL2      = 4'b0101,
            REL3      = 4'b0110,
            STR_FIFO  = 4'b0111,
            WAIT_FIFO = 4'b1001;
 
 
  reg [3:0] visual_WAIT_current;
 
 
 
  // Synchronous process
  always  @(posedge clk or negedge rst_b)
  begin : fifo_manager_WAIT
 
    if (~(rst_b))
    begin
      fifowr<=1'b0;
      next_hit<=1'b0;
      wtdg_rstrt<=1'b0;
      visual_WAIT_current <= WAIT;
    end
    else
    begin
 
      case (visual_WAIT_current)  // exemplar parallel_case full_case
        WAIT:
          begin
            if (datavalid)
            begin
              clst1_ch <= ch;
              clst1_hit0 <= hit0;
              clst1_hit1 <= hit1;
              clst1_hit2 <= hit2;
              clst1_hit3 <= hit3;
              clst2_ch <= ch;
              clst2_hit1 <= hit1[1];
              clst2_hit2 <= hit2[1];
              clst2_hit3 <= hit3[1];
              clst3_ch <= ch;
              clst3_hit1 <= hit1[1];
              clst3_hit2 <= hit2[1];
              clst3_hit3 <= hit3[1];
              empty_pkt<=1'b0;
              last_pkt<=1'b0;
              fifowr<=1'b0;
              next_hit<=1'b1;
              visual_WAIT_current <= LD_C1;
            end
            else if (~(datavalid) && ~(finished))
            begin
              fifowr<=1'b0;
              empty_pkt<=1'b0;
              last_pkt<=1'b0;
              visual_WAIT_current <= WAIT;
            end
            else if (finished)
            begin
              clst1_ch <= 8'h00;
              clst1_hit0 <= 3'b000;
              clst1_hit1 <= 3'b000;
              clst1_hit2 <= 3'b000;
              clst1_hit3 <= 3'b000;
              clst2_ch <= 8'h00;
              clst2_hit1 <= 1'b0;
              clst2_hit2 <= 1'b0;
              clst2_hit3 <= 1'b0;
              clst3_ch <= 8'h00;
              clst3_hit1 <= 1'b0;
              clst3_hit2 <= 1'b0;
              clst3_hit3 <= 1'b0;
              empty_pkt<=1'b1;
              last_pkt<=1'b0;
              fifowr<=1'b0;
              next_hit<=1'b1;
              fifowr<=1'b0;
              next_hit<=1'b0;
              visual_WAIT_current <= STR_FIFO;
            end
            else
              visual_WAIT_current <= WAIT;
          end
 
        LD_C1:
          begin
            if (mcluster)
            begin
              next_hit<=1'b0;
              visual_WAIT_current <= REL1;
            end
            else if (~(mcluster))
            begin
              fifowr<=1'b0;
              next_hit<=1'b0;
              visual_WAIT_current <= STR_FIFO;
            end
            else
              visual_WAIT_current <= LD_C1;
          end
 
        LD_C2:
          begin
            next_hit<=1'b0;
            visual_WAIT_current <= REL2;
          end
 
        LD_C3:
          begin
            next_hit<=1'b0;
            visual_WAIT_current <= REL3;
          end
 
        NXT_EVNT:
          begin
            if (finished)
            begin
              fifowr<=1'b0;
              next_hit<=1'b0;
              last_pkt<=1'b0;
              visual_WAIT_current <= NXT_EVNT;
            end
            else if (~(finished))
            begin
              fifowr<=1'b0;
              next_hit<=1'b0;
              wtdg_rstrt<=1'b0;
              visual_WAIT_current <= WAIT;
            end
            else
              visual_WAIT_current <= NXT_EVNT;
          end
 
        REL1:
          begin
            if (datavalid)
            begin
              clst2_ch <= ch;
              clst2_hit1 <= hit1[1];
              clst2_hit2 <= hit2[1];
              clst2_hit3 <= hit3[1];
              clst3_ch <= ch;
              clst3_hit1 <= hit1[1];
              clst3_hit2 <= hit2[1];
              clst3_hit3 <= hit3[1];
              next_hit<=1'b1;
              visual_WAIT_current <= LD_C2;
            end
            else if (finished)
            begin
              fifowr<=1'b0;
              next_hit<=1'b0;
              visual_WAIT_current <= STR_FIFO;
            end
            else
              visual_WAIT_current <= REL1;
          end
 
        REL2:
          begin
            if (finished)
            begin
              fifowr<=1'b0;
              next_hit<=1'b0;
              visual_WAIT_current <= STR_FIFO;
            end
            else if (datavalid)
            begin
              clst3_ch <= ch;
              clst3_hit1 <= hit1[1];
              clst3_hit2 <= hit2[1];
              clst3_hit3 <= hit3[1];
              next_hit<=1'b1;
              visual_WAIT_current <= LD_C3;
            end
            else
              visual_WAIT_current <= REL2;
          end
 
        REL3:
          begin
            fifowr<=1'b0;
            next_hit<=1'b0;
            visual_WAIT_current <= STR_FIFO;
          end
 
        STR_FIFO:
          begin
            if (finished && fifo_full)
            begin
              last_pkt<=1'b1;
              wtdg_rstrt<=1'b1;
              visual_WAIT_current <= WAIT_FIFO;
            end
            else if (finished && ~(fifo_full))
            begin
              fifowr<=1'b1;
              next_hit<=1'b1;
              last_pkt<=1'b1;
              visual_WAIT_current <= NXT_EVNT;
            end
            else if (datavalid && ~(fifo_full))
            begin
              fifowr<=1'b1;
              last_pkt<=1'b0;
              next_hit<=1'b0;
              wtdg_rstrt<=1'b0;
              visual_WAIT_current <= WAIT;
            end
            else
              visual_WAIT_current <= STR_FIFO;
          end
 
        WAIT_FIFO:
          begin
            if (~(fifo_full))
            begin
              fifowr<=1'b1;
              next_hit<=1'b1;
              wtdg_rstrt<=1'b0;
              visual_WAIT_current <= NXT_EVNT;
            end
            else if (fifo_full)
            begin
              visual_WAIT_current <= WAIT_FIFO;
            end
            else
              visual_WAIT_current <= WAIT_FIFO;
          end
 
        default:
          begin
            next_hit<=1'b0;
            wtdg_rstrt<=1'b0;
            visual_WAIT_current <= WAIT;
          end
      endcase
    end
  end
 
  assign packet[32:0] = mcluster ? {clst1_ch, clst1_hit1[1], clst1_hit2[1], clst1_hit3[1],
                                    clst2_ch, clst2_hit1, clst2_hit2, clst2_hit3,
                                    clst3_ch, clst3_hit1, clst3_hit2, clst3_hit3}
                                 : {clst1_ch, clst1_hit0, clst1_hit1, clst1_hit2, clst1_hit3,13'h0000};
  assign packet[34:33] = {empty_pkt,last_pkt};
  assign packet[50:35] = L1_BCids;
 
 
endmodule

