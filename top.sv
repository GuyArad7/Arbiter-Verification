// Created by Guy Arad on 02/09/2021.

`include "arbiter_pkg.sv"
`include "arbiter.v"
`include "if_host.sv"
`include "if_response.sv"

module top;
	import uvm_pkg::*;
	import arbiter_pkg::*;

	bit clk;
	bit rst;

	//Interface handlers
	if_host		m_inf(clk,rst);
	if_host		s_inf(clk,rst);
	if_host		t_inf(clk,rst);
	if_host		e_inf(clk,rst);
	if_response	r_inf(clk,rst);

	//DUT instance. Connects the Interfaces to the DUT.
	arbiter dut
	(
	// Master Host
	.mcpu 	(m_inf.cpu),
	.maddr 	(m_inf.addr),
	.mrd 	(m_inf.rd),
	.mwr 	(m_inf.wr),
	.mbe 	(m_inf.be),
	.mdwr 	(m_inf.dwr),
	.mdrd 	(m_inf.drd),
	.mack 	(m_inf.ack),
	// Slave Host
	.scpu 	(s_inf.cpu),
	.saddr 	(s_inf.addr),
	.srd 	(s_inf.rd),
	.swr 	(s_inf.wr),
	.sbe 	(s_inf.be),
	.sdwr 	(s_inf.dwr),
	.sdrd 	(s_inf.drd),
	.sack 	(s_inf.ack),
	// Test Host
	.tcpu 	(t_inf.cpu),
	.taddr 	(t_inf.addr),
	.trd 	(t_inf.rd),
	.twr 	(t_inf.wr),
	.tbe 	(t_inf.be),
	.tdwr 	(t_inf.dwr),
	.tdrd 	(t_inf.drd),
	.tack 	(t_inf.ack),
	// Extra Host
	.ecpu 	(e_inf.cpu),
	.eaddr 	(e_inf.addr),
	.erd 	(e_inf.rd),
	.ewr 	(e_inf.wr),
	.ebe 	(e_inf.be),
	.edwr 	(e_inf.dwr),
	.edrd 	(e_inf.drd),
	.eack 	(e_inf.ack),
	// device
	.cpu_bus (r_inf.cpu),
	.add_bus (r_inf.addr),
	.rd_bus  (r_inf.rd),
	.wr_bus  (r_inf.wr),
	.byte_en (r_inf.be),
	.data_bus_wr (r_inf.dwr),
	.data_bus_rd (r_inf.drd),
	.ack_bus (r_inf.ack),
	// General
	.clk (clk),
	.reset_n (rst)
	);

	//Variable initialization
	initial begin
		clk <= 1'b0;
		rst <= 1'b1;
	end

	//Clock generation
	always
		#5 clk = ~clk;

	//Reset generation
	initial begin  
		#1 rst = 1'b0;
		#3 rst = 1'b1;
	end

	initial begin  
		m_inf.cpu <= 1'b1;
		s_inf.cpu <= 1'b0;
		t_inf.cpu <= 1'b0;
		e_inf.cpu <= 1'b0;
	end


	initial begin
		//Registers the Interface in the configuration block
		uvm_config_db#(virtual if_host)::set(null, "*.agent_host_master.*" , "if_host", m_inf);
		uvm_config_db#(virtual if_host)::set(null, "*.agent_host_slave.*"  , "if_host", s_inf);
		uvm_config_db#(virtual if_host)::set(null, "*.agent_host_test.*"   , "if_host", t_inf);
		uvm_config_db#(virtual if_host)::set(null, "*.agent_host_extra.*"  , "if_host", e_inf);
		uvm_config_db#(virtual if_response)::set(null, "*" , "if_response", r_inf);

		//Registers the Squencers' names in the configuration block
		uvm_config_db#(string)::set(null, "*.agent_host_master.*" , "sqr_name", "sqr_host_master");
		uvm_config_db#(string)::set(null, "*.agent_host_slave.*"  , "sqr_name", "sqr_host_slave");
		uvm_config_db#(string)::set(null, "*.agent_host_test.*"   , "sqr_name", "sqr_host_test");
		uvm_config_db#(string)::set(null, "*.agent_host_extra.*"  , "sqr_name", "sqr_host_extra");

		//Executes the test
		run_test("test");
	end



   //******************************************************************************
   // Properties
   // *****************************************************************************

	property ack_reset; 
		@(posedge clk) disable iff (!rst) (r_inf.ack===1 |-> @(negedge clk) (r_inf.addr===0 && r_inf.rd===0 && r_inf.wr===0 && r_inf.be===0 && r_inf.dwr===0));
	endproperty

	property empty; 
		@(posedge clk) disable iff (!rst) ((r_inf.rd ===0 && r_inf.wr ===0) |-> r_inf.ack ===0);
	endproperty

	property rd_wr; 
		@(posedge clk) disable iff (!rst) (!(r_inf.rd ===1 && r_inf.wr ===1));
	endproperty

	property cpus; 
		@(posedge clk) disable iff (!rst) (m_inf.cpu + s_inf.cpu + t_inf.cpu + e_inf.cpu === 1);
	endproperty

	property acks; 
		@(posedge clk) disable iff (!rst) (m_inf.ack[0] + s_inf.ack[0] + t_inf.ack[0] + e_inf.ack[0] <= 1);
	endproperty

	property mack; 
		@(negedge clk) disable iff (!rst) ($rose(m_inf.ack) |=> $fell(m_inf.ack));
	endproperty

	property sack; 
		@(negedge clk) disable iff (!rst) ($rose(s_inf.ack) |=> $fell(s_inf.ack));
	endproperty

	property tack; 
		@(negedge clk) disable iff (!rst) ($rose(t_inf.ack) |=> $fell(t_inf.ack));
	endproperty

	property eack; 
		@(negedge clk) disable iff (!rst) ($rose(e_inf.ack) |=> $fell(e_inf.ack));
	endproperty

	property consistency; 
		@(posedge clk) disable iff (!rst) ((r_inf.rd ===1 || r_inf.wr===1) |=> (r_inf.rd ===0 && r_inf.wr===0) ||($stable(r_inf.addr) && $stable(r_inf.rd) && $stable(r_inf.wr) && $stable(r_inf.be) && $stable(r_inf.dwr)));
	endproperty

   //******************************************************************************
   // Asserts
   // *****************************************************************************

	ACK_RESET: assert property (ack_reset)
		else `uvm_error("ASRT ack_reset", $sformatf("failed at %0d", $time))

	EMPTY: assert property (empty)
		else `uvm_error("ASRT disable", $sformatf("failed at %0d", $time))

	RD_WR: assert property (rd_wr)
		else `uvm_error("ASRT rd_wr", $sformatf("failed at %0d", $time))

	CPUS: assert property (cpus)
		else `uvm_error("ASRT cpus", $sformatf("failed at %0d", $time))

	ACKS: assert property (acks)
		else `uvm_error("ASRT acks", $sformatf("failed at %0d", $time))

	MACK: assert property (mack)
		else `uvm_error("ASRT mack", $sformatf("failed at %0d", $time))

	SACK: assert property (sack)
		else `uvm_error("ASRT sack", $sformatf("failed at %0d", $time))

	TACK: assert property (tack)
		else `uvm_error("ASRT tack", $sformatf("failed at %0d", $time))

	EACK: assert property (eack)
		else `uvm_error("ASRT eack", $sformatf("failed at %0d", $time))
	
	CONSISTENCY: assert property (consistency)
		else `uvm_error("ASRT consistency", $sformatf("failed at %0d", $time))

endmodule
