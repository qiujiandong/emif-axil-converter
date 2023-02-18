`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/14 17:04:25
// Design Name: 
// Module Name: emif2axil
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module emif2axil#(
    parameter AXIL_DW = 32,
    parameter AXIL_AW = 4,
    parameter [23:0] EMIF_ADDR_BASE = 24'h000000,
    parameter [31:0] AXIL_ADDR_BASE = 32'h00000000,
    parameter AXIL_ADDR_WIDTH = 16 // 16 for 64kB, max is 25 for 32MB
)(
    input eclk,
    input nrst,

    (* mark_debug = "true" *) output full,
    (* mark_debug = "true" *) output busy,
    (* mark_debug = "true" *) output rd_fifo_empty,

    (* mark_debug = "true" *) input nce,
    (* mark_debug = "true" *) input noe,
    (* mark_debug = "true" *) input nwe,

    inout [31:0] emif_data,
    (* mark_debug = "true" *) input [23:0] emif_addr,

// axi-lite master interface
    output aclk,
    output aresetn,

    output [2 : 0] m_axil_awprot,
    output [3 : 0] m_axil_wstrb,
    output [2 : 0] m_axil_arprot,
    input [1 : 0] m_axil_rresp,
    // b
    input m_axil_bvalid,
    output m_axil_bready,
    input [1 : 0] m_axil_bresp,

    // aw
    (* mark_debug = "true" *) output m_axil_awvalid,
    (* mark_debug = "true" *) input m_axil_awready,
    (* mark_debug = "true" *) output [31 : 0] m_axil_awaddr,
    // w
    (* mark_debug = "true" *) output m_axil_wvalid,
    (* mark_debug = "true" *) input m_axil_wready,
    (* mark_debug = "true" *) output [31 : 0] m_axil_wdata,
    // ar
    (* mark_debug = "true" *) output m_axil_arvalid,
    (* mark_debug = "true" *) input m_axil_arready,
    (* mark_debug = "true" *) output [31 : 0] m_axil_araddr,
    // r
    (* mark_debug = "true" *) input m_axil_rvalid,
    (* mark_debug = "true" *) output m_axil_rready,
    (* mark_debug = "true" *) input [31 : 0] m_axil_rdata
// end of axi master interface

    );

    localparam S_IDLE = 3'b000;
    localparam S_WRITE = 3'b001;
    localparam S_READ = 3'b010;
    localparam S_WAITRD = 3'b011;

    wire [31:0] emif_data_in;
    wire [31:0] emif_data_out;
    wire rd_en;
    wire wr_en;

    wire [23:0] addr_fifo_dout;
    wire addr_fifo_valid;
    wire addr_fifo_empty;
    wire addr_fifo_wr_en;
    (* mark_debug = "true" *) reg addr_fifo_rd_en;

    wire rd_fifo_full;
    wire rd_fifo_rd_en;

    wire wr_data_fifo_valid;
    wire wr_data_fifo_rd_en;
    wire wr_data_fifo_wr_en;
    
    wire wr_done;

    wire [AXIL_ADDR_WIDTH - 1:0] rd_wr_addr; 

    (* mark_debug = "true" *) reg [2:0] cstate;
    (* mark_debug = "true" *) reg [2:0] nstate;

    reg [1:0] handshake_wr;
    wire handshake_ar;
    wire handshake_r;
    wire handshake_aw;
    wire handshake_w;

    reg axil_awvalid;
    reg [31 : 0] axil_awaddr;
    reg axil_wvalid;
    reg [31 : 0] axil_wdata;
    reg axil_arvalid;
    reg [31 : 0] axil_araddr;
    reg axil_rready;

    wire [23:0] wr_mask;
    wire [31:0] wr_data_dout;
    wire rd_fifo_wr_en;

    assign m_axil_awprot = 3'b0;
    assign m_axil_arprot = 3'b0;
    assign m_axil_wstrb = 4'hF;
    assign m_axil_bready = 1'b1;

    assign aclk = eclk;
    assign aresetn = nrst;

    assign rd_en = !nce & !noe;
    assign wr_en = !nce & !nwe;
    assign wr_data_fifo_wr_en = wr_en && !emif_addr[AXIL_ADDR_WIDTH - 2] && (((~wr_mask) & emif_addr) == (EMIF_ADDR_BASE & (~wr_mask)));
    assign wr_data_fifo_rd_en = handshake_w;
    assign rd_fifo_wr_en = handshake_r;
    assign busy = (!addr_fifo_empty) || (cstate != S_IDLE);
    assign wr_mask = 24'b0 | {(AXIL_ADDR_WIDTH - 1){1'b1}};
    assign addr_fifo_wr_en = (((~wr_mask) & emif_addr) == (EMIF_ADDR_BASE & (~wr_mask))) && wr_en;
    assign rd_fifo_rd_en = (((~wr_mask) & emif_addr) == (EMIF_ADDR_BASE & (~wr_mask))) && rd_en;

    assign rd_wr_addr[1:0] = 2'b0;
    assign rd_wr_addr[AXIL_ADDR_WIDTH - 1:2] = addr_fifo_dout[AXIL_ADDR_WIDTH - 3:0];

    assign wr_done = &handshake_wr;
    assign handshake_ar = m_axil_arvalid & m_axil_arready;
    assign handshake_r = m_axil_rvalid & m_axil_rready;
    assign handshake_aw = m_axil_awvalid & m_axil_awready;
    assign handshake_w = m_axil_wvalid & m_axil_wready;

    assign m_axil_awvalid = axil_awvalid;
    assign m_axil_awaddr = axil_awaddr;
    assign m_axil_wvalid = axil_wvalid;
    assign m_axil_wdata = axil_wdata;
    assign m_axil_arvalid = axil_arvalid;
    assign m_axil_araddr = axil_araddr;
    assign m_axil_rready = axil_rready;

    // cstate
    always @(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            cstate <= S_IDLE;
        end
        else begin
            cstate <= nstate;
        end
    end

    //nstate
    always @(*) begin
        nstate = cstate;
        case (cstate)
            S_IDLE:
                if(addr_fifo_valid) begin
                    // 1 for read, 0 for write
                    if(addr_fifo_dout[AXIL_ADDR_WIDTH - 2]) begin
                        nstate = S_READ;
                    end
                    else begin
                        nstate = S_WRITE;
                    end
                end
            S_WRITE:
                if(wr_done) begin
                    nstate = S_IDLE;
                end
            S_READ:
                if(handshake_ar) begin
                    nstate = S_WAITRD;
                end
            S_WAITRD:
                if(handshake_r) begin
                    nstate = S_IDLE;
                end
            default: 
                nstate = S_IDLE;
        endcase
    end

    // [1:0] handshake_wr;
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            handshake_wr <= 'b0;
        end
        else begin
            if(wr_done) begin
                handshake_wr <= 'b0;
            end
            else begin
                if(handshake_aw) begin
                    handshake_wr[1] <= 1'b1;
                end
                if(handshake_w) begin
                    handshake_wr[0] <= 1'b1;
                end
            end
        end
    end

    // axil_awvalid
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            axil_awvalid <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_WRITE) begin
                axil_awvalid <= 1'b1;
            end
            else if(handshake_aw) begin
                axil_awvalid <= 1'b0;
            end
        end
    end

    // axil_wvalid;
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            axil_wvalid <= 1'b0;
            axil_wdata <= 'b0;
        end
        else begin
            if(axil_wvalid && handshake_w) begin
                axil_wvalid <= 1'b0;
                axil_wdata <= 'b0;
            end
            else if(((cstate == S_IDLE && nstate == S_WRITE) || cstate == S_WRITE) && wr_data_fifo_valid)begin
                axil_wvalid <= 1'b1;
                axil_wdata <= wr_data_dout;
            end
        end
    end

    // axil_arvalid;
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            axil_arvalid <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_READ) begin
                axil_arvalid <= 1'b1;
            end
            else if(handshake_ar) begin
                axil_arvalid <= 1'b0;
            end
        end
    end

    // axil_rready;
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            axil_rready <= 1'b0;
        end
        else begin
            if(cstate == S_READ && nstate == S_WAITRD && !rd_fifo_full) begin
                axil_rready <= 1'b1;
            end
            else if(handshake_r) begin
                axil_rready <= 1'b0;
            end
        end
    end

    // addr_fifo_rd_en
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            addr_fifo_rd_en <= 1'b0;
        end
        else begin
            if(cstate == S_IDLE && addr_fifo_valid) begin
                addr_fifo_rd_en <= 1'b1;
            end
            else begin
                addr_fifo_rd_en <= 1'b0;
            end
        end
    end

    

    // [31 : 0] axil_awaddr;
    // [31 : 0] axil_araddr;
    always@(posedge eclk or negedge nrst) begin
        if(!nrst) begin
            axil_awaddr <= 'b0;
            axil_araddr <= 'b0;
        end
        else begin
            if(cstate == S_IDLE && nstate == S_WRITE) begin
                axil_awaddr <= rd_wr_addr + AXIL_ADDR_BASE;
            end
            else if(handshake_aw) begin
                axil_awaddr <= 'b0;
            end
            if(cstate == S_IDLE && nstate == S_READ) begin
                axil_araddr <= rd_wr_addr + AXIL_ADDR_BASE;
            end
            else if(handshake_ar)begin
                axil_araddr <= 'b0;
            end
        end
    end

    genvar gv_i;

    generate
        for(gv_i = 0;gv_i < 32; gv_i = gv_i + 1) begin
            IOBUF IOBUF_inst (
                .O(emif_data_in[gv_i]),   // 1-bit output: Buffer output
                .I(emif_data_out[gv_i]),   // 1-bit input: Buffer input
                .IO(emif_data[gv_i]), // 1-bit inout: Buffer inout (connect directly to top-level port)
                .T(wr_en)    // 1-bit input: 3-state enable input
            );
        end
    endgenerate
    
    addr_fifo addr_fifo_inst (
        .clk(eclk),                // input wire clk
        .srst(!nrst),              // input wire srst
        .din(emif_addr),          // input wire [23 : 0] din
        .wr_en(addr_fifo_wr_en),            // input wire wr_en
        .rd_en(addr_fifo_rd_en),            // input wire rd_en
        .dout(addr_fifo_dout),              // output wire [23 : 0] dout
        .full(full),              // output wire full
        .empty(addr_fifo_empty),            // output wire empty
        .valid(addr_fifo_valid)            // output wire valid
    );

    rd_data_fifo rd_data_fifo_inst (
        .clk(eclk),      // input wire clk
        .srst(!nrst),    // input wire srst
        .din(m_axil_rdata),      // input wire [31 : 0] din
        .wr_en(rd_fifo_wr_en),  // input wire wr_en
        .rd_en(rd_fifo_rd_en),  // input wire rd_en
        .dout(emif_data_out),    // output wire [31 : 0] dout
        .full(rd_fifo_full),    // output wire full
        .empty(rd_fifo_empty)  // output wire empty
    );

    wr_data_fifo wr_data_fifo_inst (
        .clk(eclk),      // input wire clk
        .srst(!nrst),    // input wire srst
        .din(emif_data_in),      // input wire [31 : 0] din
        .wr_en(wr_data_fifo_wr_en),  // input wire wr_en
        .rd_en(wr_data_fifo_rd_en),  // input wire rd_en
        .dout(wr_data_dout),    // output wire [31 : 0] dout
        .full(),    // output wire full
        .empty(),  // output wire empty
        .valid(wr_data_fifo_valid)  // output wire valid
    );
endmodule
