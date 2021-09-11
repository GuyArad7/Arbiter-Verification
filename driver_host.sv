// Created by Guy Arad on 02/09/2021.

class driver_host extends uvm_driver#(transaction);
	`uvm_component_utils(driver_host)

	virtual if_host vinf;
	transaction trans;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual if_host)::get(this , "" , "if_host", vinf);
	endfunction

	task run_phase(uvm_phase phase);
		drive();
	endtask

	virtual task drive();
		forever begin
			seq_item_port.get_next_item(trans); 

			@(negedge vinf.clk);
			push_transaction_to_dut();
			print();

			//Wait for ack
			if(trans.rd | trans.wr) begin
				wait(vinf.ack[0]==1);

				@(negedge vinf.clk);
				release_bus();
			end

			seq_item_port.item_done();
		end
	endtask

	virtual function void push_transaction_to_dut();
		vinf.addr = trans.addr;
		vinf.rd	  = trans.rd;
		vinf.wr   = trans.wr;
		vinf.be   = trans.be;
		vinf.dwr  = trans.dwr;
	endfunction

	virtual function void release_bus();
		vinf.rd = 0;
		vinf.wr = 0;
	endfunction

	//Print transaction
	virtual function void print();
		`uvm_info("driver_host", trans.sprint(), UVM_MEDIUM)
	endfunction
endclass
