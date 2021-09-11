// Created by Guy Arad on 02/09/2021.

class environment extends uvm_env;
	`uvm_component_utils(environment)

	agent_host 	agent_host_master;
	agent_host 	agent_host_slave;
	agent_host 	agent_host_test;
	agent_host 	agent_host_extra;
	agent_response	agent_resp;
	scoreboard     	scb;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//Create agents
		agent_host_master = agent_host::type_id::create("agent_host_master",this);
		agent_host_slave  = agent_host::type_id::create("agent_host_slave" ,this);
		agent_host_test   = agent_host::type_id::create("agent_host_test"  ,this);
		agent_host_extra  = agent_host::type_id::create("agent_host_extra" ,this);
		agent_resp = agent_response::type_id::create("agent_response",this);
		scb = scoreboard::type_id::create("scb",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//Connect agents to scoreboard
		agent_host_master.agent_ap_host.connect	(scb.scb_export_host[0]);
		agent_host_slave.agent_ap_host.connect	(scb.scb_export_host[1]);
		agent_host_test.agent_ap_host.connect	(scb.scb_export_host[2]);
		agent_host_extra.agent_ap_host.connect	(scb.scb_export_host[3]);
		agent_resp.agent_ap_response.connect (scb.scb_export_response);
	endfunction
endclass
