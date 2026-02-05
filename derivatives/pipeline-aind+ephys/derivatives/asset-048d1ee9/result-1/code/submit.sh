#!/bin/bash
#SBATCH --job-name=AIND-Ephys-Pipeline
#SBATCH --output=/orcd/data/dandi/001/dandi-compute/processing/tmpbjcorpst/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-1/logs/job-%j_slurm.log
#SBATCH --mem=16GB
#SBATCH --partition=mit_normal
#SBATCH --time=12:00:00

NWB_FILE_PATH=""
DATA_PATH="$(dirname "$NWB_FILE_PATH")"

RESULTS_PATH="/orcd/data/dandi/001/dandi-compute/processing/tmpbjcorpst/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-1/intermediate"
WORKDIR=/orcd/data/dandi/001/dandi-compute/work
NXF_APPTAINER_CACHEDIR=/orcd/data/dandi/001/dandi-compute/work/apptainer_cache

source /etc/profile.d/modules.sh
module load miniforge

conda activate /orcd/data/dandi/001/environments/name-nextflow_environment

DATA_PATH="$DATA_PATH" RESULTS_PATH="$RESULTS_PATH" NXF_APPTAINER_CACHEDIR="$NXF_APPTAINER_CACHEDIR" nextflow \
    -C /orcd/data/dandi/001/dandi-compute/processing/tmpbjcorpst/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-1/code/mit_engaging.config \
    -log "/orcd/data/dandi/001/dandi-compute/processing/tmpbjcorpst/001697/derivatives/pipeline-aind+ephys/derivatives/asset-048d1ee9/result-1/logs/nextflow.log" \
    run /orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/main_multi_backend.nf \
    -work-dir "$WORKDIR" \
    --job_dispatch_args "--input nwb --nwb-files $NWB_FILE_PATH" \
    --nwb_ecephys_args "--backend hdf5"

cd $RESULTS_PATH
# TODO: move various items into places
# TODO: remove need for extra flags
dandi upload --allow-any-path --validation skip
rm -rf /orcd/data/dandi/001/dandi-compute/processing/tmpbjcorpst