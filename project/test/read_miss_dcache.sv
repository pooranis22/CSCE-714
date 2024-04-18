//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_rar_dcache.sv
// Description: Test for (read-miss + free block) and (read-miss + no free block) to D-cache
// Modifiers: Quy
//=====================================================================

class mesi_rar_dcache extends base_test;

    //component macro
    `uvm_component_utils(mesi_rar_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_rar_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_rar_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_rar_dcache


// Sequence for a read-miss on I-cache
class mesi_rar_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_rar_dcache_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1:0] set_addr[5];
    rand bit [`DATA_WID_LV1:0] rand_data;
    //constructor
    function new (string name="mesi_rar_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        //Read miss + free block in the same address for all cpu
        set_addr = '{32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000};
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        
        // Fill up cache cpu 0
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2]; data == rand_data;})
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[3]; data == rand_data;})

        //Read miss + no free block in same set address in cpu0
        rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[4]; data == rand_data;})

        #1000;
    endtask

endclass : mesi_rar_dcache_seq
