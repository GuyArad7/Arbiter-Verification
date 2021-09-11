// Created by Guy Arad on 02/09/2021.

class sequence_random extends uvm_sequence#(transaction);
	`uvm_object_utils(sequence_random)

	function new(string name = "");
		super.new(name);
	endfunction

	task body();
		transaction trans;

		repeat(1) begin
			`uvm_do(trans)
		end
	endtask
endclass

