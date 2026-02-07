#!/bin/bash
#SBATCH --job-name=AIND-Ephys-Pipeline
#SBATCH --output=/orcd/data/dandi/001/dandi-compute/processing/tmpjjq0ccss/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-17/logs/job-%j_slurm.log
#SBATCH --mem=1GB
#SBATCH --partition=mit_normal
#SBATCH --time=12:00:00

NWB_FILE_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/048/d1e/048d1ee9-83b7-491f-8f02-1ca615b1d455"
DATA_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/048/d1e"

RESULTS_PATH="/orcd/data/dandi/001/dandi-compute/processing/tmpjjq0ccss/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-17/intermediate"
WORKDIR="/orcd/data/dandi/001/dandi-compute/work"
NXF_APPTAINER_CACHEDIR="/orcd/data/dandi/001/dandi-compute/work/apptainer_cache"

source /etc/profile.d/modules.sh
module load miniforge
module load apptainer

conda activate /orcd/data/dandi/001/environments/name-nextflow_environment

DATA_PATH="$DATA_PATH" RESULTS_PATH="$RESULTS_PATH" NXF_APPTAINER_CACHEDIR="$NXF_APPTAINER_CACHEDIR" nextflow \
    -C "/orcd/data/dandi/001/dandi-compute/processing/tmpjjq0ccss/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-17/code/mit_engaging.config" \
    -log "/orcd/data/dandi/001/dandi-compute/processing/tmpjjq0ccss/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-17/logs/nextflow.log" \
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
echo "tmpjjq0ccss" >> /orcd/data/dandi/001/dandi-compute/processing/done.txt
