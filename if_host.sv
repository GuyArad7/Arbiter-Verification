// Created by Guy Arad on 02/09/2021.

interface if_host(input logic clk,rst);
	logic		cpu;
	logic [31:0]	addr;
	logic		rd;
	logic		wr;
	logic [3:0]	be;
	logic [31:0]	dwr;
	logic [31:0]	drd;
	logic [1:0]	ack;

endinterface

