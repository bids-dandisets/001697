#!/bin/bash
#SBATCH --job-name=AIND-Ephys-Pipeline
#SBATCH --output=/orcd/data/dandi/001/dandi-compute/processing/tmpi_crvvfx/001697/derivatives/dandiset-000943/sub-M7/ses-M7-D15-2020-11-16-16-16-33/pipeline-aind+ephys/version-+c75f900/params-98fd947_config-6568dda_attempt-1/logs/job-%j_slurm.log
#SBATCH --mem=1GB
#SBATCH --cpus-per-task 1
#SBATCH --partition=mit_normal
#SBATCH --time=12:00:00

NWB_FILE_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/011/8dc/0118dc4a-b8e4-4f7d-80f3-80be3799eb9f"
DATA_PATH="/orcd/data/dandi/001/s3dandiarchive/blobs/011/8dc"

RESULTS_PATH="/orcd/data/dandi/001/dandi-compute/processing/tmpi_crvvfx/001697/derivatives/dandiset-000943/sub-M7/ses-M7-D15-2020-11-16-16-16-33/pipeline-aind+ephys/version-+c75f900/params-98fd947_config-6568dda_attempt-1/intermediate"
WORKDIR="/orcd/data/dandi/001/dandi-compute/work"
NXF_APPTAINER_CACHEDIR="/orcd/data/dandi/001/dandi-compute/work/apptainer_cache"

source /etc/profile.d/modules.sh
module load miniforge
module load apptainer

conda activate /orcd/data/dandi/001/environments/name-nextflow_environment

# Ensure the correct version of AIND pipeline is used
git -C "/orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody" checkout 

# Need to ensure latest DANDI-CLI version is always used, otherwise upload of logs may not be possible at the end
pip install -U dandi

DATA_PATH="$DATA_PATH" RESULTS_PATH="$RESULTS_PATH" NXF_APPTAINER_CACHEDIR="$NXF_APPTAINER_CACHEDIR" nextflow \
    -C "/orcd/data/dandi/001/dandi-compute/processing/tmpi_crvvfx/001697/derivatives/dandiset-000943/sub-M7/ses-M7-D15-2020-11-16-16-16-33/pipeline-aind+ephys/version-+c75f900/params-98fd947_config-6568dda_attempt-1/code/mit_engaging.config" \
    -log "/orcd/data/dandi/001/dandi-compute/processing/tmpi_crvvfx/001697/derivatives/dandiset-000943/sub-M7/ses-M7-D15-2020-11-16-16-16-33/pipeline-aind+ephys/version-+c75f900/params-98fd947_config-6568dda_attempt-1/logs/nextflow.log" \
    run "/orcd/data/dandi/001/dandi-compute/aind-ephys-pipeline.cody/pipeline/main_multi_backend.nf" \
    -work-dir "$WORKDIR" \
    --params_file "/orcd/data/dandi/001/dandi-compute/processing/tmpi_crvvfx/001697/derivatives/dandiset-000943/sub-M7/ses-M7-D15-2020-11-16-16-16-33/pipeline-aind+ephys/version-+c75f900/params-98fd947_config-6568dda_attempt-1/code/default.json" \
    --job_dispatch_args "--nwb-files $NWB_FILE_PATH"

cd $RESULTS_PATH
mv nwb/ ../derivatives/
mv visualization_output.json visualization/
mv visualization/ ..
mv nextflow/* ../logs/
cd ..
rm -rf $RESULTS_PATH  # Clean up intermediate values

dandi upload --validation skip  # Dandiset is valid if ignoring NWBI issues from copied files (BIDS part is valid)
echo "tmpi_crvvfx" >> /orcd/data/dandi/001/dandi-compute/processing/done.txt
