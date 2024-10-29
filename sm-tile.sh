#!/bin/bash

#get command arguments to pass to rscript
subplot_width=$1
subplot_buffer=$2

# Activate the 'ms-env' conda environment
basedir=$( cd "$(dirname "$0")" ; pwd -P)

source $(conda info --base)/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate ms-env

echo "Current Conda environment: $(conda info --envs | grep '*' | awk '{print $1}')"

echo "Basedir: ${basedir}"
echo "Working directory: $(pwd)"
# Check if the conda environment was activated
if [[ $? -ne 0 ]]; then
  echo "Failed to activate the conda environment 'ms-env'."
  exit 1
fi

mkdir -p output
find . > output/find.txt
# find ${basedir}
# find . -type f > output/findf.txt
parent_path=$(realpath .)
infile=$(ls input | head -n 1)

# Extract the base filename by removing everything after ".las"
new_infile=$(echo "$infile" | sed 's/\.las.*/.las/')
filename_no_ext=${new_infile%.*}
# Rename the file to just "filename.las"
mv "$parent_path/input/$infile" "$parent_path/input/$new_infile"
input_path="$parent_path/input/$new_infile"
outfile="segmented_merged_${new_infile}"
testout="test_output_${new_infile}"
output_dir="$parent_path/output/"
zipfile="${filename_no_ext}_point_clouds.tar.gz"
#cp "$input_path" "$test_output_path"
echo "input path: $input_path"
echo "output path: $output_path"
# echo "Running r package install script" 
# # Run script to install r-only packages
#Rscript --verbose ${basedir}/run/create-ms-env.R

# # Check if the R script ran successfully
# if [[ $? -ne 0 ]]; then
#   echo "Failed to run the R script."
#   exit 1
# fi

# echo "R package install script ran succedssfully."
echo "Running  MeanShift segmentation"
# Run the R script
Rscript --verbose ${basedir}/run/splitPointCloud.R "$input_path" "$filename_no_ext" "$output_dir"  "$subplot_width" "$subplot_buffer" 

# Check if the R script ran successfully
if [[ $? -ne 0 ]]; then
  echo "Failed to run the R script."
  exit 1
fi

echo "R package install script ran successfully."
echo "Zipping outputs to $zipfile"

cd "$output_dir"
tar -czf "$zipfile" ./*

echo "Removing everything except $zipfile from output"

find . -type f ! -name $zipfile -delete
# Deactivate the conda environment (optional)
conda deactivate
