# AIND Ephys Pipeline

This directory contains code and configuration files for running the AIND electrophysiology data processing pipeline on DANDI assets using MIT Engaging.


### Submitting job on MIT Engaging

```bash
module load miniforge

conda activate /orcd/data/dandi/001/environments/name-dandi+compute+submission_env

dandicompute submit --pipeline aind+ephys \
  --dandiset-id [dandiset id] \
  --subject-id [subject id] \
  --session-id [session id] \
  --run-id [run id] \
  --input-path /sub-[subject id]/ses-[session id]/run-[run id]/[blob ID] \
  --output-path /sub-[subject id]/ses-[session id]/run-[run id]/processed \
  --config-path /orcd/data/dandi/001/pipelines/aind+ephys/configs/config.yaml
```



### Output

The output will be stored in [Dandiset `001697`](https://dandiarchive.org/dandiset/001697) under the following directory:

```text
001697/
└── pipeline-aind+ephys/
    └── derivatives/
        └── asset-[first 8 characters of blob or zarr ID]/
            └── results-[results ID]/
                ├── code/ (submission script and config files)
                │   └── ...
                ├── intermediate/ (intermediate files from processing)
                │   └── ... (the processed units)
                ├── logs/ (logs from SLURM, SpikeInterface, and Nextflow)
                │   └── ... (the processed units)
                ├── output/ (processed units)
                │   ├── [blob ID]_block[block number]_recording[recording number].nwb
                │   └── ...
                └── visualization/ (various plots useful for assessing quality)
                    └── ...
            └── sourcedata/ (input NWB file)
                └── [asset path or blob ID].nwb
```
