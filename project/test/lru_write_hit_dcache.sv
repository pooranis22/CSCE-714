//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_write_hit_dcache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class lru_write_hit_dcache extends base_test;

    //component macro
    `uvm_component_utils(lru_write_hit_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_write_hit_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_write_hit_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : lru_write_hit_dcache


// Sequence for a read-miss on I-cache
class lru_write_hit_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_write_hit_dcache_seq)

    cpu_transaction_c trans;
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[4];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu;
    rand int rand_addr_index;

    //constructor
    function new (string name="lru_write_hit_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        repeat(10)begin  

            // Read LRU
            rand_set = $urandom(); 
            for(int i = 0; i < 4; i++)begin // addresses in the same set
                rand_addr[i] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
                rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
                `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
            end

            repeat(30)begin
                rand_cpu = $urandom_range(0,3);
                rand_addr_index = $urandom_range(0,3);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})

                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
            
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index];})
            end

        end

        #500;

    endtask

endclass : lru_write_hit_dcache_seq
