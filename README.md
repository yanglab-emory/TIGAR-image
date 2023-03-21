# TIGAR-image
[TIGAR tool](https://github.com/yanglab-emory/TIGAR) on [Docker](https://hub.docker.com/repository/docker/rndparr/tigar-web/general). 


## Example Usage

The commands to run each function should look like the following (with `PATH_TO_DIRECTORY` changed to the directory to mount). The `PATH_TO_DIRECTORY` directory  should contain the **input files** and will also be the **directory that Docker writes the results to** (you may need to change permissions on the directory to allow Docker write access).

The following examples use the files included in the [ExampleData](https://github.com/yanglab-emory/TIGAR/tree/master/ExampleData) folder included with TIGAR.

### DPR training
```bash
## Example files:
# gene_exp.txt
# sampleID.txt 
# example.vcf.gz
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ tigar TIGAR_Model_Train.sh --model DPR --gene_exp gene_exp.txt --train_sampleID sampleID.txt --chr 1 --genofile example.vcf.gz --genofile_type vcf --format GT --maf 0.01 --hwe 0.0001 --cvR2 1 --dpr 1 --ES fixed
```

### Elastic-Net training
```bash
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ tigar TIGAR_Model_Train.sh --model elastic_net --gene_exp gene_exp.txt --train_sampleID sampleID.txt --chr 1 --genofile example.vcf.gz --genofile_type vcf --format GT --maf 0.01 --hwe 0.0001 --cvR2 1
```

### GReX prediction
```bash
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ tigar TIGAR_GReX_Pred.sh --gene_anno gene_anno.txt --test_sampleID test_sampleID.txt --chr 1 --weight eQTLweights.txt.gz --genofile example.vcf.gz --genofile_type vcf --format GT
```

### Summary-level TWAS with plink LD and FUSION test statistic
```bash
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ rndparr/tigar-web:v1.1 TIGAR_TWAS.sh --asso 2 --gene_anno gene_anno.txt --Zscore CHR1_GWAS_Zscore.txt.gz --weight eQTLweights.txt.gz --LD CHR1_plink_reference_cov --LD_type plink --chr 1 --test_stat FUSION
```

### Summary-level TWAS with TIGAR LD and both test statistics (FUSION and SPrediXcan)
```bash
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ rndparr/tigar-web:v1.1 TIGAR_TWAS.sh --asso 2 --gene_anno gene_anno.txt --Zscore CHR1_GWAS_Zscore.txt.gz --weight eQTLweights.txt.gz --LD CHR1_reference_cov.txt.gz --LD_type TIGAR --chr 1 --test_stat both
```

### Summary-level TWAS with TIGAR LD and SPrediXcan test statistic (FUSION and SPrediXcan)
```bash
docker run -v PATH_TO_DIRECTORY:/home/appuser/VOLUME/ rndparr/tigar-web:v1.1 TIGAR_TWAS.sh --asso 2 --gene_anno gene_anno.txt --Zscore CHR1_GWAS_Zscore.txt.gz --weight eQTLweights.txt.gz --LD CHR1_reference_cov.txt.gz --LD_type TIGAR --chr 1 --test_stat SPrediXcan
```
