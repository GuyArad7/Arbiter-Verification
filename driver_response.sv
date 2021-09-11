// Created by Guy Arad on 02/09/2021.

class driver_response extends uvm_driver#(transaction);
	`uvm_component_utils(driver_response)

	int TIMEOUT_LIMIT = 2**16-1;
	virtual if_response vinf;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual if_response)::get(this , "" , "if_response", vinf);
	endfunction

	task run_phase(uvm_phase phase);
		drive();
	endtask

	virtual task drive();
		int cycles;
		reset_outputs_in_dut();

		forever begin
			wait(vinf.rd | vinf.wr) begin
				delay(cycles);
				
				if (cycles == TIMEOUT_LIMIT)
					#1 continue;

				@(negedge vinf.clk);
				push_outputs_to_dut(); 
				print();
				
				@(negedge vinf.clk);
				reset_outputs_in_dut();
			end
		end
	endtask

	//Create delay, and return delay duration
	virtual task delay(output int cycles);
		randcase
			100: cycles = $urandom_range(1,10);
			50:  cycles = $urandom_range(10,100);
			20:  cycles = $urandom_range(100,1000);
			1:   cycles = $urandom_range(1000,10000);
			2:   cycles = TIMEOUT_LIMIT;
		endcase

		for(int i=0; i<cycles; i++) begin
			@(posedge vinf.clk); 
		end
	endtask

	virtual function void push_outputs_to_dut();
		vinf.drd = vinf.rd ? $urandom() : 0;
		vinf.ack = 1;
	endfunction

	virtual function void reset_outputs_in_dut();
		vinf.drd = 0;
		vinf.ack = 0;
	endfunction

	//Print pushed values
	virtual function void print();
		`uvm_info("driver_response", $sformatf("DUT received drd=%h, ack=%h",vinf.drd, vinf.ack), UVM_MEDIUM)
	endfunction
endclass
