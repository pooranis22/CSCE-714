//=====================================================================
// Project: 4 core MESI cache design
// File Name: random_write_miss_dcache.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class random_write_miss_dcache extends base_test;

    //component macro
    `uvm_component_utils(random_write_miss_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", random_write_miss_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing random_write_miss_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : random_write_miss_dcache


// Sequence for a read-miss on I-cache
class random_write_miss_dcache_seq extends base_vseq;
    //object macro
    `uvm_object_utils(random_write_miss_dcache_seq)

    cpu_transaction_c trans;
    
    rand bit [`ADDR_WID_LV1-1:0] rand_addr[5];
    rand bit [`DATA_WID_LV1-1:0] rand_data;
    rand bit [`INDEX_WID_LV1-1:0] rand_set;

    rand int rand_cpu;
    rand int addr_index;

    //constructor
    function new (string name="random_write_miss_dcache_seq");
        super.new(name);
    endfunction : new

    virtual task body();

    repeat(40)begin  
        // Write Miss + free block
        rand_set = $urandom(); 
        addr_index = $urandom_range(0,4);
        for(int i = 0; i < 5; i++)begin // addresses in the same set
            rand_addr[i] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
            rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
            `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
        end

        addr_index = $urandom_range(0,4);
        repeat(20)begin
            // Write Miss -> free block -> the copy is in Exclusive State
            rand_cpu = $urandom_range(0,3); // READ Miss cpu0 to make E state
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff); // WRITE MISS cpu1 with the same addr => no write back
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            addr_index++;

            // WRITE Miss -> free block -> the copy is in Shared State 
            rand_cpu = $urandom_range(0,3); 
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; address == rand_addr[addr_index%5];}) 
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);  // Write miss
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+2)%4], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            addr_index++;

            // WRITE Miss -> free block -> the copy is in Modified State
            rand_cpu = $urandom_range(0,3); 
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff); // WRITE 
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff); // WRITE MISS cpu0 with the same addr => write back
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
        end

        //============================================================================================================================================//

        // Write Miss + no free block
        rand_set = $urandom(); 
        for(int i = 0; i < 5; i++)begin // addresses in the same set
            rand_addr[i] = $urandom_range(32'h4000_0000, 32'hffff_ffff);
            rand_addr[i][`INDEX_MSB_LV1:`INDEX_LSB_LV1] = rand_set;
            `uvm_info("ADDR", $sformatf("ADDR_CHECK: %0h", rand_addr[i]), UVM_LOW)
        end

        repeat(20)begin
            rand_cpu = $urandom_range(0,3);
            for(int j = 0; j < 4; j++)begin // Fill up cache with addresses in the same set
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
                addr_index++;
            end

            // Write Miss -> no free block -> the replacement to be done is Exclusive
            rand_cpu = $urandom_range(0,3); 
            repeat(4)begin
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
                addr_index++;
            end
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
            addr_index++;

            // Write Miss -> no free block -> the replacement to be done is Shared
            rand_cpu = $urandom_range(0,3); 
            repeat(4) begin // Shared State
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[(rand_cpu+1)%4], {request_type == READ_REQ; address == rand_addr[addr_index%5];})
                addr_index++;
            end
            rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff); // Evict
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})

            // Write Miss -> no free block -> the replacement to be done is Modified
            rand_cpu = $urandom_range(0,3); 
            repeat(5)begin
                rand_data = $urandom_range(32'h0000_0000,32'hffff_ffff);
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[rand_cpu], {request_type == WRITE_REQ; address == rand_addr[addr_index%5]; data == rand_data;})
                addr_index++;
            end
        #1000;

        end
    end

    #1000;
    
    endtask

endclass : random_write_miss_dcache_seq
