#!/bin/bash

ref=reference/Vigna_genome.fasta
CPU=15
bwa mem -t $CPU -R "@RG\tID:sample\tPL:Illumina\tSM:sample" $ref $data_dir/sample_1_clean.fq.gz $data_dir/sample_2_clean.fq.gz | samtools view -@ $CPU -bS -F 256 > bam_dir/sample.bam
samtools view -@ $CPU -h -b -q30 bam_dir/sample.bam > bam_dir/sample.q30.bam
samtools sort -@ $CPU -o bam_dir/sample.q30.sorted.bam bam_dir/sample.q30.bam
samtools index  -@ $CPU bam_dir/sample.q30.sorted.bam

gatk MarkDuplicates -I bam_dir/sample.q30.sorted.bam -O bam_dir/sample.q30.markdup.bam -M bam_dir/sample.q30.markdup_metrics.txt
samtools index -@ 4 bam_dir/sample.q30.markdup.bam

gatk HaplotypeCaller --emit-ref-confidence GVCF --native-pair-hmm-threads 4 -R $reference -I bam_dir/sample.q30.markdup.bam -O hap_dir/sample.g.vcf.gz

gatk CombineGVCFs -R $ref -O lvdou.combined.g.vcf.gz --variant hap_dir/*.g.vcf.gz

gatk GenotypeGVCFs -R $ref -V lvdou.combined.g.vcf.gz -O vcf_dir/lvdou.raw.vcf.gz

gatk SelectVariants -R $ref -V vcf_dir/lvdou.raw.vcf.gz -O vcf_dir/lvdou.snp.vcf.gz --select-type-to-include SNP --restrict-alleles-to BIALLELIC

gatk VariantFiltration -O $outfile \
                         -V vcf_dir/lvdou.snp.vcf.gz \
                         --filter-expression "QD < 2.0 || MQ < 40.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
                         --filter-name "LowQual"

bgzip -d -c -@ $CPU $outfile | grep -v "LowQual" >vcf_dir/lvdou.snp.LQ.filtered.vcf
