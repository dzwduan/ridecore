`include "define.v"
`include "constants.vh"
`include "pipeline.v"
`include "dmem.v"
`include "imem.v"

module TopSim (
    input clk,
    input reset_x
);

  wire [  `ADDR_LEN-1:0] pc;
  wire [4*`INSN_LEN-1:0] idata;
  wire [            8:0] imem_addr;
  wire [  `DATA_LEN-1:0] dmem_data;
  wire [  `DATA_LEN-1:0] dmem_wdata;
  wire [  `ADDR_LEN-1:0] dmem_addr;
  wire                   dmem_we;
  wire [  `DATA_LEN-1:0] dmem_wdata_core;
  wire [  `ADDR_LEN-1:0] dmem_addr_core;
  wire                   dmem_we_core;

  wire                   utx_we;
  wire                   finish_we;
  wire                   ready_tx;
  wire                   loaded;

  reg                    prog_loading;
  wire [4*`INSN_LEN-1:0] prog_loaddata = 0;
  wire [  `ADDR_LEN-1:0] prog_loadaddr = 0;
  wire                   prog_dmem_we = 0;
  wire                   prog_imem_we = 0;

  always @(posedge clk) begin
    if (!reset_x) begin
      prog_loading <= 1'b1;
    end else begin
      prog_loading <= 0;
    end
  end

  pipeline pipe (
      .clk(clk),
      .reset(~reset_x | prog_loading),
      .pc(pc),
      .idata(idata),
      .dmem_wdata(dmem_wdata_core),
      .dmem_addr(dmem_addr_core),
      .dmem_we(dmem_we_core),
      .dmem_data(dmem_data)
  );

  assign dmem_addr = prog_loading ? prog_loadaddr : dmem_addr_core;
  assign dmem_we = prog_loading ? prog_dmem_we : dmem_we_core;
  assign dmem_wdata = prog_loading ? prog_loaddata[127:96] : dmem_wdata_core;
  dmem datamemory (
      .clk(clk),
      .addr({2'b0, dmem_addr[`ADDR_LEN-1:2]}),
      .wdata(dmem_wdata),
      .we(dmem_we),
      .rdata(dmem_data)
  );

  assign imem_addr = prog_loading ? prog_loadaddr[12:4] : pc[12:4];
  imem_ld instmemory (
      .clk(~clk),
      .addr(imem_addr),
      .rdata(idata),
      .wdata(prog_loaddata),
      .we(prog_imem_we)
  );

endmodule  // top


