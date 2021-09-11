// Created by Guy Arad on 02/09/2021.

class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)

	//Declare 5 analysis_export
	uvm_analysis_export #(transaction) scb_export_host[4];
	uvm_analysis_export #(transaction) scb_export_response;

	//Declare 5 fifos
	uvm_tlm_analysis_fifo #(transaction) host_fifo[4];
	uvm_tlm_analysis_fifo #(transaction) response_fifo;

	transaction transaction_host;
	transaction transaction_response;

	int TIMEOUT_LIMIT = 2**16-1;
	bit[2:0] MSTR  = 3'b000;
	bit[2:0] SLAV  = 3'b001;
	bit[2:0] TEST  = 3'b010;
	bit[2:0] EXTR  = 3'b011;
	bit[2:0] IDLE  = 3'b111;
	bit[2:0] current_state = MSTR;

	bit[2:0] current_state_cov;
	bit[2:0] hosts_active_cov;

	covergroup cov;
		STATES: coverpoint current_state_cov {
			        bins Master = {0}; 
			        bins Slave  = {1}; 
			        bins Test   = {2}; 
			        bins Extra  = {3}; 
			        bins Idle   = {7};
		        } 
		HOSTS_ACTIVE: coverpoint hosts_active_cov {
			        bins Idle  = {0}; 
			        bins One   = {1}; 
			        bins Two   = {2}; 
			        bins Three = {3}; 
			        bins Four  = {4};
		        } 
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);
		transaction_host      = new("transaction_host");
		transaction_response  = new("transaction_response");
		cov = new;
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//Create 5 exports and fifos
		foreach(scb_export_host[i])
			scb_export_host[i] = new($sformatf("scb_export_host[%d]",i), this);
		foreach(host_fifo[i])	    
			host_fifo[i]	   = new($sformatf("host_fifo[%d]",i), this);
		scb_export_response = new("scb_export_response", this);
		response_fifo	    = new("response_fifo", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		//Connect 5 fifos
		foreach(scb_export_host[i])
			scb_export_host[i].connect(host_fifo[i].analysis_export);
		scb_export_response.connect(response_fifo.analysis_export);
	endfunction


     	task run();
		forever begin
			get_response_transaction();

			round_robin();

			//First compare
			host_fifo[current_state].get(transaction_host);
			compare();

			//Last compare (ack and drd check)
			host_fifo[current_state].get(transaction_host);

			if(transaction_host.ack == 1) begin
				response_fifo.get(transaction_response);
				compare();
			end
		end
     	endtask

 	//Get first non-empty response transaction
	task get_response_transaction();
		response_fifo.get(transaction_response);
	
		//Idle check
		if(!transaction_response.rd && !transaction_response.wr) begin
			`uvm_info("scoreboard_idle", "", UVM_MEDIUM)
			current_state = IDLE;
			coverage();

			response_fifo.get(transaction_response);
		end
	endtask


	//Round-robin algorithm
	virtual function void round_robin();
		case(current_state)
			MSTR : current_state = !host_fifo[1].is_empty() ? SLAV : !host_fifo[2].is_empty() ? TEST : !host_fifo[3].is_empty() ? EXTR : MSTR;

			SLAV : current_state = !host_fifo[2].is_empty() ? TEST : !host_fifo[3].is_empty() ? EXTR : !host_fifo[0].is_empty() ? MSTR : SLAV;

			TEST : current_state = !host_fifo[3].is_empty() ? EXTR : !host_fifo[0].is_empty() ? MSTR : !host_fifo[1].is_empty() ? SLAV : TEST;

			EXTR : current_state = !host_fifo[0].is_empty() ? MSTR : !host_fifo[1].is_empty() ? SLAV : !host_fifo[2].is_empty() ? TEST : EXTR;

			default : current_state = !host_fifo[0].is_empty() ? MSTR : !host_fifo[1].is_empty() ? SLAV : !host_fifo[2].is_empty() ? TEST : !host_fifo[3].is_empty() ? EXTR : IDLE;
		endcase

		coverage();
	endfunction

	//Compare the host and response transactions.
	virtual function void compare(); 
		if(equal()) begin
			print_response();

			if(current_state == MSTR)
				`uvm_info("compare OK", {"Master\n"}, UVM_MEDIUM)
			else if (current_state == SLAV)
				`uvm_info("compare OK", {"Slave\n"}, UVM_MEDIUM)
			else if (current_state == TEST)
				`uvm_info("compare OK", {"Test\n"}, UVM_MEDIUM)
			else
				`uvm_info("compare OK", {"Extra\n"}, UVM_MEDIUM)
		end 

		else begin
			print_host();
			print_response();
			`uvm_info("compare Fail", {"Test: Fail!\n"}, UVM_LOW);
		end
	endfunction


	//Return 1 if the host and response transactions are equal.
	virtual function int equal();
		return (transaction_host.cpu  == transaction_response.cpu & 
			transaction_host.addr == transaction_response.addr &
			transaction_host.rd   == transaction_response.rd &
			transaction_host.wr   == transaction_response.wr &
			transaction_host.be   == transaction_response.be &
			transaction_host.dwr  == transaction_response.dwr &

			((transaction_host.drd == transaction_response.drd &
			  transaction_host.ack == transaction_response.ack) |
			  transaction_host.ack > 1));
	endfunction

	virtual function void print_host();
		`uvm_info("scoreboard_host", $sformatf("cpu=%h,addr=%h,rd=%h,wr=%h,be=%h,dwr=%h,drd=%h,ack=%h", transaction_host.cpu, transaction_host.addr, transaction_host.rd, transaction_host.wr, transaction_host.be, transaction_host.dwr, transaction_host.drd, transaction_host.ack), UVM_MEDIUM)
	endfunction

	virtual function void print_response();
		`uvm_info("scoreboard_response", $sformatf("cpu=%h,addr=%h,rd=%h,wr=%h,be=%h,dwr=%h,drd=%h,ack=%h", transaction_response.cpu, transaction_response.addr, transaction_response.rd, transaction_response.wr, transaction_response.be, transaction_response.dwr, transaction_response.drd, transaction_response.ack), UVM_MEDIUM)
	endfunction

	virtual function void coverage;
		current_state_cov = current_state;
		hosts_active_cov = current_state==IDLE ? 0 : !host_fifo[0].is_empty() + !host_fifo[1].is_empty() + !host_fifo[2].is_empty() + !host_fifo[3].is_empty();
		cov.sample();
	endfunction

endclass
