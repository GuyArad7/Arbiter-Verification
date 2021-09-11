// Created by Guy Arad on 02/09/2021.

class monitor_response extends uvm_monitor;
	`uvm_component_utils(monitor_response)

	uvm_analysis_port#(transaction) mon_ap_response;
	virtual if_response mon_inf;
	transaction trans;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual if_response)::get(this, "" , "if_response" , mon_inf);
		mon_ap_response = new("mon_ap_response" , this);
	endfunction
  
	task run_phase(uvm_phase phase);
		int cnt_empty = 0;
		trans = transaction::type_id::create("trans" , this);

		#30
		forever begin
			@(posedge mon_inf.clk);

			if(!mon_inf.rd && !mon_inf.wr) begin
				if(++cnt_empty == 2)
					send_idle_transaction();
				continue;
			end

			cnt_empty = 0;

			//Send initial transaction
			get_inputs_from_dut();
			print();
			mon_ap_response.write(trans);

			//Wait for ack or timeout
			wait(!mon_inf.rd && !mon_inf.wr) begin

				//Send complete transaction
				if(mon_inf.ack==1) begin
					get_outputs_from_dut();
					print();
					mon_ap_response.write(trans);
				end
			end

			@(negedge mon_inf.clk);
		end
	endtask

	virtual function void send_idle_transaction();
		trans.rd = 0;
		trans.wr = 0;
		mon_ap_response.write(trans);
	endfunction

	virtual function void get_inputs_from_dut();
		trans.cpu  = mon_inf.cpu;
		trans.addr = mon_inf.addr;
		trans.rd   = mon_inf.rd;
		trans.wr   = mon_inf.wr;
		trans.be   = mon_inf.be;
		trans.dwr  = mon_inf.dwr;
		trans.drd  = mon_inf.drd;
		trans.ack  = mon_inf.ack;
	endfunction

	virtual function void get_outputs_from_dut();
		trans.drd = mon_inf.drd;
		trans.ack = mon_inf.ack;
	endfunction

	//Print monitored values
	virtual function void print();
		`uvm_info("monitor_response", $sformatf("cpu=%h, addr=%h, rd=%h,wr=%h,be=%h,dwr=%h,drd=%h,ack=%h",trans.cpu, trans.addr, trans.rd, trans.wr, trans.be, trans.dwr, trans.drd, trans.ack), UVM_MEDIUM)
	endfunction
endclass

