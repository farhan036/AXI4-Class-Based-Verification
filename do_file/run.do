
vlib work

REM ==================================================
REM Compile DUT files WITH code coverage
REM ==================================================
vlog -f dut_files.txt +cover -covercells

REM ==================================================
REM Compile TB/verification files WITHOUT code coverage
REM ==================================================
vlog -f tb_files.txt
REM ==================================================
REM Start simulation
REM ==================================================
vsim -assertdebug -voptargs=+acc work.AXI_tb -cover

do wave.do
file mkdir coverage

REM ==================================================
REM Run simulation
REM ==================================================
run -all

REM ==================================================
REM Exclude
REM ==================================================
coverage exclude -scope /AXI_tb/DUT -ftrans write_state W_ADDR->W_IDLE
coverage exclude -scope /AXI_tb/DUT -ftrans write_state W_DATA->W_IDLE
coverage exclude -scope /AXI_tb/DUT -ftrans read_state R_ADDR->R_IDLE
coverage exclude -scope /AXI_tb/DUT -ftrans read_state R_WAIT->R_IDLE

coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 288 -code s
coverage exclude -src axi4.v -line 212 -code s
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 204 -code b
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 212 -code b
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 288 -code b
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 153 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 173 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 184 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 189 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 204 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 224 -code c
coverage exclude -src axi4.v -scope /AXI_tb/DUT -line 264 -code c

coverage exclude -scope /AXI_tb/DUT -togglenode ARSIZE
coverage exclude -scope /AXI_tb/DUT -togglenode AWSIZE
coverage exclude -scope /AXI_tb/DUT -togglenode BRESP
coverage exclude -scope /AXI_tb/DUT -togglenode read_addr_incr
coverage exclude -scope /AXI_tb/DUT -togglenode read_size
coverage exclude -scope /AXI_tb/DUT -togglenode RRESP
coverage exclude -scope /AXI_tb/DUT -togglenode write_addr_incr
coverage exclude -scope /AXI_tb/DUT -togglenode write_size
coverage exclude -scope /AXI_tb/DUT/mem_inst -togglenode j


REM ==================================================
REM Save coverage database
REM ==================================================
coverage save coverage/cov.ucdb

REM ==================================================
REM Functional Coverage
REM ==================================================
coverage report -cvg -details -output coverage/functional_coverage.txt


REM ==================================================
REM Assertion Coverage Report
REM ==================================================
coverage report -assert -details -output coverage/assertion_coverage.txt

REM ==================================================
REM Code Coverage - DUT ONLY
REM ==================================================

coverage report -code bcesft -details -output coverage/all_code_coverage.txt
coverage report -code s -details -output coverage/line_coverage.txt
coverage report -code t -details -output coverage/toggle_coverage.txt
coverage report -code f -details -output coverage/fsm_coverage.txt
coverage report -code b -details -output coverage/branch_coverage.txt
coverage report -code c -details -output coverage/condition_coverage.txt
coverage report -code e -details -output coverage/expression_coverage.txt

# ==================================================
# Combined Code, Assertion & Functional Summary
# ==================================================
coverage report -detail -all -output coverage/full_coverage_summary.txt
