# 1. Phylogenetic tree
VCF2Dis -i $vcf -o raw.p_dist.mat
neighbor <neighbor.par
mv outtree lvdou.VCF2Dis.NJtree.nwk

# 2. Population structure
for K in {1..10}
do
  echo $K
  admixture -j6 --cv lvdou_0.05_0.5.bed $K | tee log${K}.out
done

