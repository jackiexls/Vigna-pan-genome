# 1. Gene-based pan-genome
orthofinder -f $indir -M msa -S diamond -T fasttree -t 20 -o $outdir -p tmp

# 2. SV identification
nucmer --mum --mincluster=100 --prefix=$acc --threads=20 $ref $query 
mummerplot -png --medium --layout --fat --filter -p $acc -R $ref -Q $query $acc.delta
delta-filter -m -i 89 $acc.delta > $acc.delta.filtered
show-coords -THrd $acc.delta.filtered > $acc.delta.filtered.coords
syri -c $acc.delta.filtered.coords -r $ref -q $query -d $acc.delta --all --no-chrmatch
