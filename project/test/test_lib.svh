//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================
//TODO: add your testcase files in here
`include "base_test.sv"

// I-CACHE

`include "lru_read_miss_icache.sv"
`include "lru_read_hit_icache.sv"

`include "read_miss_icache.sv"
`include "read_hit_icache.sv"
`include "write_miss_icache.sv"
`include "write_hit_icache.sv"

`include "randomized_icache.sv"

`include "parallel_icache.sv"

// D-CACHE

`include "lru_read_miss_dcache.sv"
`include "lru_read_hit_dcache.sv"
`include "lru_write_miss_dcache.sv"
`include "lru_write_hit_dcache.sv"

`include "read_miss_dcache.sv"
`include "read_hit_dcache.sv"
`include "write_miss_dcache.sv"
`include "write_hit_dcache.sv"

`include "mesi_read_miss_dcache.sv"
`include "mesi_write_miss_dcache.sv"
`include "mesi_write_hit_dcache.sv"

`include "random_read_miss_dcache.sv"
`include "random_write_hit_dcache.sv"
`include "random_write_miss_dcache.sv"

`include "randomized_dcache.sv"

`include "parallel_dcache.sv"

// OTHERS
`include "random_delay_test.sv"
`include "random_test.sv"

`include "cont_rw_same_addr_dcache.sv"