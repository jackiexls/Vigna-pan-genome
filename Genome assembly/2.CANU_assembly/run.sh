#!/bin/bash

### correct
canu useGrid=false minThreads=10 minOverlapLength=700 minReadLength=1000 \
  -correct -p zlv5 -d zlv5_correct genomeSize=500m -pacbio clean_data/zlv5.pacbio.fa.gz

### trim
canu useGrid=false minThreads=10 minOverlapLength=700 minReadLength=1000 \
  -trim -p zlv5 -d zlv5_trim genomeSize=500m -pacbio zlv5_correct/zlv5.correctedReads.fasta.gz

### assembly
canu useGrid=false minThreads=10 minOverlapLength=700 minReadLength=1000 \
  -assemble -p zlv5 -d zlv5_asssemble genomeSize=500m -pacbio -corrected zlv5_correct/zlv5.trimmedReads.fasta.gz
