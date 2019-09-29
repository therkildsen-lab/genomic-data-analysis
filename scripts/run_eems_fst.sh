#!/bin/bash
export OMP_NUM_THREADS=8

PARAMS=$1

/programs/eems/Pairwise_FSTs/runeems_Fsts/src/runeems_Fsts --params $PARAMS


#nohup sh run_eems_fst.sh silverside_eems_test.ini > silverside_eems_test_fstmat_nohup.log &
