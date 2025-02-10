library(data.table)

folder <- "put_folder_path_with_epl_files_here"

file_list <- list.files(
  path = folder,
  full.names = TRUE,
  recursive = TRUE
)
file_list <- file_list[!grepl(".txt", file_list, ignore.case = TRUE)]

df <- data.table()

process_file <- function(file) {
  text_file <- fread(file, encoding = "UTF-8", sep = "\n", header = FALSE)[-2]  
  
  split_file <- strsplit(text_file$V1, "\t", fixed = TRUE)
  
  intensities <- gsub(":LEVELS:", "", unlist(strsplit(split_file[[4]], ";")))
  
  file_name <- basename(file)
  id_parts <- strsplit(file_name, " ")[[1]]
  id <- id_parts[1]
  frequency <- id_parts[2]
  
  data <- transpose(as.data.table(split_file[6:518]))
  setnames(data, intensities)
  
  data_long <- data.table(
    timepoint = rep(1:512, times = ncol(data)),
    intensity = rep(as.factor(intensities), each = nrow(data)),
    amplitude = as.numeric(as.matrix(data)),
    frequency = frequency,
    id = id
  )
  return(data_long)
  
}

df <- rbindlist(lapply(file_list, process_file), use.names = TRUE)