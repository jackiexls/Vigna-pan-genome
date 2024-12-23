#!/bin/bash

vcf=Vigna_PAV_format.vcf.gz
tabix -p vcf $vcf

ref=reference.fa
threads=30

vg construct -t $threads -a -f -S -v $vcf -r $reference  >Vigna_PAV.vg
mkdir tmp
vg index -t $threads -L -b tmp -x Vigna_PAV.xg Vigna_PAV.vg
vg gbwt -d tmp -g Vigna_PAV.gg -x Vigna_PAV.xg -o Vigna_PAV.gbwt -P
vg snarls -t $threads --include-trivial Vigna_PAV.xg >Vigna_PAV.trivial.snarls
vg index -b tmp -t $threads -j Vigna_PAV.dist -s Vigna_PAV.trivial.snarls Vigna_PAV.vg
vg minimizer -t $threads -i Vigna_PAV.min -g Vigna_PAV.gbwt -d Vigna_PAV.dist Vigna_PAV.xg
vg snarls -t $threads Vigna_PAV.xg >Vigna_PAV.snarls
