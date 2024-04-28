//=====================================================================
// Project: 4 core MESI cache design
// File Name: random_delay_test.sv
// Description: Randomized Test in D-Cache
// Modifiers: Quy
//=====================================================================

class random_delay_test extends base_test;

    //component macro
    `uvm_component_utils(random_delay_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", random_delay_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing random_delay_test test" , UVM_LOW)
    endtask: run_phase

endclass : random_delay_test


// Sequence for a read-miss on I-cache
class random_delay_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(random_delay_test_seq)

    rand bit [`ADDR_WID_LV1-1:0] rand_addr[4];

    cpu_transaction_c trans[4];

    rand int rand_cpu[4];
    rand bit rand_op[4];

    rand int unsigned wait_time;

    //constructor
    function new (string name="random_delay_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        repeat(500)begin
            for(int i = 0; i < 4; i++) begin
                rand_addr[i] = $urandom();
                rand_cpu[i] = $urandom_range(0,3);
                rand_op[i] = $urandom();
                wait_time = $urandom_range(0,500);
            end

            fork
                `uvm_do_on_with(trans[0], p_sequencer.cpu_seqr[rand_cpu[0]], {request_type == rand_op[0]; address == rand_addr[0]; wait_cycles == wait_time;})
                `uvm_do_on_with(trans[1], p_sequencer.cpu_seqr[rand_cpu[1]], {request_type == rand_op[1]; address == rand_addr[1]; wait_cycles == wait_time;})
                `uvm_do_on_with(trans[2], p_sequencer.cpu_seqr[rand_cpu[2]], {request_type == rand_op[2]; address == rand_addr[2]; wait_cycles == wait_time;})
                `uvm_do_on_with(trans[3], p_sequencer.cpu_seqr[rand_cpu[3]], {request_type == rand_op[3]; address == rand_addr[3]; wait_cycles == wait_time;})
            join

        end

        #100;
    endtask

endclass : random_delay_test_seq


