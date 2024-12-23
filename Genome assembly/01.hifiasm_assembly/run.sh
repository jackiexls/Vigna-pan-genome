#!/bin/bash

hifiasm -t 30 -o ${accession} ${accession}_hifi_reads.fasta.gz
awk -F'\t' '{if($1=="S") print ">"$2"\n"$3}' ${accession}.bp.p_ctg.gfa >${accession}.hifiasm_contigs.fa

