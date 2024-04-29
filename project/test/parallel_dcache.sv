//=====================================================================
// Project: 4 core MESI cache design
// File Name: parallel_dcache.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class parallel_dcache extends base_test;

    //component macro
    `uvm_component_utils(parallel_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", parallel_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing parallel_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : parallel_dcache


// Sequence for a read-miss on I-cache
class parallel_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(parallel_dcache_seq)

    rand bit [`ADDR_WID_LV1-1:0] rand_addr[30];
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    cpu_transaction_c trans1;
    cpu_transaction_c trans2;
    cpu_transaction_c trans3;
    cpu_transaction_c trans4;

    
    rand bit [`DATA_WID_LV1-1:0] rand_data1;   
    rand int rand_cpu1;
    rand int rand_op1;
    rand int rand_addr_index1;

    rand bit [`DATA_WID_LV1-1:0] rand_data2;
    rand int rand_cpu2;
    rand int rand_op2;
    rand int rand_addr_index2;

    rand bit [`DATA_WID_LV1-1:0] rand_data3;
    rand int rand_cpu3;
    rand int rand_op3;
    rand int rand_addr_index3;

    rand bit [`DATA_WID_LV1-1:0] rand_data4;
    rand int rand_cpu4;
    rand int rand_op4;
    rand int rand_addr_index4;

    //constructor
    function new (string name="parallel_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        for(int i = 0; i < 3; i++)begin // addresses in the same set
            rand_set = $urandom();
            for(int j = 0; j < 10; j++)begin
                rand_addr[i*10 + j] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
                rand_addr[i*10 + j][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
                `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i*10 + j]), UVM_LOW)
            end
        end

        repeat(20)begin
            fork
                begin
                    rand_cpu1 = $urandom_range(0,3);
                    rand_op1 = $urandom_range(0,1);
                    rand_addr_index1 = $urandom_range(0,29);
                    `uvm_info("RAND_ADDR_INDEX", $sformatf("RAND_ADDR_INDEX: %0d", rand_addr_index1), UVM_LOW)
                    rand_data1 = $urandom_range(32'h0000_0000, 32'hffff_ffff);
                    if(rand_op1 == 0)begin
                        #1
                        `uvm_do_on_with(trans1, p_sequencer.cpu_seqr[rand_cpu1], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index1];})
                    end
                    else begin
                        #1
                        `uvm_do_on_with(trans1, p_sequencer.cpu_seqr[rand_cpu1], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index1]; data == rand_data1;})
                    end
                end
                begin
                    rand_cpu2 = $urandom_range(0,3);
                    rand_op2 = $urandom_range(0,1);
                    rand_addr_index2 = $urandom_range(0,29);
                    `uvm_info("RAND_ADDR_INDEX", $sformatf("RAND_ADDR_INDEX: %0d", rand_addr_index2), UVM_LOW)
                    rand_data2 = $urandom_range(32'h0000_0000, 32'hffff_ffff);
                    if(rand_op2 == 0)begin
                        #10
                        `uvm_do_on_with(trans2, p_sequencer.cpu_seqr[rand_cpu2], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index2];})
                    end
                    else begin
                        #10
                        `uvm_do_on_with(trans2, p_sequencer.cpu_seqr[rand_cpu2], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index2]; data == rand_data2;})
                    end
                end
                begin
                    rand_cpu3 = $urandom_range(0,3);
                    rand_op3 = $urandom_range(0,1);
                    rand_addr_index3 = $urandom_range(0,29);
                    `uvm_info("RAND_ADDR_INDEX", $sformatf("RAND_ADDR_INDEX: %0d", rand_addr_index3), UVM_LOW)
                    rand_data3 = $urandom_range(32'h0000_0000, 32'hffff_ffff);
                    if(rand_op3 == 0)begin
                        #100
                        `uvm_do_on_with(trans3, p_sequencer.cpu_seqr[rand_cpu3], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index3];})
                    end
                    else begin
                        #100
                        `uvm_do_on_with(trans3, p_sequencer.cpu_seqr[rand_cpu3], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index3]; data == rand_data3;})
                    end
                end
                begin
                    rand_cpu4 = $urandom_range(0,3);
                    rand_op4 = $urandom_range(0,1);
                    rand_addr_index4 = $urandom_range(0,29);
                    `uvm_info("RAND_ADDR_INDEX", $sformatf("RAND_ADDR_INDEX: %0d", rand_addr_index4), UVM_LOW)
                    rand_data4 = $urandom_range(32'h0000_0000, 32'hffff_ffff);
                    if(rand_op4 == 0)begin
                        #1000
                        `uvm_do_on_with(trans4, p_sequencer.cpu_seqr[rand_cpu4], {request_type == READ_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index4];})
                    end
                    else begin
                        #1000
                        `uvm_do_on_with(trans4, p_sequencer.cpu_seqr[rand_cpu4], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address == rand_addr[rand_addr_index4]; data == rand_data4;})
                    end
                end
            join
        end

        #1000;
    endtask

endclass : parallel_dcache_seq


