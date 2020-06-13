awk '$3=="gene"' ../../5-postmaker/3-confident/A188Ref1a1.confident.gff | cut -f 1,4,5,7,9 | sed 's/ID=//g' | sed 's/;Name.*//g' > A188Ref1a1.confident.genes


