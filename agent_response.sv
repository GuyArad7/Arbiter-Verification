// Created by Guy Arad on 02/09/2021.

class agent_response extends uvm_agent;
	`uvm_component_utils(agent_response)

	uvm_analysis_port#(transaction) agent_ap_response;

	driver_response	   drv_response;
	monitor_response   mon_response;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agent_ap_response = new("agent_ap_response" , this);
		drv_response = driver_response::type_id::create("drv_response" , this);
		mon_response = monitor_response::type_id::create("mon_response" , this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mon_response.mon_ap_response.connect(agent_ap_response);
	endfunction

endclass


