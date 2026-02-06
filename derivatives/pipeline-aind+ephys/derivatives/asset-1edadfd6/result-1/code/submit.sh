#!/bin/bash
#SBATCH --job-name=AIND-Ephys-Pipeline
#SBATCH --output=/orcd/data/dandi/001/dandi-compute/processing/tmpa14up9z2/001697/derivatives/pipeline-aind+ephys/derivatives/asset-1edadfd6/result-1/logs/job-%j_slurm.log
#SBATCH --mem=16GB
#SBATCH --partition=mit_normal
#SBATCH --time=12:00:00

set -e

NWB_FILE_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/1ed/adf/1edadfd6-a87f-4a9a-9d52-b42248e963ab"
DATA_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/1ed/adf"

RESULTS_PATH="/orcd/data/dandi/001/dandi-compute/processing/tmpa14up9z2/001697/derivatives/pipeline-aind+ephys/derivatives/asset-1edadfd6/result-1/intermediate"
WORKDIR="/orcd/data/dandi/001/dandi-compute/work"
NXF_APPTAINER_CACHEDIR="/orcd/data/dandi/001/dandi-compute/work/apptainer_cache"

source /etc/profile.d/modules.sh
module load miniforge
module load apptainer

conda activate /orcd/data/dandi/001/environments/name-nextflow_environment

DATA_PATH="$DATA_PATH" RESULTS_PATH="$RESULTS_PATH" NXF_APPTAINER_CACHEDIR="$NXF_APPTAINER_CACHEDIR" nextflow \
    -C "/orcd/data/dandi/001/dandi-compute/processing/tmpa14up9z2/001697/derivatives/pipeline-aind+ephys/derivatives/asset-1edadfd6/result-1/code/mit_engaging.config" \
    -log "/orcd/data/dandi/001/dandi-compute/processing/tmpa14up9z2/001697/derivatives/pipeline-aind+ephys/derivatives/asset-1edadfd6/result-1/logs/nextflow.log" \
    run "/orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/main_multi_backend.nf" \
    -work-dir "$WORKDIR" \
    --job_dispatch_args "--input nwb --nwb-files $NWB_FILE_PATH" \
    --preprocessing_args "--motion skip" \
    --nwb_ecephys_args "--backend hdf5"

cd $RESULTS_PATH
mv nwb ../output
mv visualization_output.json visualization/
mv visualization ..
cp /orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/capsule_versions.env ../code/
mv nextflow/* ../logs/

dandi upload --allow-any-path --validation skip  # TODO: remove need for extra flags
echo "tmpa14up9z2" >> /orcd/data/dandi/001/dandi-compute/processing/done.txt
