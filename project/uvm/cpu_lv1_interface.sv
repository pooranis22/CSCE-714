//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
// Designers: Venky & Suru
//=====================================================================


interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg    ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

//Assertions
//ASSERTION1: cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

//TODO: Add assertions at this interface
//ASSERTION2: no_cpu_wr_done_without_previous_posedge_cpu_wr
    property data_in_bus_cpu_lv1_deassert_one_cycle_after_cpu_rd_deassert;
        @(posedge clk)
          $fell(cpu_rd) |-> ##1 $fell(data_in_bus_cpu_lv1);
    endproperty

    assert_data_in_bus_cpu_lv1_deassert_one_cycle_after_cpu_rd_deassert: assert property (data_in_bus_cpu_lv1_deassert_one_cycle_after_cpu_rd_deassert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_cpu_lv1_deassert_one_cycle_after_cpu_rd_deassert Failed: data_in_bus_cpu_lv1 did not deassert one cycle after cpu_rd deassert"))

//ASSERTION3: cpu_wr_done deassert 1 clock cycle after cpu_wr deassert
    property cpu_wr_done_deassert_one_cycle_after_cpu_wr_deassert;
        @(posedge clk)
           $fell(cpu_wr) |-> ##1 $fell(cpu_wr_done);
    endproperty

    assert_cpu_wr_done_deassert_one_cycle_after_cpu_wr_deassert: assert property (cpu_wr_done_deassert_one_cycle_after_cpu_wr_deassert)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done_deassert_one_cycle_after_cpu_wr_deassert Failed: cpu_wr_done did not deassert one cycle after cpu_wr_deassert"))

//ASSERTION4: cpu_rd and addr_bus_cpu_lv1 are asserted simultaneously
    property prop_simult_cpu_rd_addr;
        @(posedge clk)
            (cpu_rd) |-> |addr_bus_cpu_lv1;
    endproperty

    assert_prop_simult_cpu_rd_addr: assert property (prop_simult_cpu_rd_addr)
    else
        `uvm_error("cpu_lv1_interface", $sformatf("Assertion assert_prop_simult_cpu_rd_addr Failed: cpu_rd and addr_bus_cpu_lv1 are not asserted simultaneously"))

//ASSERTION5: cpu_wr does have a corresponding address
    property prop_cpu_wr_addr;
        @(posedge clk)
            (cpu_wr) |-> |addr_bus_cpu_lv1;
    endproperty

    assert_prop_cpu_wr_addr: assert property (prop_cpu_wr_addr)
    else
        `uvm_error("cpu_lv1_interface", $sformatf("Assertion assert_prop_cpu_wr_addr Failed: cpu_wr does not have a corresponding address"))
    

endinterface
