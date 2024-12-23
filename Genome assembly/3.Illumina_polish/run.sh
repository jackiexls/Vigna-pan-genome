#!/bin/bash

ref=zlv5_canu.contigs.fasta
read1=zhonglv5/00.data/000.illumina/NDES00539_L1_1.fq.gz
read2=zhonglv5/00.data/000.illumina/NDES00539_L1_2.fq.gz

CPU=15
mkdir index
bwa index -p index/draft $ref
bwa mem -t $CPU index/draft $read1 $read2 | samtools sort -@ 10 -O bam -o align.bam
samtools index -@ $CPU align.bam

gatk MarkDuplicates -I align.bam -O align.markdup.bam -M align.markdup_metrics.txt
samtools index -@ $CPU align.markdup.bam

samtools view -@ $CPU -h -b -q 30 align.markdup.bam > align_filter.bam
samtools index -@ $CPU align_filter.bam

MEMORY=600
java -Xmx${MEMORY}G -jar /share/home/software/software/pilon-1.24/pilon-1.24.jar --genome $draft --frags align_filter.bam \
    --fix snps,indels \
    --output zlv5_pilon_polished --vcf &> pilon.log


perl -pe 's/_pilon//' zlv5_pilon_polished.fasta >zlv5.genome.final.fasta
