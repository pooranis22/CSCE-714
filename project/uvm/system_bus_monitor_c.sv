//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_monitor_c.sv
// Description: system bus monitor component
// Designers: Venky & Suru
//=====================================================================

`include "sbus_packet_c.sv"

class system_bus_monitor_c extends uvm_monitor;
    //component macro
    `uvm_component_utils(system_bus_monitor_c)

    uvm_analysis_port #(sbus_packet_c) sbus_out;
    sbus_packet_c       s_packet;

    //Covergroup to monitor all the points within sbus_packet
    covergroup cover_sbus_packet;
        option.per_instance = 1;
        option.name = "cover_system_bus";
        REQUEST_TYPE: coverpoint  s_packet.bus_req_type;
        REQUEST_PROCESSOR: coverpoint s_packet.bus_req_proc_num;
        REQUEST_ADDRESS: coverpoint s_packet.req_address{
            option.auto_bin_max = 20;
        }
        READ_DATA: coverpoint s_packet.rd_data{
            option.auto_bin_max = 20;
        }
        //TODO: Add coverage for other fields of sbus_mon_packet
        BUS_REQ_SNOOP: coverpoint s_packet.bus_req_snoop{
            illegal_bins illegal_req_type = {4'b1111};
        }
        REQ_SERVICED_BY: coverpoint s_packet.req_serviced_by;
        WR_DATA_SNOOP: coverpoint s_packet.wr_data_snoop{
            option.auto_bin_max = 20;
        }
        SNOOP_WR_REQ_FLAG: coverpoint s_packet.snoop_wr_req_flag;
        CP_IN_CACHE: coverpoint s_packet.cp_in_cache;
        SHARED: coverpoint s_packet.shared;
        SERVICE_TIME: coverpoint s_packet.service_time;
        PROC_EVICT_DIRTY_BLK_ADDR: coverpoint s_packet.proc_evict_dirty_blk_addr;
        PROC_EVICT_DIRTY_BLK_DATA: coverpoint s_packet.proc_evict_dirty_blk_data;
        PROC_EVICT_DIRTY_BLK_FLAG: coverpoint s_packet.proc_evict_dirty_blk_flag;
        //cross coverage
        //ensure each processor has read miss, write miss, invalidate, etc.
        X_PROC__REQ_TYPE: cross REQUEST_TYPE, REQUEST_PROCESSOR;
        X_PROC__ADDRESS: cross REQUEST_PROCESSOR, REQUEST_ADDRESS;
        X_PROC__DATA: cross REQUEST_PROCESSOR, READ_DATA;
        //TODO: Add relevant cross coverage (examples shown above)
        X_PROC__CP_IN_CACHE: cross REQUEST_PROCESSOR, CP_IN_CACHE;
        X_REQUEST_PROCESSOR__REQUEST_SERV_BY: cross REQUEST_PROCESSOR, REQ_SERVICED_BY;
        X_REQUEST_PROCESSOR__REQUEST_SNOOP: cross REQUEST_PROCESSOR, BUS_REQ_SNOOP;
        X_REQUEST_PROCESSOR__CP_IN_CACHE: cross REQUEST_PROCESSOR, CP_IN_CACHE; 
    endgroup

    // Virtual interface of used to observe system bus interface signals
    virtual interface system_bus_interface vi_sbus_if;

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        sbus_out = new("sbus_out", this);
        this.cover_sbus_packet = new();
    endfunction : new

    //UVM build phase ()
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // throw error if virtual interface is not set
        if (!uvm_config_db#(virtual system_bus_interface)::get(this, "","v_sbus_if", vi_sbus_if))
            `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vi_sbus_if"})
    endfunction: build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "RUN Phase", UVM_LOW)
        // s_packet.service_time = 0;
        forever begin
        //TODO: Code for the system bus monitor is minimal!
        //Add code to observe other cases
        //Add code for dirty block eviction
        //Snoop requests, service time, etc
            // trigger point for creating the packet
            @(posedge (|vi_sbus_if.bus_lv1_lv2_gnt_proc));
            `uvm_info(get_type_name(), "Packet creation triggered", UVM_LOW)
            s_packet = sbus_packet_c::type_id::create("s_packet", this);

            // wait for assertion of either bus_rd, bus_rdx or invalidate before monitoring other bus activities
            // lv2_rd for I-cache cases
            @(posedge(vi_sbus_if.bus_rd | vi_sbus_if.bus_rdx | vi_sbus_if.invalidate | vi_sbus_if.lv2_rd | vi_sbus_if.lv2_wr));


            fork
                begin: cp_in_cache_check
                    // check for cp_in_cache assertion
                    @(posedge vi_sbus_if.cp_in_cache) s_packet.cp_in_cache = 1;
                end : cp_in_cache_check
                begin: shared_check
                    // check for shared signal assertion when data_in_bus_lv1_lv2 is also high
                    wait(vi_sbus_if.shared & vi_sbus_if.data_in_bus_lv1_lv2) s_packet.shared = 1;
                end : shared_check
            join_none

            if(vi_sbus_if.lv2_wr)
            begin
                s_packet.proc_evict_dirty_blk_addr = vi_sbus_if.addr_bus_lv1_lv2;
                s_packet.proc_evict_dirty_blk_data = vi_sbus_if.data_bus_lv1_lv2;
                s_packet.proc_evict_dirty_blk_flag = 1;
                @(posedge (vi_sbus_if.bus_rd | vi_sbus_if.bus_rdx | vi_sbus_if.invalidate | vi_sbus_if.lv2_rd));
            end

            // bus request type
            if (vi_sbus_if.bus_rd === 1'b1)
                s_packet.bus_req_type = BUS_RD;
            else if (vi_sbus_if.bus_rdx === 1'b1)
                s_packet.bus_req_type = BUS_RDX;
            else if (vi_sbus_if.invalidate === 1'b1)
                s_packet.bus_req_type = INVALIDATE;
            else if (vi_sbus_if.lv2_rd === 1'b1)
                s_packet.bus_req_type = ICACHE_RD;



            // proc which requested the bus access
            case (1'b1)
                vi_sbus_if.bus_lv1_lv2_gnt_proc[0]: s_packet.bus_req_proc_num = REQ_PROC0;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[1]: s_packet.bus_req_proc_num = REQ_PROC1;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[2]: s_packet.bus_req_proc_num = REQ_PROC2;
                vi_sbus_if.bus_lv1_lv2_gnt_proc[3]: s_packet.bus_req_proc_num = REQ_PROC3;
            endcase

            // address requested
            s_packet.req_address = vi_sbus_if.addr_bus_lv1_lv2;

            // fork and call tasks
            fork: update_info

                // to determine which of snoops or L2 serviced read miss
                begin: req_service_check
                    if (s_packet.bus_req_type == BUS_RD)
                    begin
                        @(posedge vi_sbus_if.data_in_bus_lv1_lv2);
                        `uvm_info(get_type_name(), "Bus read successful", UVM_LOW)
                        s_packet.rd_data = vi_sbus_if.data_bus_lv1_lv2;
                        // check which had grant asserted
                        case (1'b1)
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[0]: s_packet.req_serviced_by = SERV_SNOOP0;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[1]: s_packet.req_serviced_by = SERV_SNOOP1;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[2]: s_packet.req_serviced_by = SERV_SNOOP2;
                            vi_sbus_if.bus_lv1_lv2_gnt_snoop[3]: s_packet.req_serviced_by = SERV_SNOOP3;
                            vi_sbus_if.bus_lv1_lv2_gnt_lv2     : s_packet.req_serviced_by = SERV_L2;
                        endcase
                    end
                    // L2 serviced read miss
                    else if (s_packet.bus_req_type == BUS_RDX)
                    begin
                        @(posedge vi_sbus_if.data_in_bus_lv1_lv2);
                        `uvm_info(get_type_name(), "Bus readx successful", UVM_LOW)
                        s_packet.rd_data = vi_sbus_if.data_bus_lv1_lv2;
                        // check which had grant asserted
                        case (1'b1)
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[0]: s_packet.req_serviced_by = SERV_SNOOP0;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[1]: s_packet.req_serviced_by = SERV_SNOOP1;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[2]: s_packet.req_serviced_by = SERV_SNOOP2;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[3]: s_packet.req_serviced_by = SERV_SNOOP3;
                            vi_sbus_if.bus_lv1_lv2_gnt_lv2     : s_packet.req_serviced_by = SERV_L2;
                            default;
                        endcase
                    end
                    // lv2_rd for I-cache cases
                    else if (s_packet.bus_req_type == ICACHE_RD)
                    begin
                        @(posedge vi_sbus_if.data_in_bus_lv1_lv2);
                        `uvm_info(get_type_name(), "ICACHE_RD successful", UVM_LOW)
                        s_packet.rd_data = vi_sbus_if.data_bus_lv1_lv2;
                        // check which had grant asserted
                        case (1'b1)
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[0]: s_packet.req_serviced_by = SERV_SNOOP0;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[1]: s_packet.req_serviced_by = SERV_SNOOP1;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[2]: s_packet.req_serviced_by = SERV_SNOOP2;
                        //     vi_sbus_if.bus_lv1_lv2_gnt_snoop[3]: s_packet.req_serviced_by = SERV_SNOOP3;
                            vi_sbus_if.bus_lv1_lv2_gnt_lv2     : s_packet.req_serviced_by = SERV_L2;
                            default;
                        endcase
                    end
                    // Check invalidation
                    else if (s_packet.bus_req_type == INVALIDATE)
                    begin
                        @(posedge vi_sbus_if.all_invalidation_done);
                        `uvm_info(get_type_name(), "INVALIDATE successful", UVM_LOW)
                    end
                end: req_service_check

                begin: bus_req_snoop_check
                @(posedge(vi_sbus_if.bus_lv1_lv2_req_snoop[0] | vi_sbus_if.bus_lv1_lv2_req_snoop[1] | vi_sbus_if.bus_lv1_lv2_req_snoop[2] | vi_sbus_if.bus_lv1_lv2_req_snoop[3]))
                case(1'b1)
                    vi_sbus_if.bus_lv1_lv2_req_snoop[0]: s_packet.bus_req_snoop[0] = 1;
                    vi_sbus_if.bus_lv1_lv2_req_snoop[1]: s_packet.bus_req_snoop[1] = 1;
                    vi_sbus_if.bus_lv1_lv2_req_snoop[2]: s_packet.bus_req_snoop[2] = 1;
                    vi_sbus_if.bus_lv1_lv2_req_snoop[3]: s_packet.bus_req_snoop[3] = 1;
                endcase
                end: bus_req_snoop_check

                begin: wr_data_snoop_check
                @(posedge vi_sbus_if.lv2_wr)
                if(vi_sbus_if.bus_lv1_lv2_gnt_snoop[0] || vi_sbus_if.bus_lv1_lv2_gnt_snoop[1] || vi_sbus_if.bus_lv1_lv2_gnt_snoop[2] || vi_sbus_if.bus_lv1_lv2_gnt_snoop[3])
                begin
                    s_packet.wr_data_snoop = vi_sbus_if.data_bus_lv1_lv2;
                    s_packet.snoop_wr_req_flag = 1;
                end
                end: wr_data_snoop_check

            join_none : update_info

            // wait until request is processed and send data
            @(negedge vi_sbus_if.bus_lv1_lv2_req_proc[0] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[1] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[2] or negedge vi_sbus_if.bus_lv1_lv2_req_proc[3]);

            `uvm_info(get_type_name(), "Packet to be written", UVM_LOW)

            // disable all spawned child processes from fork
            disable fork;

            // write into scoreboard after population of the packet fields
            sbus_out.write(s_packet);
            cover_sbus_packet.sample();
            // s_packet.service_time++;
        end
    endtask : run_phase

endclass : system_bus_monitor_c