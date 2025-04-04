`ifndef ETH_MAC_BASE_TEST
`define ETH_MAC_BASE_TEST

`include "uvm_macros.svh"  // Import UVM macros
import uvm_pkg::*;         // Import all UVM classes

//Module includes
`include "eth_mac_env.sv"
`include "eth_mac_tx_agent.sv"
`include "eth_mac_virtual_seqr.sv"
`include "eth_mac_tx_seq.sv"
`include "eth_mac_rx_seq.sv"
`include "eth_mac_tx_seqr.sv"
`include "eth_mac_scb.sv"
`include "eth_mac_cfg.sv"


class eth_mac_base_test extends uvm_test;
    `uvm_component_utils(eth_mac_base_test)

    eth_mac_env env;
    eth_mac_cfg cfg;

    function new(string name = "eth_mac_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);     

        //Build the eth mac env
        env = eth_mac_env::type_id::create("eth_mac_env", this);  

        // Instantiate cfg only in the base test
        cfg = eth_mac_cfg::type_id::create("cfg"); 

        // Store cfg in the config database so environment can access it
        uvm_config_db#(eth_mac_cfg)::set(this, "eth_mac_env", "cfg", cfg);                
    endfunction : build_phase

    virtual function void report_phase(uvm_phase phase);
        //Instance of uvm report server
        uvm_report_server   server;
        //Variable to track number of errors
        int err_num;
        string link_speed_str;
        super.report_phase(phase);
        
        server = get_report_server();
        err_num = server.get_severity_count(UVM_ERROR);

        case(cfg.link_speed)
            2'b00: link_speed_str = "GBIT_SPEED";
            2'b01: link_speed_str = "MB_100_SPEED";
            2'b10: link_speed_str = "MB_10_SPEED";
            default: link_speed_str = "UNKNOWN";
        endcase        
        
        if (err_num == 0) begin
           `uvm_info("base_test", "//////////////////////////////////////////////////////////////", UVM_MEDIUM)
           `uvm_info("base_test", $sformatf("TEST WITH LINK SPEED: %s", link_speed_str), UVM_MEDIUM)
           `uvm_info("base_test", "TESTCASE PASSED", UVM_MEDIUM)
           `uvm_info("base_test", "//////////////////////////////////////////////////////////////", UVM_MEDIUM)
        end else begin
           `uvm_info("base_test", "//////////////////////////////////////////////////////////////", UVM_MEDIUM)
           `uvm_info("base_test", $sformatf("TEST WITH LINK SPEED: %s", link_speed_str), UVM_MEDIUM)
           `uvm_info("base_test", "TESTCASE FAILED", UVM_MEDIUM)
           `uvm_info("base_test", "//////////////////////////////////////////////////////////////", UVM_MEDIUM)
        end
        
    endfunction : report_phase

endclass : eth_mac_base_test

`endif //ETH_MAC_BASE_TEST