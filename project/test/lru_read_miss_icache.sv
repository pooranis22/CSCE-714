//=====================================================================
// Project: 4 core MESI cache design
// File Name: lru_read_miss_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class lru_read_miss_icache extends base_test;

    //component macro
    `uvm_component_utils(lru_read_miss_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lru_read_miss_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lru_read_miss_icache test" , UVM_LOW)
    endtask: run_phase

endclass : lru_read_miss_icache


// Sequence for a read-miss on I-cache
class lru_read_miss_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lru_read_miss_icache_seq)

    cpu_transaction_c trans;
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[16];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu;
    rand int rand_addr_index;

    //constructor
    function new (string name="lru_read_miss_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        repeat(10)begin  

            // Read LRU
            rand_set = $urandom(); 
            for(int i = 0; i < 16; i++)begin // addresses in the same set
                rand_addr[i] = $urandom_range(32'h0000_0000, (32'h4000_0000 - 1'b1));
                rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
                `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
            end

            rand_cpu = $urandom_range(0,3);
            
            repeat(30)begin

                rand_addr_index = $urandom_range(0,3);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
            
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                rand_addr_index = $urandom_range(4,7);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
            
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                rand_addr_index = $urandom_range(8,11);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
            
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                rand_addr_index = $urandom_range(12,15);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})

                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
            
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+3)%4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
                
            end

        end

        #500;

    endtask

endclass : lru_read_miss_icache_seq
