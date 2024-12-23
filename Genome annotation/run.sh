# Repeat annotation
ltr_finder -D 15000 -d 1000 -L 7000 -l 100 -p 20 -C -M 0.9 ${acc}.genome.fasta > $acc.finder.scn
BuildDatabase -name $acc -engine ncbi ${acc}.genome.fasta
RepeatModeler -database $acc -pa 15
RepeatMasker -e ncbi -lib ${acc}.TElib -pa 15 -gff -dir out/ ${acc}.genome.fasta

# Ab initio gene prediction using augustus:
perl randomSplit.pl $gb_file 20   # *.gb.train   *.gb.test
perl optimize_augustus.pl --species=$acc --rounds=5 --cpus=12 --kfold=10 $gb_file\.test --onlytrain=$gb_file\.train --metapars=$augustus/config/species/$acc/$acc\_metapars.cfg > optimize.out
etraining --species=$acc  $gb_file.train
augustus --species=$acc --gff3=on > $acc.gff

# Transcript assembly using Trinity:
Trinity --seqType fq --max_memory 150G --samples_file sample_file.txt --CPU 25

# Homology-based gene prediction using GenomeThreader:
gth -gff3out -intermediate -minorflen 147 -startcodon -duplicatecheck seq \
  -protein ${homologous}.fasta -translationtable 1 -genomic ${acc}.genome.fasta -o ${homologous}.fasta.gff

# Integration of gene annotations using EVM:
perl $EVM_dir/EvmUtils/partition_EVM_inputs.pl --genome ${acc}.genome.fasta --gene_predictions $merged_result --transcript_alignments $transcript_result --segmentSize 100000 --overlapSize 10000 --partition_listing partitions_list.out
perl $EVM_dir/EvmUtils/write_EVM_commands.pl --genome ${acc}.genome.fasta --weights weights.txt --gene_predictions $merged_result --transcript_alignments $transcript_result  --output_file_name evm.out --partitions partitions_list.out >commands.list
parallel --jobs 20 < commands.list
perl $EVM_dir/EvmUtils/recombine_EVM_partial_outputs.pl --partitions partitions_list.out --output_file_name evm.out
perl $EVM_dir/EvmUtils/convert_EVM_outputs_to_GFF3.pl --partitions partitions_list.out --output evm.out  --genome ${acc}.genome.fasta

# Functional annotation using interproscan:
bash interproscan.sh -iprlookup -pa -goterms -i $infile -f tsv
