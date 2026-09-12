# AXI4 Class-Based Verification Environment

A SystemVerilog class-based verification environment developed to verify
an AMBA AXI4 interface connected to a Single-Port Synchronous RAM.

This project demonstrates object-oriented verification using
SystemVerilog classes, constrained-random stimulus generation,
functional coverage, assertions, and scoreboard-based checking.

------------------------------------------------------------------------

## Table of Contents

-   [Project Overview](#project-overview)
-   [Design Under Test](#design-under-test)
-   [Verification Architecture](#verification-architecture)
-   [Verification Components](#verification-components)
-   [AXI4 Features Verified](#axi4-features-verified)
-   [Constrained-Random Verification](#constrained-random-verification)
-   [Functional Coverage](#functional-coverage)
-   [Assertions](#assertions)
-   [Scoreboard and Golden Model](#scoreboard-and-golden-model)
-   [Verification Test Scenarios](#verification-test-scenarios)
-   [Bugs Identified and Fixed](#bugs-identified-and-fixed)
-   [Project Structure](#project-structure)
-   [Simulation Results](#simulation-results)
-   [Tools and Technologies](#tools-and-technologies)
-   [Learning Objectives](#learning-objectives)
-   [Future Improvements](#future-improvements)
-   [Related Project](#related-project)
-   [Authors](#authors)

------------------------------------------------------------------------

## Project Overview

The Design Under Test (DUT) is an AXI4 interface connected to a
Single-Port Synchronous RAM memory.

The verification environment was developed using a modular SystemVerilog
class-based architecture to verify both normal and corner-case AXI4
transactions.

The project focuses on verifying:

-   AXI4 read and write transactions.
-   Write and read channel handshaking.
-   Burst transfers.
-   4KB address boundary compliance.
-   Memory address range validation.
-   Reset behavior.
-   Write priority over read operations.
-   Invalid transaction handling.
-   Functional and code coverage.

------------------------------------------------------------------------

## Design Under Test

The system consists of an AMBA AXI4 interface connected to a Single-Port
Synchronous RAM.

The memory is word-addressable, and byte addresses are converted to word
addresses using address alignment logic.

The verification environment checks normal memory operations as well as
invalid AXI4 scenarios, including bursts that cross a 4KB address
boundary.

------------------------------------------------------------------------

## Verification Architecture

``` text
                    +----------------------+
                    |      Generator       |
                    | Constrained-Random   |
                    +----------+-----------+
                               |
                               | Mailbox
                               v
                    +----------------------+
                    |       Driver         |
                    |   Protocol Stimulus  |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |     AXI4 Interface   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |         DUT          |
                    |  AXI4 + Single-Port  |
                    |     Synchronous RAM  |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |       Monitor        |
                    | Transaction Sampling |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |      Scoreboard      |
                    | Expected vs Actual   |
                    +----------------------+
```

------------------------------------------------------------------------

## Verification Methodology

This project uses a SystemVerilog Class-Based Verification methodology
rather than UVM.

The environment is built using independent reusable classes
communicating through mailboxes and virtual interfaces.

### Main Components

  Component     Responsibility
  ------------- ------------------------------------------------------
  Transaction   Represents AXI4 transactions and randomized stimulus
  Generator     Creates and randomizes transaction objects
  Driver        Converts transactions into pin-level AXI4 signals
  Monitor       Samples DUT interface activity
  Scoreboard    Compares expected and actual behavior
  Environment   Instantiates and connects verification components
  Assertions    Checks protocol-level properties
  Coverage      Measures verification completeness

------------------------------------------------------------------------

## AXI4 Features Verified

The verification environment covers the five AXI4 channels.

### Write Channels

-   Write Address Channel (AW)
-   Write Data Channel (W)
-   Write Response Channel (B)

### Read Channels

-   Read Address Channel (AR)
-   Read Data Channel (R)

The testbench verifies valid/ready handshaking, burst behavior, response
signals, and transaction completion.

------------------------------------------------------------------------

## Constrained-Random Verification

The AXI transaction class uses SystemVerilog randomization constraints
to generate diverse test scenarios.

### Operation Distribution

  Operation   Distribution
  ----------- --------------
  WRITE       35%
  READ        35%
  IDLE        30%

### Address Modes

The randomized transactions target different address ranges and boundary
conditions.

-   Low and mid-range addresses.
-   Addresses constrained to remain within the 4KB boundary.
-   High memory regions.
-   High-edge boundary scenarios.

### Burst Length

The transaction class dynamically sizes write data according to the
generated burst length.

The environment covers:

  Burst Category   Length Range
  ---------------- --------------
  Single Beat      0
  Short Burst      1--15
  Medium Burst     16--127
  Maximum Burst    128--255

------------------------------------------------------------------------

## Functional Coverage

Functional coverage is implemented using embedded SystemVerilog
covergroups.

Coverage points include:

### Address Coverage

-   Low address range.
-   Mid address range.
-   High address range.

### Burst Length Coverage

-   Single-beat bursts.
-   Short bursts.
-   Medium bursts.
-   Maximum-length bursts.

### Control Coverage

-   Operation type: WRITE, READ, and IDLE.
-   Address mode.
-   AWVALID.
-   ARVALID.

Cross-coverage is used to measure combinations of transaction types,
addresses, burst lengths, and control conditions.

------------------------------------------------------------------------

## Assertions

SystemVerilog Assertions are included to monitor protocol behavior and
detect illegal conditions.

The assertions cover important AXI4 protocol requirements, including:

-   Valid signals remain asserted until handshake.
-   Correct write and read transaction sequencing.
-   Burst completion using WLAST and RLAST.
-   Correct response generation.
-   Reset behavior.
-   Address boundary violations.

Assertion coverage is analyzed alongside functional and code coverage.

------------------------------------------------------------------------

## Scoreboard and Golden Model

The scoreboard implements a golden-model-based verification approach.

It compares expected transaction behavior against actual DUT outputs.

The scoreboard continuously checks DUT behavior cycle-by-cycle and
reports:

-   Total checks.
-   Passed checks.
-   Failed checks.
-   Overall verification status.

This provides automated functional correctness checking without relying
exclusively on manual waveform inspection.

------------------------------------------------------------------------

## Verification Test Scenarios

The following test scenarios were implemented:

  -----------------------------------------------------------------------
  Test Case                        Description
  -------------------------------- --------------------------------------
  Reset Test                       Verifies correct reset initialization
                                   and recovery

  Write Operation                  Checks normal AXI4 write transactions

  Write Priority                   Verifies write priority behavior when
                                   both requests are active

  Read Operation                   Checks normal AXI4 read transactions

  Idle Test                        Ensures no transaction occurs when
                                   AWVALID and ARVALID are low

  Random Write                     Randomized write operations without
                                   4KB boundary crossing

  Random Read                      Randomized read operations without 4KB
                                   boundary crossing

  Invalid Write Burst              Tests write transactions crossing the
                                   4KB boundary

  Invalid Read Burst               Tests read transactions crossing the
                                   4KB boundary

  Mixed Random Transactions        Combines valid and invalid randomized
                                   scenarios

  Random Reset                     Verifies behavior during randomized
                                   ARESETn assertion
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Bugs Identified and Fixed

During the verification process, multiple RTL and verification-related
issues were identified and resolved.

### 1. Memory Read Indexing Bug

An off-by-one indexing issue was identified during memory verification.

The read logic was corrected to access the intended memory location.

### 2. Active-Low Reset Handling

The reset logic was corrected to properly handle the active-low reset
signal and initialize the interface as expected.

### 3. 4KB Boundary Checking

The boundary-checking mechanism was improved to detect invalid bursts
before the data transfer phase completes.

The initial address and burst length are used to calculate the total
transaction span, allowing earlier detection of 4KB boundary violations.

### 4. Coverage-Related Dead Bits

The verification and RTL implementation were reviewed to identify
unreachable bits affecting toggle coverage.

Unused or unreachable coverage points were analyzed and handled
appropriately during coverage reporting.

------------------------------------------------------------------------

## Project Structure

The following structure is recommended for the repository. Update file
names if your actual source files use different names.

``` text
AXI4-Class-Based-Verification/
│
├── rtl/
│   ├── axi4_memory.sv
│   └── axi4_slave.sv
│
├── tb/
│   ├── axi_pkg.sv
│   ├── AXI_intrf.sv
│   ├── AXI_transaction.sv
│   ├── AXI_generator.sv
│   ├── AXI_driver.sv
│   ├── AXI_monitor.sv
│   ├── AXI_scoreboard.sv
│   ├── AXI_env.sv
│   ├── AXI_tb.sv
│   └── AXI_properties.sv
│
├── memory_verification/
│   ├── mem_intrf.sv
│   ├── mem_transaction_pkg.sv
│   ├── mem_driver_pkg.sv
│   ├── mem_gen_pkg.sv
│   ├── mem_monitor_pkg.sv
│   ├── mem_scoreboard_pkg.sv
│   ├── mem_env_pkg.sv
│   └── MEM_tb.sv
│
│
├── docs/
│   └── Project_Report.pdf
│
└── README.md
```

------------------------------------------------------------------------

## Simulation Results

The verification environment was tested using directed and
constrained-random scenarios.

A mixed constrained-random scenario generated 800 AXI transactions
covering different transaction types, burst lengths, addresses, and
boundary conditions.

The scoreboard continuously checked DUT behavior throughout simulation.

### Expected Result

``` text
TOTAL TESTS : ...
PASSED      : ...
FAILED      : 0

OVERALL STATUS: SUCCESS
```

Add actual simulation screenshots, waveform captures, and coverage
reports to this section when available.

------------------------------------------------------------------------

## Tools and Technologies

-   SystemVerilog.
-   QuestaSim .
-   Constrained-Random Verification.
-   Functional Coverage.
-   SystemVerilog Assertions (SVA).
-   Mailboxes.
-   Virtual Interfaces.
-   Object-Oriented Programming Concepts.

------------------------------------------------------------------------


## Authors

**Mostafa Mohamed Farhan**\
**Mahmoud Ismail Mahmoud**

Digital Verification Course\
Project 1

------------------------------------------------------------------------
