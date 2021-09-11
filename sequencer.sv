// Created by Guy Arad on 02/09/2021.

class sequencer extends uvm_sequencer#(transaction);
	`uvm_component_utils(sequencer)

	function new(string name, uvm_component parent);
		super.new(name);
	endfunction
  
endclass

