# LauraeParallel: Laurae's R package for Parallel Load Balancing

This R package is meant to be used with the `parallel` package in order to speed up long and dynamic optimization computations. It attempts to simulate guided/dynamic OpenMP scheduling, which makes it a very good scheduler for slow and dynamic functions, but very bad for very fast and constant (in time) functions.

It can be used with [LauraeCE](https://github.com/Laurae2/LauraeCE/) R optimization package.

Useful also if you need timeout on functions.

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

With "ERROR" on timeout but keep running:

```r
> library(LauraeParallel)
> library(parallel)
> library(R.utils)
> 
> cl <- makeCluster(2)
> 
> my_fun <- function(x) {
+   Sys.sleep(x)
+   return(x)
+ }
> invisible(clusterEvalQ(cl = cl, expr = {
+   library(R.utils)
+ }))
> clusterExport(cl = cl, "my_fun")
> 
> system.time({data <- LauraeLapply(cl, (1:6) * 0.1, function(x) {my_fun(x)})})
   user  system elapsed 
   0.00    0.02    1.26 
> data
[[1]]
[1] 0.1

[[2]]
[1] 0.2

[[3]]
[1] 0.3

[[4]]
[1] 0.4

[[5]]
[1] 0.5

[[6]]
[1] 0.6

> 
> system.time({data <- LauraeLapply(cl, (1:6) * 0.1, function(x) {
+   err <- try(withTimeout(my_fun(x), timeout = 0.3, onTimeout = "error"))
+   if (class(err) == "try-error") {
+     return("ERROR")
+   } else {
+     return(err)
+   }
+ })})
   user  system elapsed 
   0.00    0.00    1.15 
> data
[[1]]
[1] 0.1

[[2]]
[1] 0.2

[[3]]
[1] "ERROR"

[[4]]
[1] "ERROR"

[[5]]
[1] "ERROR"

[[6]]
[1] "ERROR"

> 
> stopCluster(cl)
```
