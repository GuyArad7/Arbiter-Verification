// Created by Guy Arad on 02/09/2021.

class test extends uvm_test;
	`uvm_component_utils(test)

	environment env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
  		env = environment::type_id::create("env" , this);
	endfunction

	task run_phase(uvm_phase phase);
		sequence_all seq1;
		sequence_all seq2;
		sequence_all seq3;
		sequence_all seq4;

		seq1 = sequence_all::type_id::create("seq1");
		seq2 = sequence_all::type_id::create("seq2");
  		seq3 = sequence_all::type_id::create("seq3");
		seq4 = sequence_all::type_id::create("seq4");

		/* Start the 4 hosts in parallel */

		phase.raise_objection(.obj(this));
		fork
  			seq1.start(env.agent_host_master.seqer);
		  	seq2.start(env.agent_host_slave.seqer);
		  	seq3.start(env.agent_host_test.seqer);
		  	seq4.start(env.agent_host_extra.seqer);
		join
		phase.drop_objection(.obj(this));
	endtask
endclass

