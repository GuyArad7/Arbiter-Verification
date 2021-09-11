// Created by Guy Arad on 02/09/2021.

class monitor_host extends uvm_monitor;
	`uvm_component_utils(monitor_host)

	uvm_analysis_port#(transaction) mon_ap_host;
	virtual if_host mon_inf;
	transaction trans, trans_cov;

	covergroup cov;
		CPU:   coverpoint trans_cov.cpu  {
			        bins Zero = {0}; 
			        bins One  = {1};
		       }
		ADDR:  coverpoint trans_cov.addr {
			        bins Addresses   [5] = {[0:$]};
		       }
		BE:    coverpoint trans_cov.be   {
			        bins Byte_Enables[2] = {[0:$]};
		       }
		DWR:   coverpoint trans_cov.dwr  {
			        bins Data_Writes [5] = {[0:$]};
		       }
		DRD:   coverpoint trans_cov.drd iff trans_cov.rd {
			        bins Data_Reads  [5] = {[0:$]};
		       }
		RD_WR: coverpoint {trans_cov.rd,trans_cov.wr} {
			        bins Write   = {1}; 
			        bins Read    = {2};
		       }
		ACK:   coverpoint trans_cov.ack {
			        bins Ack     = {1}; 
			        bins Timeout = {3};
		       }
		RD_WR_X_ACK: cross RD_WR, ACK;
		option.per_instance = 1;
	endgroup
  
	function new(string name, uvm_component parent);
		super.new(name, parent);
		cov = new;
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual if_host)::get(this , "" , "if_host" , mon_inf);
		mon_ap_host= new("mon_ap_host" , this);
	endfunction
  
   	task run_phase(uvm_phase phase);
		trans = transaction::type_id::create("trans", this);

		forever begin
			@(posedge mon_inf.clk);
			if(mon_inf.rd | mon_inf.wr) begin 

				//Send initial transaction
				get_inputs_from_dut();
				#1 print();
				mon_ap_host.write(trans);

				//Wait for answer
				wait(mon_inf.ack[0] == 1);

				//Send complete transaction
				get_outputs_from_dut();
				print();
				mon_ap_host.write(trans);

				coverage();
			end
		end
	endtask

	virtual function void get_inputs_from_dut();
		trans.cpu  = mon_inf.cpu;
		trans.addr = mon_inf.addr;
		trans.rd   = mon_inf.rd;
		trans.wr   = mon_inf.wr;
		trans.be   = mon_inf.be;
		trans.dwr  = mon_inf.dwr;
		trans.drd  = 0;
		trans.ack  = 0;
	endfunction

	virtual function void get_outputs_from_dut();
		trans.drd = mon_inf.drd;
		trans.ack = mon_inf.ack;
	endfunction

	//Print monitored values
	virtual function void print();
		`uvm_info("monitor_host", $sformatf("cpu=%h, addr=%h, rd=%h,wr=%h,be=%h,dwr=%h,drd=%h,ack=%h",trans.cpu, trans.addr, trans.rd, trans.wr, trans.be, trans.dwr, trans.drd, trans.ack), UVM_MEDIUM)
	endfunction

	virtual function void coverage();
		trans_cov = trans;
		cov.sample();
	endfunction
endclass

