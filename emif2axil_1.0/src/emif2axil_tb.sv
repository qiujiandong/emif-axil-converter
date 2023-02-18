`timescale 1ns / 1ps
`include "common.sv"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/18 09:19:14
// Design Name: 
// Module Name: emif2axil_tb
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


module emif2axil_tb;

import SimSrcGen::*;

logic eclk;
logic nrst;

logic [31:0] cnt;

logic nce;
logic noe;
logic nwe;
logic [23:0] emif_addr;
// logic [31:0] emif_data_input;

// logic [1 : 0] m_axil_rresp;
// logic m_axil_bvalid;
// logic [1 : 0] m_axil_bresp;

logic m_axil_awready;
logic m_axil_wready;
logic m_axil_arready;

logic m_axil_rvalid;
logic [31 : 0] m_axil_rdata;

wire full;
wire busy;
wire rd_fifo_empty;
wire [31:0] emif_data;
// axi-lite master interface
wire aclk;
wire aresetn;
wire [2 : 0] m_axil_awprot;
wire [3 : 0] m_axil_wstrb;
wire [2 : 0] m_axil_arprot;
// b
wire m_axil_bready;
// aw
wire m_axil_awvalid;
wire [31 : 0] m_axil_awaddr;
// w
wire m_axil_wvalid;
wire [31 : 0] m_axil_wdata;
// ar
wire m_axil_arvalid;
wire [31 : 0] m_axil_araddr;
// r
wire m_axil_rready;

initial GenClk(eclk, 1, 16); // period = 16ns -> 62.5MHz
initial GenArst(eclk, nrst, 2, 3); // delay 2ns, duration 3 period
// initial begin
//     force emif_data = 32'hAAAAAAAA;
// end
assign emif_data = (!nce && !nwe)? 32'h55555555 : 32'hz;
// assign emif_data = emif_data_input;

// logic m_axil_awready;
// logic m_axil_wready;
// logic m_axil_arready;
always_ff@(posedge eclk or negedge nrst) begin
    if(!nrst) begin
        m_axil_awready <= 1'b0;
        m_axil_wready <= 1'b0;
        m_axil_arready <= 1'b0;
    end
    else begin
        m_axil_awready <= {$random} % 2;
        m_axil_wready <= {$random} % 2;
        m_axil_arready <= {$random} % 2;
    end
end

// cnt
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        cnt <= 'b0;
    end
    else begin
        cnt <= cnt + 'b1;
    end
end

// logic nce;
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        nce <= 1'b1;
    end
    else begin
        if (cnt == 32'd10) begin
            nce <= 1'b0;
        end
        // if(cnt == 32'd15) begin
        //     nce = 1'b1;
        // end
    end
end
// logic noe;
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        noe <= 1'b1;
    end
    else begin
        if (cnt == 32'd50) begin
            noe <= 1'b0;
        end
        if(cnt == 32'd51) begin
            noe <= 1'b1;
        end
    end
end
// logic nwe;
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        nwe <= 1'b1;
    end
    else begin
        if (cnt == 32'd20) begin
            nwe <= 1'b0;
        end
        if(cnt == 32'd21) begin
            nwe <= 1'b1;
        end
        if (cnt == 32'd30) begin
            nwe <= 1'b0;
        end
        if(cnt == 32'd31) begin
            nwe <= 1'b1;
        end
        if (cnt == 32'd60) begin
            nwe <= 1'b0;
        end
        if(cnt == 32'd61) begin
            nwe <= 1'b1;
        end
    end
end

// logic [23:0] emif_addr;
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        emif_addr <= 'b0;
    end
    else begin
        if (cnt == 32'd20) begin
            emif_addr <= 24'h000555; // write 0x555
        end
        if(cnt == 32'd30) begin
            emif_addr <= 24'h001AAA; // read 0xaaa
        end
        if(cnt == 32'd60) begin
            emif_addr <= 24'h101AAA; // read 0xaaa
        end
    end
end
// logic [31:0] emif_data_input;
// always_ff @( posedge eclk or negedge nrst ) begin
//     if(!nrst) begin
//         emif_data_input <= 'b0;
//     end
//     else begin
//         if (cnt == 32'd20) begin
//             emif_data_input <= 32'hAAAAAAAA;
//         end
//         if(cnt == 32'd30) begin
//             emif_addr <= 32'h55555555;
//         end
//     end
// end

// logic m_axil_rvalid;
always_ff @( posedge eclk or negedge nrst ) begin
    if(!nrst) begin
        m_axil_rvalid <= 1'b0;
        m_axil_rdata <= 'b0;
    end
    else begin
        if (m_axil_arvalid & m_axil_arready) begin
            m_axil_rvalid <= 1'b1;
            m_axil_rdata <= 32'hAAAAAAAA;
        end
        else if(m_axil_rvalid & m_axil_rready) begin
            m_axil_rvalid <= 1'b0;
            m_axil_rdata <= 'b0;
        end
    end
end

// logic [31 : 0] m_axil_rdata;

emif2axil #(
    .AXIL_ADDR_BASE(32'hC0000000),
    .AXIL_ADDR_WIDTH(14) // 16 for 64kB, max is 25 for 32MB
)
emif2axil_inst
(
    .eclk(eclk),
    .nrst(nrst),

    .full(full),
    .busy(busy),
    .rd_fifo_empty(rd_fifo_empty),

    .nce(nce),
    .noe(noe),
    .nwe(nwe),

    .emif_data(emif_data),
    .emif_addr(emif_addr),

// axi-lite master interface
    .aclk(aclk),
    .aresetn(aresetn),

    .m_axil_awprot(m_axil_awprot),
    .m_axil_wstrb(m_axil_wstrb),
    .m_axil_arprot(m_axil_arprot),
    .m_axil_rresp(2'b00),
    // b
    .m_axil_bvalid(1'b0),
    .m_axil_bready(m_axil_bready),
    .m_axil_bresp(2'b00),

    // aw
    .m_axil_awvalid(m_axil_awvalid),
    .m_axil_awready(m_axil_awready),
    .m_axil_awaddr(m_axil_awaddr),
    // w
    .m_axil_wvalid(m_axil_wvalid),
    .m_axil_wready(m_axil_wready),
    .m_axil_wdata(m_axil_wdata),
    // ar
    .m_axil_arvalid(m_axil_arvalid),
    .m_axil_arready(m_axil_arready),
    .m_axil_araddr(m_axil_araddr),
    // r
    .m_axil_rvalid(m_axil_rvalid),
    .m_axil_rready(m_axil_rready),
    .m_axil_rdata(m_axil_rdata)
// end of axi master interface
    );
endmodule
