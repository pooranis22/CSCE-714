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
//ASSERTION3: no bus_lv1_lv2_gnt_snoop without bus_lv1_lv2_req_snoop in past cycle
    property no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop_in_past;
        @(posedge clk)
            (bus_lv1_lv2_req_snoop) |-> ##[1:$] (bus_lv1_lv2_gnt_snoop);
    endproperty

    assert_no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop_in_past: assert property (no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop_in_past)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_lv1_lv2_gnt_snoop_without_bus_lv1_lv2_req_snoop_in_past Failed: no_bus_lv1_lv2_gnt_snoop without bus_lv1_lv2_req_snoop"))

//ASSERTION4: bus_lv1_lv2_req_snoop and bus_lv1_lv2_gnt_snoop deassert at the same time
    property bus_lv1_lv2_req_snoop_and_bus_lv1_lv2_gnt_snoop_deassert_simult;
        @(posedge clk)
          ($rose(bus_lv1_lv2_req_snoop) ##1 $rose(bus_lv1_lv2_gnt_snoop)) |-> ##[1:100] ($fell(|bus_lv1_lv2_req_snoop) && $fell(|bus_lv1_lv2_gnt_snoop));
    endproperty

    assert_bus_lv1_lv2_req_snoop_and_bus_lv1_lv2_gnt_snoop_deassert_simult: assert property (bus_lv1_lv2_req_snoop_and_bus_lv1_lv2_gnt_snoop_deassert_simult)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_snoop_and_bus_lv1_lv2_gnt_snoop_deassert_simult Failed: bus_lv1_lv2_req_snoop and bus_lv1_lv2_gnt_snoop deassert simultaneously"))

//ASSERTION5: no bus_lv1_lv2_gnt_proc without bus_lv1_lv2_req_proc
    property no_bus_lv1_lv2_gnt_proc_without_bus_lv1_lv2_req_proc_in_past;
        @(posedge clk)
            (bus_lv1_lv2_req_proc) |-> ##[1:$] (bus_lv1_lv2_gnt_proc);
    endproperty

    assert_no_bus_lv1_lv2_gnt_proc_without_bus_lv1_lv2_req_proc_in_past: assert property (no_bus_lv1_lv2_gnt_proc_without_bus_lv1_lv2_req_proc_in_past)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_lv1_lv2_gnt_proc_without_bus_lv1_lv2_req_proc_in_past Failed: no_bus_lv1_lv2_gnt_snoop without bus_lv1_lv2_req_snoop"))
        
//ASSERTION6: bus_lv1_lv2_req_proc and bus_lv1_lv2_gnt_proc deassert at the same time
    property bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult;
        @(posedge clk)
          ($rose(bus_lv1_lv2_req_proc) ##1 $rose(bus_lv1_lv2_gnt_proc)) |-> ##[1:100] ($fell(|bus_lv1_lv2_req_proc) && $fell(|bus_lv1_lv2_gnt_proc));
    endproperty

    assert_bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult: assert property (bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_bus_lv1_lv2_req_proc_and_bus_lv1_lv2_gnt_proc_deassert_simult Failed: bus_lv1_lv2_req_proc and bus_lv1_lv2_gnt_proc deassert simultaneously"))

//ASSERTION7: no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past
    property no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past;
        @(posedge clk)
            bus_lv1_lv2_req_lv2 |-> ##[1:$] bus_lv1_lv2_gnt_lv2;
    endproperty

    assert_no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past: assert property (no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past Failed: no_bus_lv1_lv2_gnt_lv2_without_bus_lv1_lv2_req_lv2_in_past"))

//ASSERTION8: no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul
    property no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul;
        @(posedge clk)
            (bus_lv1_lv2_req_lv2 && bus_lv1_lv2_gnt_lv2) |-> ##[1:100] (!bus_lv1_lv2_req_lv2 && !bus_lv1_lv2_gnt_lv2);
    endproperty

    assert_no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul: assert property (no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul Failed: no_bus_lv1_lv2_gnt_lv2_and_bus_lv1_lv2_req_lv2_deassert_simul"))

//ASSERTION9: no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle
    property no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle;
        @(posedge clk)
            $rose(cp_in_cache) |=> $fell(bus_lv1_lv2_req_lv2);
    endproperty

    assert_no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle: assert property (no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle Failed: no_cp_in_cache_assert_and_bus_lv1_lv2_req_lv2_deassert_next_cycle"))

//ASSERTION10: no_cp_in_cache_with_lv2_wr_and_lv2_rd_high
    property no_cp_in_cache_with_lv2_wr_and_lv2_rd_high;
        @(posedge clk)
            (lv2_wr && lv2_rd) |=> (cp_in_cache);
    endproperty

    assert_no_cp_in_cache_with_lv2_wr_and_lv2_rd_high: assert property (no_cp_in_cache_with_lv2_wr_and_lv2_rd_high)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_cp_in_cache_with_lv2_wr_and_lv2_rd_high Failed: no_cp_in_cache_with_lv2_wr_and_lv2_rd_high"))

//ASSERTION11: no_lv2_rd_assert_without_bus_rd_or_bus_rdx
    property no_lv2_rd_assert_without_bus_rd_or_bus_rdx;
        @(posedge clk)
            (lv2_rd && (addr_bus_lv1_lv2 >= 32'h4000_0000)) |-> (bus_rd || bus_rdx);
    endproperty

    assert_no_lv2_rd_assert_without_bus_rd_or_bus_rdx: assert property (no_lv2_rd_assert_without_bus_rd_or_bus_rdx)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_lv2_rd_assert_without_bus_rd_or_bus_rdx Failed: no_lv2_rd_assert_without_bus_rd_or_bus_rdx"))

//ASSERTION12: no_bus_rd_and_bus_rdx_not_together
    property no_bus_rd_and_bus_rdx_not_together;
        @(posedge clk)
            not(bus_rd && bus_rdx);
    endproperty

    assert_no_bus_rd_and_bus_rdx_not_together: assert property (no_bus_rd_and_bus_rdx_not_together)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_bus_rd_and_bus_rdx_not_together Failed: no_bus_rd_and_bus_rdx_not_together"))

//ASSERTION13: no_invalidate_without_bus_lv1_lv2_gnt_proc
    property no_invalidate_without_bus_lv1_lv2_gnt_proc;
        @(posedge clk)
            (invalidate ##1 all_invalidation_done) |-> $past(bus_lv1_lv2_gnt_proc);
    endproperty

    assert_no_invalidate_without_bus_lv1_lv2_gnt_proc: assert property (no_invalidate_without_bus_lv1_lv2_gnt_proc)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_invalidate_without_bus_lv1_lv2_gnt_proc Failed: no_invalidate_without_bus_lv1_lv2_gnt_proc"))

//ASSERTION14: invalidate_invalidation_done_all_invalidation_done_deassert_simultaneously
    property invalidate_invalidation_done_all_invalidation_done_deassert_simul;
        @(posedge clk)
            $rose(invalidate) |-> ##[1:$] ($fell(invalidate) && $fell(all_invalidation_done));
    endproperty

    assert_invalidate_invalidation_done_all_invalidation_done_deassert_simul: assert property (invalidate_invalidation_done_all_invalidation_done_deassert_simul)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_invalidate_invalidation_done_all_invalidation_done_deassert_simul Failed: invalidate_invalidation_done_all_invalidation_done_deassert_simul"))

//ASSERTION15: no_addr_in_bus_lv1_lv2_when_invalidation
    property no_addr_in_bus_lv1_lv2_when_invalidation;
        @(posedge clk)
            all_invalidation_done |-> $past(addr_bus_lv1_lv2);
    endproperty

    assert_no_addr_in_bus_lv1_lv2_when_invalidation: assert property (no_addr_in_bus_lv1_lv2_when_invalidation)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_addr_in_bus_lv1_lv2_when_invalidation Failed: no_addr_in_bus_lv1_lv2_when_invalidation"))

//ASSERTION16: bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert
    property bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert;
        @(posedge clk)
            ($rose(data_in_bus_lv1_lv2) && addr_bus_lv1_lv2 >= 32'h4000_0000) |=> (!bus_rd && !bus_rdx);
    endproperty

    assert_bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert: assert property (bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert Failed: bus_rd_and_bus_rdx_low_one_clk_cycle_after_data_in_bus_lv1_lv2_assert"))

//ASSERTION17: shared_and_bus_lv1_lv2_gnt_snoop
    property shared_and_bus_lv1_lv2_gnt_snoop;
        @(posedge clk)
            bus_lv1_lv2_req_snoop |-> ##[1:$] shared;
    endproperty

    assert_shared_and_bus_lv1_lv2_gnt_snoop: assert property (shared_and_bus_lv1_lv2_gnt_snoop)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_shared_and_bus_lv1_lv2_gnt_snoop Failed: shared_and_bus_lv1_lv2_gnt_snoop"))

//ASSERTION18: data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop
    property data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop;
        @(posedge clk)
            $rose(lv2_rd) |-> ##[1:100] ($fell(lv2_rd) ##1 (data_in_bus_lv1_lv2 === 1'bz));
    endproperty

    assert_data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop: assert property (data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop Failed: data_in_bus_lv1_lv2_drop_one_cycle_after_lv2_rd_drop"))

//ASSERTION19: no_lv2_wr_without_data_bus_lv1_lv2
    property no_lv2_wr_without_data_bus_lv1_lv2;
        @(posedge clk)
            $rose(lv2_wr) |-> $changed(data_bus_lv1_lv2);
    endproperty

    assert_no_lv2_wr_without_data_bus_lv1_lv2: assert property (no_lv2_wr_without_data_bus_lv1_lv2)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_no_lv2_wr_without_data_bus_lv1_lv2 Failed: assert_no_lv2_wr_without_data_bus_lv1_lv2"))

//ASSERTION20: lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert
    property lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert;
        @(posedge clk)
            !lv2_wr |-> ##1 !lv2_wr_done;
    endproperty

    assert_lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert: assert property (lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert Failed: lv2_wr_done_deassert_one_clock_cycle_after_lv2_wr_deassert"))



endinterface