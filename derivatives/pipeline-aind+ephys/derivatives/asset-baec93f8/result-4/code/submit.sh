#!/bin/bash
#SBATCH --job-name=AIND-Ephys-Pipeline
#SBATCH --output=/orcd/data/dandi/001/dandi-compute/processing/tmp8is00bfu/001697/derivatives/pipeline-aind+ephys/derivatives/asset-baec93f8/result-4/logs/job-%j_slurm.log
#SBATCH --mem=1GB
#SBATCH --partition=mit_normal
#SBATCH --time=12:00:00

NWB_FILE_PATH="/orcd/data/dandi/002/s3dandiarchive/blobs/bae/c93/baec93f8-8ba7-4d37-bc39-dd322d192bd0"
DATA_PATH="/orcd/data/dandi/002/s3dandiarchive/blobs/bae/c93"

RESULTS_PATH="/orcd/data/dandi/001/dandi-compute/processing/tmp8is00bfu/001697/derivatives/pipeline-aind+ephys/derivatives/asset-baec93f8/result-4/intermediate"
WORKDIR="/orcd/data/dandi/001/dandi-compute/work"
NXF_APPTAINER_CACHEDIR="/orcd/data/dandi/001/dandi-compute/work/apptainer_cache"

source /etc/profile.d/modules.sh
module load miniforge
module load apptainer

conda activate /orcd/data/dandi/001/environments/name-nextflow_environment

DATA_PATH="$DATA_PATH" RESULTS_PATH="$RESULTS_PATH" NXF_APPTAINER_CACHEDIR="$NXF_APPTAINER_CACHEDIR" nextflow \
    -C "/orcd/data/dandi/001/dandi-compute/processing/tmp8is00bfu/001697/derivatives/pipeline-aind+ephys/derivatives/asset-baec93f8/result-4/code/mit_engaging.config" \
    -log "/orcd/data/dandi/001/dandi-compute/processing/tmp8is00bfu/001697/derivatives/pipeline-aind+ephys/derivatives/asset-baec93f8/result-4/logs/nextflow.log" \
    run "/orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/main_multi_backend.nf" \
    -work-dir "$WORKDIR" \
    --job_dispatch_args "--input nwb --nwb-files $NWB_FILE_PATH" \
    --preprocessing_args "" \
    --nwb_ecephys_args "--backend hdf5"

cd $RESULTS_PATH
mv nwb ../output
mv visualization_output.json visualization/
mv visualization ..
cp /orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/capsule_versions.env ../code/
mv nextflow/* ../logs/

dandi upload --allow-any-path --validation skip  # TODO: remove need for extra flags
echo "tmp8is00bfu" >> /orcd/data/dandi/001/dandi-compute/processing/done.txt
