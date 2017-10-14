# LauraeParallel: Laurae's R package for Parallel Load Balancing

This R package is meant to be used with the `parallel` package in order to speed up long and dynamic optimization computations. It attempts to simulate guided/dynamic OpenMP scheduling, which makes it a very good scheduler for slow and dynamic functions, but very bad for very fast and constant (in time) functions.

It should be used with [LauraeCE](https://github.com/Laurae2/LauraeCE/) R optimization package.

Installation:

```r
devtools::install_github("Laurae2/LauraeParallel")
```

# Example

This is how it currently looks:

```r
> library(parallel)
> cl <- makeCluster(2)
> system.time({parLapply(cl, 1:6, function(x) {
+     Sys.sleep(x)
+     return(x)
+ })})
   user  system elapsed 
   0.43    0.11   15.10 
> system.time({LauraeLapply(cl, 1:6, function(x) {
+     Sys.sleep(x)
+     return(x)
+ })})
   user  system elapsed 
   0.00    0.00   12.02 
```