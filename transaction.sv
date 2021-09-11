// Created by Guy Arad on 02/09/2021.

class transaction extends uvm_sequence_item;

	rand logic		cpu;
	rand logic [31:0]	addr;
	rand logic		rd;
	rand logic		wr;
	rand logic [3:0]	be;
	rand logic [31:0]	dwr;
	     logic [31:0]	drd;
	     logic [1:0]	ack;

	constraint rd_wr {rd!=1 | wr!=1;}

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(transaction)
		`uvm_field_int(cpu, UVM_ALL_ON)
		`uvm_field_int(addr,UVM_ALL_ON)
		`uvm_field_int(rd,  UVM_ALL_ON)
		`uvm_field_int(wr,  UVM_ALL_ON)
		`uvm_field_int(be,  UVM_ALL_ON)
		`uvm_field_int(dwr, UVM_ALL_ON)
		`uvm_field_int(drd, UVM_ALL_ON)
		`uvm_field_int(ack, UVM_ALL_ON)
	`uvm_object_utils_end
endclass

