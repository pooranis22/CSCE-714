//=====================================================================
// Project: 4 core MESI cache design
// File Name: randomized_icache.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class randomized_icache extends base_test;

    //component macro
    `uvm_component_utils(randomized_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", randomized_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing randomized_icache test" , UVM_LOW)
    endtask: run_phase

endclass : randomized_icache


// Sequence for a read-miss on I-cache
class randomized_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(randomized_icache_seq)

    cpu_transaction_c trans;
    
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[10];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu, rand_addr_index;

    //constructor
    function new (string name="randomized_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

    repeat(20)begin  

        rand_set = $urandom(); 
        for(int i = 0; i < 10; i++)begin // addresses in the same set
            rand_addr[i] = $urandom_range(32'h0000_0000, (32'h4000_0000 - 1'b1));
            rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
            `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
        end

        repeat(50)begin
            rand_cpu = $urandom_range(0,3);
            rand_addr_index = $urandom_range(0,9);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
            rand_addr_index = $urandom_range(0,4);
            rand_data = $urandom_range(32'h0000_0000, 32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index];})
        end
    end

    #500;
    
    endtask

endclass : randomized_icache_seq
