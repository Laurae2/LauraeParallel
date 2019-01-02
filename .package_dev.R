# Load useful libraries for development
library(devtools)
library(roxygen2) # devtools::install_github("klutometis/roxygen")

# Set the working directory to where I am
setwd("E:/GitHub/LauraeParallel")

# Generate documentation
document()

# Check for errors
devtools::check(document = TRUE)

# Install package
install(".")
