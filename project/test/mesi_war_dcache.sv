//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_war_dcache.sv
// Description: Test for MESI write after read (E -> M) and (S -> M) to D-cache
// Modifiers: Quy
//=====================================================================

class mesi_war_dcache extends base_test;

    //component macro
    `uvm_component_utils(mesi_war_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_war_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_war_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_war_dcache


// Sequence for a read-miss on I-cache
class mesi_war_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_war_dcache_seq)

    cpu_transaction_c trans;
    rand bit [`ADDR_WID_LV1:0] saved_address;
    randc int rand_cpu;
    rand bit [`DATA_WID_LV1:0] rand_data;

    //constructor
    function new (string name="mesi_war_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
            // Populate all cache with the same address
            saved_address = $urandom_range(32'h4000_0000, 32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == saved_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == saved_address;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == saved_address;})
            
            // Write a new data into the the same address in 1 cpu
            rand_cpu = $urandom_range(0,3);
            rand_data = $urandom_range(32'h0000_0000, 32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == saved_address;})
            
            #1000;
        // end
    endtask

endclass : mesi_war_dcache_seq
