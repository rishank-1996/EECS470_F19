#!/bin/bash

mkdir test
make clean &> /dev/null
#Deleting previous versions..
rm test/Output.txt
rm test/diff.txt
#Creating new files
touch test/Output.txt
touch test/diff.txt

for i in O0 O1 O2 O3 Os Ofast Og 0
do
    export OPT=$i
    echo "Trying optimization: $(tput setaf 1)$i$(tput sgr 0)" 
    echo "Trying optimization: $i" | tee -a  test/diff.txt &> /dev/null
    #For assembly programs:
    for file in test_progs/*.s; do
        make assembly SOURCE=$file &> /dev/null
        echo -e "Running file $(tput setaf 2)$file$(tput sgr 0)" | tee -a  test/Output.txt
        make | tee -a  test/Output.txt &> /dev/null
        grep 'CPI' program.out
        make -C ../../abhinav_p3/eecs470_f19_project3_abhinova/ assembly SOURCE=$file &> /dev/null
        make -C ../../abhinav_p3/eecs470_f19_project3_abhinova/ &> /dev/null
        echo -e "$file" | tee -a  test/diff.txt &> /dev/null
        diff  writeback.out ../../abhinav_p3/eecs470_f19_project3_abhinova/writeback.out | tee -a  test/diff.txt &> /dev/null
    done

    #For c programs:
    for file in test_progs/*.c; do
        #echo "Assembling $file"
        make program SOURCE=$file &> /dev/null
        echo -e "Running file $(tput setaf 2)$file$(tput sgr 0)" | tee -a  test/Output.txt
        make | tee -a  test/Output.txt &> /dev/null
        grep 'CPI' program.out
        make -C ../../abhinav_p3/eecs470_f19_project3_abhinova/ program SOURCE=$file &> /dev/null
        make -C ../../abhinav_p3/eecs470_f19_project3_abhinova/ &> /dev/null
        echo -e "$file" | tee -a  test/diff.txt
        diff  writeback.out ../../abhinav_p3/eecs470_f19_project3_abhinova/writeback.out | tee -a  test/diff.txt &> /dev/null
    done

    echo "" | tee -a  test/diff.txt &> /dev/null
done

echo -e "cleaning up"
make clean &> /dev/null

echo "$(tput setaf 1)Done$(tput sgr 0)"
