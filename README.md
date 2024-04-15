# Task was done before initial commit
	I added assertions and coverpoints from lab 5 and 6 in this project already. We need to add more assertions and coverpoints since there should be at least 20 assertions for systembus_interface and at least 20 assertions for lv1_interface. I also created more test file in test directory but they was raw copy from given read-miss-icache.

# TODO Task:
	- Update cpu_monitor_c.sv and system_bus_monitor_c.sv and add more monitor function
	- Add more assertions to cpu_lv1_interface.sv and system_bus_interface.sv
	- Correct coverpoints to cpu_mon_packet_c.sv and system_bus_monitor_c.sv follow feedback from lab6 grade
	- Update read_hit_dcache, read_hit_icache, read_miss_dcache, write_hit_dcache, and write_miss_dcache in test directory.



# Environment setup
> source setup.bash

# compilation and elaboration
> cd ./project/sim/
> irun -f cmd_line_comp_elab.f

# running a test case in GUI
> cd ./project/sim/
> irun -f run_mc.f <+UVM_TESTNAME=test_case_name>

## File Organization
• design – folder that contains all cache design files. "cache_top.sv" is the top level file. Except cache_top.sv all the files in design folder are encrypted.

• design/common – folder that contains component design files shared by level 1 and level 2 cache.

• design/lv1 – folder that contains component design files which exclusively belongs to level 1 cache.

• design/lv2 – folder that contains component design files which exclusively belongs to level 2 cache.

• sim – folder that contains files to control simulation and store results.

• gold – folder that contains the golden arbiter, and memory.

• uvm – folder that contains test bench files: driver, monitor, scoreboard, transactions, packet classes and checkers. top level test bench file: "top.sv"

• test – folder that contains test case files: virtual sequences and test classes.

## TestBench Instructions
  1. Currently the design has all 4 cores enabled.

  2. Level 1 and level 2 cache are all empty at the beginning but memory is pre-filled with initial data. The value of a data block in
  the memory depend on bit[3] of its address.
  data = addr_bus_lv2_mem[3] ? 32'h5555_aaaa : 32'haaaa_5555;
  Once you write back to the memory, it will become the value you have written.

## Github Commands
## To clone:
	git clone <url>
## To checkout particular branch number:
	git checkout <branch number>
## To upload a new repository on github:
	git init
	git add .
	git status
	git commit -m "comment"
	git remote add origin <URL for repo>
	git push -u origin master
## To add a new file or modify some file in existing repo:
	git init
	git add .
	git status
	git commit -m "added this change"
	git push
