// Created by Guy Arad on 02/09/2021.

class agent_host extends uvm_agent;
	`uvm_component_utils(agent_host)

	uvm_analysis_port#(transaction) agent_ap_host;
	string sqr_name;   

	sequencer 	seqer;
	driver_host 	drv_host;
	monitor_host 	mon_host;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(string)::get(this , "" , "sqr_name" , sqr_name);

		agent_ap_host	= new("agent_ap_host" , this);
		seqer		= sequencer::type_id::create(sqr_name , this);
		drv_host	= driver_host::type_id::create("drv_host" , this);
		mon_host	= monitor_host::type_id::create("mon_host" , this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv_host.seq_item_port.connect(seqer.seq_item_export);
		mon_host.mon_ap_host.connect(agent_ap_host);
	endfunction
endclass

