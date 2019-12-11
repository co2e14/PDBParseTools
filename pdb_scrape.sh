#Script to download .ent PDB and scrape data
#Christian Orr 2019
#Script will take up around 150GB of space to run. 

mkdir pdb

rsync -rlpt -v -z --delete --port=33444 \
rsync.rcsb.org::ftp_data/structures/divided/pdb/ ./pdb

cd pdb

mkdir ../all_pdb

echo "moving all pdbs to single dir"

mv 0*/* ../all_pdb/
mv 1*/* ../all_pdb/
mv 2*/* ../all_pdb/
mv 3*/* ../all_pdb/
mv 4*/* ../all_pdb/
mv 5*/* ../all_pdb/
mv 6*/* ../all_pdb/
mv 7*/* ../all_pdb/
mv 8*/* ../all_pdb/
mv 9*/* ../all_pdb/
mv a*/* ../all_pdb/
mv b*/* ../all_pdb/
mv c*/* ../all_pdb/
mv d*/* ../all_pdb/
mv e*/* ../all_pdb/
mv f*/* ../all_pdb/
mv g*/* ../all_pdb/
mv h*/* ../all_pdb/
mv i*/* ../all_pdb/
mv j*/* ../all_pdb/
mv k*/* ../all_pdb/
mv l*/* ../all_pdb/
mv m*/* ../all_pdb/
mv n*/* ../all_pdb/
mv o*/* ../all_pdb/
mv p*/* ../all_pdb/
mv q*/* ../all_pdb/
mv r*/* ../all_pdb/
mv s*/* ../all_pdb/
mv t*/* ../all_pdb/
mv u*/* ../all_pdb/
mv v*/* ../all_pdb/
mv w*/* ../all_pdb/
mv x*/* ../all_pdb/
mv y*/* ../all_pdb/
mv z*/* ../all_pdb/

cd ../all_pdb

time find . | xargs gunzip

#get rid of non x-ray crystallography data. Takes ~ 1 hour each
time find . -exec grep -l "EXPDTA    SOLUTION NMR" "{}" \; -delete
time find . -exec grep -l "EXPDTA    ELECTRON MICROSCOPY" "{}" \; -delete
time find . -exec grep -l "EXPDTA    ELECTRON CRYSTALLOGRAPHY" "{}" \; -delete
time find . -exec grep -l "EXPDTA    SOLID-STATE NMR" "{}" \; -delete
time find . -exec grep -l "EXPDTA    FIBER DIFFRACTION" "{}" \; -delete
time find . -exec grep -l "EXPDTA    NEUTRON DIFFRACTION" "{}" \; -delete
time find . -exec grep -l "EXPDTA    SOLUTION SCATTERING" "{}" \; -delete
time find . -exec grep -l "EXPDTA    HYBRID" "{}" \; -delete
time find . -exec grep -l "EXPDTA    POWDER DIFFRACTION" "{}" \; -delete
time find . -exec grep -l "EXPDTA    OTHER" "{}" \; -delete

#get relevant info and put into out.csv. Takes ~1.5 hour total
time find . | xargs gawk 'BEGIN { ORS=", "}; / COMPLIES WITH FORMAT / { print $3} /EXPDTA/ {print $2 $3 $4 $5 $6} /200  SYNCHROTRON/ {print $NF} /DATE OF DATA COLLECTION/ {print $NF} /200 DIFFRACTION PROTOCOL:/ {print $5} /METHOD USED TO DETERMINE THE STRUCTURE:/ {printf "%s\n", $9 $10 $11 $12 $13} /WAVELENGTH OR RANGE/ { printf "%5.4f, %5.4f, %5.4f, %5.4f, %5.4f, %5.4f, %5.4f, %5.4f, %5.4f, %5.4f, ", $8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' > ../pdbstdout_10lambdas.csv

#just list wavelengths
time find . | xargs gawk 'BEGIN { ORS=","}; /WAVELENGTH OR RANGE/ { printf "%5.4f\n%5.4f\n%5.4f\n%5.4f\n%5.4f\n%5.4f\n%5.4f\n%5.4f\n%5.4f\n",$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' > lambdaout.csv

#just find resolutions
time find . | xargs gawk 'BEGIN { ORS=","}; /REMARK   3   RESOLUTION RANGE HIGH / {printf "%5.4f\n", $8}' > pdbresout.csv

#get rid of zeros and spaces
sed '/0.0000/d' ./lambdaout.csv
sed '/ /' ./lambdaout.csv

time find . | xargs gawk 'BEGIN { ORS=",";} /REVDAT   1 / {print $4} /REMARK 200 METHOD USED TO DETERMINE THE STRUCTURE:/ { print $9 $ 10 $11 $12 $13 $14 $15 $16 $17 $18} /END / {printf "%s\n", $NF}'

time find . | xargs gawk 'BEGIN { ORS=","}; /HEADER/ { print substr( $NF, length($NF) - 3, length($NF) ) } /REMARK 200  BEAMLINE  / {print $NF} /WAVELENGTH OR RANGE/ { printf "%5.4f%5.4f%5.4f%5.4f%5.4f%5.4f%5.4f\n",$8,$9,$10,$11,$12,$13,$14,$15}' > ../pdbid_beamline_lambda.csv
