//=====================================================================
// Project: 4 core MESI cache design
// File Name: randomized_dcache.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class randomized_dcache extends base_test;

    //component macro
    `uvm_component_utils(randomized_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", randomized_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing randomized_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : randomized_dcache


// Sequence for a read-miss on I-cache
class randomized_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(randomized_dcache_seq)

    cpu_transaction_c trans;
    // rand bit [`ADDR_WID_LV1:0] set_addr[15];
    // rand bit [`ADDR_WID_LV1:0] set_addr[10];
    rand bit [`ADDR_WID_LV1:0] set_addr[30];
    rand bit [`DATA_WID_LV1:0] rand_data;
    rand int rand_cpu;
    rand int rand_op;
    rand int rand_addr_index;

    //constructor
    function new (string name="randomized_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        set_addr = {32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000,32'h4005_0000, 32'h4006_0000,32'h4007_0000, 32'h4008_0000, 32'h4009_0000, 
                    32'h4000_0004, 32'h4001_0004, 32'h4002_0004, 32'h4003_0004, 32'h4004_0004,32'h4005_0004, 32'h4006_0004,32'h4007_0004, 32'h4008_0004, 32'h4009_0004, 
                    32'h4000_0008, 32'h4001_0008, 32'h4002_0008, 32'h4003_0008, 32'h4004_0008,32'h4005_0008, 32'h4006_0008,32'h4007_0008, 32'h4008_0008, 32'h4009_0008};

        // set_addr = {32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000, 
        //             32'h4000_0004, 32'h4001_0004, 32'h4002_0004, 32'h4003_0004, 32'h4004_0004};

        // set_addr = {32'h4000_0000, 32'h4001_0000, 32'h4002_0000, 32'h4003_0000, 32'h4004_0000,32'h4005_0000, 32'h4006_0000,32'h4007_0000, 32'h4008_0000, 32'h4009_0000};

        repeat(500)begin
            rand_cpu = $urandom_range(0,3);
            rand_op = $urandom_range(0,1);
            rand_addr_index = $urandom_range(0,29);
            rand_data = $urandom_range(32'h0000_0000, 32'hffff_ffff);
            if(rand_op == 0)begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == set_addr[rand_addr_index];})
            end
            else begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == set_addr[rand_addr_index]; data == rand_data;})
            end
        end

        #1000;
    endtask

endclass : randomized_dcache_seq
