# rodent_molecular_identification
 
## Sequencing results

The FASTA files are downloaded from the eurofins website and run using BLAST to classify the species from the CytB sequence. The protocol for the setup of the BLAST algorithm is available in the Chapter 3 repository [here](https://github.com/DidDrog11/chapter_3/blob/observed_data/report/Supplementary-Material-2.pdf). 

The `sequencing.csv` file is manually updated with the results of the BLAST search and is stored in the `data/inventory` folder.

The `sequencing_results.R` script can then be run to pull in additional data on the samples from the `rodent_trapping` repository.

## Samples to be sequenced

An updated list of the samples remaining to be sequenced can be generated once this is run. The `to_be_sequenced.R` script requires an updated `sequencing.csv` to compare available samples with those that have been successfully analysed.