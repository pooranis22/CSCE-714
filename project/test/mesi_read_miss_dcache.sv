//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_dcache.sv
// Description: Test for read miss with MESI to D-cache
// Modifiers: Quy Van
//=====================================================================

class mesi_read_miss_dcache extends base_test;

    //component macro
    `uvm_component_utils(mesi_read_miss_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_read_miss_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_read_miss_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_read_miss_dcache


// Sequence for a read-miss on I-cache
class mesi_read_miss_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_read_miss_dcache_seq)

    cpu_transaction_c trans;
    bit [`ADDR_WID_LV1-1:0] set_addr[5];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    int rand_addr;
    //constructor
    function new (string name="mesi_read_miss_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        // addresses in the same set
        set_addr = '{32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000};
        
    // Read Miss + free block
        // Read miss -> free block -> no copy = Invalid
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        // Read miss -> free block -> the copy is in Exclusive  
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        // Read miss -> free block -> the copy is in Shared
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        // Read miss -> free block -> the copy is in Shared
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})

            // Write cpu0 -> Modified state, other block is invalidated
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0]; data == rand_data;})

        // Read Miss -> free block -> the copy is in Modified
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
        
    // Read Miss + no free block
            // Fill up cpu0 with addresses in the same set
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[4];})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})

        // Read Miss + no free block + the replacement is in Exclusive State 
            // evict set_addr[4] (E state) for set_addr[3]
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[3];})

            // Evicted set_addr[0] with write
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1]; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2]; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[3]; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[4]; data == rand_data;})


        // Read Miss + no free block + the replacement is in Modified state (set_addr[1])
            // Evict set_addr[1] (M state) for set_addr[0]
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[0];})            

        // Read Miss + no free block + the replacement is in Shared State 
            // Turn set_addr[2] in shared state in cpu1
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[2];})
            // Evict set_addr[2] (S state) in cpu0 for set_addr[1]
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[1];})

        #1000;
    endtask

endclass : mesi_read_miss_dcache_seq
