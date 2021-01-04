Group 5
Module: Reservation Station
The Reservation Station takes Instruction packets as inputs. The entries in the station are filled according
to the order in which they are dispatched. The Reservation station has the ready bits associated with its
Tags which make sure that the instruction is issued only after the corresponding tag bits are ready to be
issued.
The entries in the Reservation Station are cleared once the particular instruction reaches the Execution
stage. We are shifting the entries which are below the cleared RS entry up by one to fill the emptied
Reservation Station entry.
The CDB Broadcasts the Physical register (upon reaching Complete stage) across the Reservation Station
and adds the ready bits to the tags containing that particular Physical Register.
Structural hazard is reported on the Reservation Station when no more entries are renaming for the
next instructions.
Test bench:
Our testbench checks whether the Reservation Station can handle structural hazards, ready bit
detection, CDB updates and bypassing.

Hit MAKE inside the M1 submission folder in this repository.
The coverage report can be found in the urgReport folder inside M1_submission.
