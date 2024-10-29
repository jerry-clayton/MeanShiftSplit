## File takes one LAS file, split it into tiles based on inputs, and then save each tile

###
# Set parameters for MS segmentation from command line args
###

args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
input_tile_name <- args[2]
output_dir <- args[3]

# Plot width for subplots
P_WIDTH <- as.numeric(args[4])
# Plot buffer for subplots
P_BUFFER <- as.numeric(args[5])

library(lidR)
library(MeanShiftR)
library(data.table)
library(sf)


print(paste("input:",input_file))

# use all available processor cores
set_lidr_threads(0)

f_las <- readLAS(input_file)

# convert LAS to data.table for MeanShiftR package
f_dt <- lidR::payload(f_las) %>% as.data.table

print("Generating point clouds")
# subdivide the point cloud to parallelize
point_clouds <- MeanShiftR::split_BufferedPointCloud(f_dt, plot.width = P_WIDTH, buffer.width = P_BUFFER)
print("Point cloud generation done")

filecount <- 0
print("num of point clouds")
print(length(point_clouds))
for (tile in 1:length(point_clouds)){
     filecount <- filecount + 1
     curr <- point_clouds[tile]
     saveRDS(curr,paste0(output_dir,input_tile_name,"_pc_",filecount))
}
