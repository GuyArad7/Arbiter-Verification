// Created by Guy Arad on 02/09/2021.

class sequence_disable extends uvm_sequence#(transaction);
	`uvm_object_utils(sequence_disable)

	function new(string name = "");
		super.new(name);
	endfunction

	task body();
		transaction trans;
		
		repeat(1) begin
			`uvm_do_with(trans, {rd==0; wr==0;})
		end
	endtask
endclass

