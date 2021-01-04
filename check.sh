	#!/bin/bash
        mkdir output_files

	diff /home/rufal/group5f19/writeback_sim.out /home/rufal/group5f19/writeback_synth.out | tee 1> error1.txt 
         #Comparing lines in output files with @@@
           if [ -s error1.txt ]
           then
             echo "Mismatch in writeback.out after synth"
           else
              echo "Matching writeback.out after synth"
           fi
        
 
