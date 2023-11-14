`include "constants.vh"
`default_nettype none
module tag_generator(
		     input wire 		    clk,
		     input wire 		    reset,
		     input wire 		    branchvalid1,    //inst1是否有效
		     input wire 		    branchvalid2,    //inst2是否有效
		     input wire 		    prmiss,
		     input wire 		    prsuccess,       //预测成功
		     input wire 		    enable,          //指令是否可以发射
		     input wire [`SPECTAG_LEN-1:0]  tagregfix,

		     output wire [`SPECTAG_LEN-1:0] sptag1,		//speculative tag  00001、00010、…、10000（从 00001 左循环）的顺序
		     output wire [`SPECTAG_LEN-1:0] sptag2, 	//speculative tag
		     output wire 		    speculative1,
		     output wire 		    speculative2,
			 //如果没有可用的推测标签，标签产生器将把 attachable 标志设置为 0，并暂停标签指派流程。
		     output wire 		    attachable,
		     output reg [`SPECTAG_LEN-1:0]  tagreg
		     );

//    reg [`SPECTAG_LEN-1:0] 		       tagreg;

   // tagereg 推测标签寄存器
   // brdepth 分支深度寄存器
   reg [`BRDEPTH_LEN-1:0] 		       brdepth;
   
   // 左循环
   assign sptag1 = (branchvalid1) ? 
		   {tagreg[`SPECTAG_LEN-2:0], tagreg[`SPECTAG_LEN-1]}
		   : tagreg;
   assign sptag2 = (branchvalid2) ? 
		   {sptag1[`SPECTAG_LEN-2:0], sptag1[`SPECTAG_LEN-1]}
		   : sptag1;
	// depth != 0 则开始推测
   assign speculative1 = (brdepth != 0) ? 1'b1 : 1'b0;
   assign speculative2 = ((brdepth != 0) || branchvalid1) ? 1'b1 : 1'b0;
   //
   assign attachable = (brdepth + branchvalid1 + branchvalid2) > (`BRANCH_ENT_NUM + prsuccess) ? 1'b0 : 1'b1;

   // 根据 prmiss 和 enable 来更新 tagreg 和 brdepth
   always @ (posedge clk) begin
      if (reset) begin
	 tagreg <= `SPECTAG_LEN'b1;
	 brdepth <= `BRDEPTH_LEN'b0;
      end else begin
	 tagreg <= prmiss ? tagregfix :
		   ~enable ? tagreg : 
		   sptag2;
	 brdepth <= prmiss ? `BRDEPTH_LEN'b0 :
		    ~enable ? brdepth - prsuccess :
		    brdepth + branchvalid1 + branchvalid2 - prsuccess;
      end
   end
   
endmodule // tag_generator
`default_nettype wire
