//=====================================================================
// Project: 4 core MESI cache design
// File Name: cont_rw_same_addr.sv
// Description: Test for simple (write miss + free block) and (write + no free block) to D-cache
// Modifiers: Quy Van
//=====================================================================

class cont_rw_same_addr extends base_test;

    //component macro
    `uvm_component_utils(cont_rw_same_addr)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", cont_rw_same_addr_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing cont_rw_same_addr test" , UVM_LOW)
    endtask: run_phase

endclass : cont_rw_same_addr


// Sequence for a read-miss on I-cache
class cont_rw_same_addr_seq extends base_vseq;
    //object macro
    `uvm_object_utils(cont_rw_same_addr_seq)

    cpu_transaction_c trans;
    bit [`DATA_WID_LV1-1:0] rand_data;

    //constructor
    function new (string name="cont_rw_same_addr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        // Continuously write with 4 addresses in the same set to cpu0
        repeat(10)begin
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4000_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4001_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4002_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4003_0000; data == rand_data;})
        end
        
        // Continously write fifth address in the same set to cpu0
        repeat(10)begin
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == 32'h4004_0000; data == rand_data;})
        end

        // Continuously read with 4 addresses in the same set to cpu0
        repeat(10)begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4005_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4006_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4007_0000; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4008_0000; data == rand_data;})
        end

        // Continously read fifth address in the same set to cpu0
        repeat(10)begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == 32'h4009_0000; data == rand_data;})
        end

    endtask

endclass : cont_rw_same_addr_seq
