//=====================================================================
// Project: 4 core MESI cache design
// File Name: random_read_miss_dcache.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class random_read_miss_dcache extends base_test;

    //component macro
    `uvm_component_utils(random_read_miss_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", random_read_miss_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing random_read_miss_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : random_read_miss_dcache


// Sequence for a read-miss on I-cache
class random_read_miss_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(random_read_miss_dcache_seq)

    cpu_transaction_c trans;
    
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[5];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu;
    rand int addr_index;

    //constructor
    function new (string name="random_read_miss_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

    repeat(25)begin  
        // Read Miss + free block
        rand_set = $urandom(); 
        addr_index = $urandom_range(0,4);
        for(int i = 0; i < 5; i++)begin // addresses in the same set
            rand_addr[i] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
            rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
            `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
        end
        repeat(10)begin
            for(int i = 0; i < 4; i++)begin // Read Miss same addr all cpu
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[i], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
            end
            
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            rand_cpu = $urandom_range(0,3);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;}) // Write 1 cpu -> Modified state, other block is invalidated
            
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; address == rand_addr[addr_index%5];}) // Read Miss -> free block -> the copy is in Modified
        end

        //============================================================================================================================================//

        // Read Miss + no free block
        rand_set = $urandom(); 
        for(int i = 0; i < 5; i++)begin // addresses in the same set
            rand_addr[i] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
            rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
            `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
        end

        repeat(15)begin
            rand_cpu = $urandom_range(0,3);
            for(int j = 0; j < 4; j++)begin // Fill up cache with addresses in the same set
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
                addr_index++;
            end
        
            // Read Miss + no free block + the replacement is in Exclusive State 
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
            addr_index++;
            
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            addr_index++;

            // Read Miss + no free block + the replacement is in Modified state
            repeat(4)begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})            
                addr_index++;
            end
            // Read Miss + no free block + the replacement is in Shared State 
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
            
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
        end
    end

    #1000;
    
    endtask

endclass : random_read_miss_dcache_seq
