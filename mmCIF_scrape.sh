#Script to download mmCIF PDB and scrape data
#Christian Orr 2019
#Script will take up around 200GB of space to run. 

mkdir mmCIF

rsync -rlpt -v -z --delete --port=33444 \
rsync.rcsb.org::ftp_data/structures/divided/mmCIF/ ./mmCIF

cd mmCIF

mkdir ../all_cif

echo "moving all cifs to single dir"

mv 0*/* ../all_cif/
mv 1*/* ../all_cif/
mv 2*/* ../all_cif/
mv 3*/* ../all_cif/
mv 4*/* ../all_cif/
mv 5*/* ../all_cif/
mv 6*/* ../all_cif/
mv 7*/* ../all_cif/
mv 8*/* ../all_cif/
mv 9*/* ../all_cif/
mv a*/* ../all_cif/
mv b*/* ../all_cif/
mv c*/* ../all_cif/
mv d*/* ../all_cif/
mv e*/* ../all_cif/
mv f*/* ../all_cif/
mv g*/* ../all_cif/
mv h*/* ../all_cif/
mv i*/* ../all_cif/
mv j*/* ../all_cif/
mv k*/* ../all_cif/
mv l*/* ../all_cif/
mv m*/* ../all_cif/
mv n*/* ../all_cif/
mv o*/* ../all_cif/
mv p*/* ../all_cif/
mv q*/* ../all_cif/
mv r*/* ../all_cif/
mv s*/* ../all_cif/
mv t*/* ../all_cif/
mv u*/* ../all_cif/
mv v*/* ../all_cif/
mv w*/* ../all_cif/
mv x*/* ../all_cif/
mv y*/* ../all_cif/
mv z*/* ../all_cif/

cd ../all_cif

time find . | xargs gunzip

#get rid of non x-ray crystallography data. Takes ~ 1 hour each
time find . -exec grep -l "    'SOLUTION NMR'" "{}" \; -delete
time find . -exec grep -l "    'ELECTRON MICROSCOPY'" "{}" \; -delete
time find . -exec grep -l "    'ELECTRON CRYSTALLOGRAPHY'" "{}" \; -delete
time find . -exec grep -l "    'SOLID-STATE NMR'" "{}" \; -delete
time find . -exec grep -l "    'FIBER DIFFRACTION'" "{}" \; -delete
time find . -exec grep -l "    'NEUTRON DIFFRACTION'" "{}" \; -delete
time find . -exec grep -l "    'SOLUTION SCATTERING'" "{}" \; -delete
time find . -exec grep -l "    'HYBRID'" "{}" \; -delete
time find . -exec grep -l "    'POWDER DIFFRACTION'" "{}" \; -delete
time find . -exec grep -l "    'OTHER'" "{}" \; -delete

#get relevant info and put into out.csv. Takes ~1.5 hour total
time find . | xargs gawk 'BEGIN { ORS=", "}; /_entry.id/ { print $2} /_pdbx_database_status.recvd_initial_deposition_date/ { print $2} /_symmetry.Int_Tables_number/ { print $2} /_exptl.method/ { print $2 $3 $4} /_diffrn_radiation_wavelength.wavelength/ { print $2} /_diffrn_source.source   / { print $2 $3 $4 $5} /_refine.pdbx_method_to_determine_struct/ { printf "%s\n", $2 $3 $4 $5 $6}' > out.csv

#pull entryID, date and synchrotron from mmCIF file, needs manual curation after with vim.
time find . | xargs gawk 'BEGIN { ORS=", "}; /_entry.id/ { print $2} /_pdbx_database_status.recvd_initial_deposition_date/ { print $NF} /_diffrn_source.pdbx_synchrotron_site/{ printf "%s\n", $NF}' > ../datesource.csv
