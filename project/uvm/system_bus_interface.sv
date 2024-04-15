//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
// Designers: Venky & Suru
//=====================================================================

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
    parameter NO_OF_CORE            = 4;

    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NO_OF_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions
//property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

//ASSERTION1: lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))

//ASSERTION2: data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    property no_data_in_bus_lv1_lv2_and_cp_in_cache_without_previous_lv2_rd;
        @(posedge clk)
          (data_in_bus_lv1_lv2 && cp_in_cache) |-> ($past(lv2_rd));
    endproperty

    assert_no_data_in_bus_lv1_lv2_and_cp_in_cache_without_previous_lv2_rd: assert property (no_data_in_bus_lv1_lv2_and_cp_in_cache_without_previous_lv2_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_data_in_bus_lv1_lv2_and_cp_in_cache_without_previous_lv2_rd Failed: no_data_in_bus_lv1_lv2_and_cp_in_cache_without_previous_lv2_rd"))


//TODO: Add assertions at this interface
//There are atleast 20 such assertions. Add as many as you can!!
//ASSERTION3: no bus_lv1_lv2_gnt_snoop without bus_lv1_lv2_req_snoop
    property no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop;
        @(posedge clk)
            (bus_lv1_lv2_gnt_snoop) |-> (bus_lv1_lv2_req_snoop);
    endproperty

    assert_no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop: assert property (no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop Failed: no_bus_lv1_lv2_gnt_snoop without bus_lv1_lv2_req_snoop"))

//ASSERTION4: bus_lv1_lv2_req_proc and bus_lv1_lv2_gnt_proc deassert at the same time
    property bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult;
        @(posedge clk)
          $fell(bus_lv1_lv2_gnt_proc) |-> $fell(bus_lv1_lv2_req_proc);
    endproperty

    assert_bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult: assert property (bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult Failed: bus_lv1_lv2_req_proc and bus_lv1_lv2_gnt_proc deassert simultaneously"))

//ASSERTION5: invalidate_and_share cannot assert simult
    property invalidate_and_share_cannot_assert_simult;
        @(posedge clk)
          not(invalidate && shared);
    endproperty

    assert_invalidate_and_share_cannot_assert_simult: assert property (invalidate_and_share_cannot_assert_simult)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_invalidate_and_share_cannot_assert_simult Failed: invalidate and share cannot assert simultaneously"))



endinterface
