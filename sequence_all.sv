// Created by Guy Arad on 02/09/2021.

class sequence_all extends uvm_sequence#(transaction);
	`uvm_object_utils(sequence_all)

	sequence_disable seq1;
	sequence_read 	 seq2;
	sequence_write 	 seq3;
	sequence_random  seq4;

	function new(string name = "");
		super.new(name);
	endfunction

	task body();
		repeat(1000) begin
			randcase
				0: `uvm_do(seq1)
				0: `uvm_do(seq2)
				0: `uvm_do(seq3)
				1: `uvm_do(seq4)
			endcase
		end
	endtask
endclass

