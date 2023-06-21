#! /bin/bash

PREPARE="Rscript $1/scripts/prepareData.R"
TSPM_SPARSE="Rscript $1/scripts/TSPM_Sparse.R"
TSPM_NON_SPARSE="Rscript $1/scripts/TSPM_Non_Sparse.R"
TSPMPLUS_MEM_SPARSE="Rscript $1/scripts/TSPMPLUS_Mem_Sparse.R"
TSPMPLUS_MEM_NON_SPARSE="Rscript $1/scripts/TSPMPLUS_Mem_Non_Sparse.R"
TSPMPLUS_FILE_SPARSE="Rscript $1/scripts/TSPMPLUS_Files_Sparse.R"
TSPMPLUS_FILE_NON_SPARSE="Rscript $1/scripts/TSPMPLUS_Files_Non_Sparse.R"


###prepare data
echo "preparing data"
/usr/bin/time -p -v $PREPARE > $1/output/preparation.txt 2>&1
echo "data prepared"
for i in {1..10}
do
  mkdir -p $1/output/${i}/
  echo -e "\n\nentering iteration $i "
  echo "tSPMPlus:"
  /usr/bin/time -p -v $TSPMPLUS_MEM_SPARSE >  $1/output/${i}/MEM_SPARSE.txt 2>&1
  /usr/bin/time -p -v $TSPMPLUS_MEM_NON_SPARSE > $1/output/${i}/MEM_NON_SPARSE.txt 2>&1
  /usr/bin/time -p -v $TSPMPLUS_FILE_SPARSE > $1/output/${i}/FILE_SPARSE.txt 2>&1
  /usr/bin/time -p -v $TSPMPLUS_FILE_NON_SPARSE > $1/output/${i}/FILE_NON_SPARSE.txt 2>&1
done
