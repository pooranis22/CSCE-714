//=====================================================================
// Project: 4 core MESI cache design
// File Name: parallel_icache.sv
// Description: Test for read-miss to I-cache
// Designers: Venky & Suru
//=====================================================================

class parallel_icache extends base_test;

    //component macro
    `uvm_component_utils(parallel_icache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", parallel_icache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing parallel_icache test" , UVM_LOW)
    endtask: run_phase

endclass : parallel_icache


// Sequence for a read-miss on I-cache
class parallel_icache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(parallel_icache_seq)

    cpu_transaction_c trans1, trans2, trans3, trans4;
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[16];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu4, rand_cpu1, rand_cpu2, rand_cpu3;
    rand int rand_addr_index4, rand_addr_index1, rand_addr_index2, rand_addr_index3;
    rand int rand_op1, rand_op2, rand_op3, rand_op4;

    //constructor
    function new (string name="parallel_icache_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        repeat(20)begin  

            // Read LRU
            rand_set = $urandom(); 
            for(int i = 0; i < 16; i++)begin // addresses in the same set
                rand_addr[i] = $urandom_range(32'h0000_0000, (32'h4000_0000 - 1'b1));
                rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
                `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
            end

            
            
            repeat(40)begin
                begin
                    rand_cpu1 = $urandom_range(0,3);
                    rand_addr_index1 = $urandom_range(0,15);
                    rand_op1 = $urandom_range(0,1);
                    if(rand_op1 == 0)begin
                        `uvm_do_on_with(trans1, p_sequencer.cpu_seqr[rand_cpu1], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index1];})
                    end 
                    else begin
                        `uvm_do_on_with(trans1, p_sequencer.cpu_seqr[rand_cpu1], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index1];})
                    end
                end

                begin
                    rand_cpu2 = $urandom_range(0,3);
                    rand_addr_index2 = $urandom_range(0,15);
                    rand_op2 = $urandom_range(0,1);
                    if(rand_op2 == 0)begin
                        `uvm_do_on_with(trans2, p_sequencer.cpu_seqr[rand_cpu2], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index2];})
                    end 
                    else begin
                        `uvm_do_on_with(trans2, p_sequencer.cpu_seqr[rand_cpu2], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index2];})
                    end                
                end

                begin
                    rand_cpu3 = $urandom_range(0,3);
                    rand_addr_index3 = $urandom_range(0,15);
                    rand_op3 = $urandom_range(0,1);
                    if(rand_op3 == 0)begin
                        `uvm_do_on_with(trans3, p_sequencer.cpu_seqr[rand_cpu3], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index3];})
                    end 
                    else begin
                        `uvm_do_on_with(trans3, p_sequencer.cpu_seqr[rand_cpu3], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index3];})
                    end                
                end

                begin
                    rand_cpu4 = $urandom_range(0,3);
                    rand_addr_index4 = $urandom_range(0,15);
                    rand_op4 = $urandom_range(0,1);
                    if(rand_op4 == 0)begin
                        `uvm_do_on_with(trans4, p_sequencer.cpu_seqr[rand_cpu4], {request_type == READ_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index4];})
                    end 
                    else begin
                        `uvm_do_on_with(trans4, p_sequencer.cpu_seqr[rand_cpu4], {request_type == WRITE_REQ; access_cache_type == ICACHE_ACC; address == rand_addr[rand_addr_index4];})
                    end                
                end
            end

        end

        #500;

    endtask

endclass : parallel_icache_seq
