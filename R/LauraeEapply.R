#' Laurae's Parallel Environment Apply with Load Balancing
#'
#' This function performs \code{parallel::parLapply} using an environment as the input list, with proper load balancing (OpenMP-like pragma guided/dynamic instead of pragma static in \code{parallel::parLapply}).
#' 
#' In contrast to \code{base:eapply}, the executed function remains in \code{.GlobalEnv} (or the environment in which it is executed). Actually, you could just do \code{LauraeParallel::LauraeLapply(cl = cl, x = eapply(x, function(x) {x}), fun = fun, ...)}. Nothing new...
#'
#' Pragma guided/dynamic works very well for long tasks which have dynamic computation time (such as machine learning tasks on large data). However, it becomes very poor when data is computed very quickly, as the overhead increases dramatically. With the default \code{parallel::parLapply}, data is chunked for each worker first, then submitted (static pragma), which makes it significantly faster on (not too) smaller data.
#'
#' Please check the example to understand the difference between guided/dynamic pragma and static pragma scheduling for parallelization.
#'
#' @param cl Type: cluster. It must be created by \code{snow}.
#' @param x Type: environment.
#' @param fun Type: function to parallelize.
#' @param ... More parameters to pass to the function.
#'
#' @return A list of elements.
#'
#' @examples
#'
#' library(parallel)
#' cl <- makeCluster(2)
#'
#' # Set this to 1 for more realistic testing...
#' airman_speedtest <- 0.1
#' 
#' my_env <- new.env()
#' for (i in 1:6) {
#'   my_env[[as.character(i)]] <- i * airman_speedtest
#' }
#'
#' # Guided/Dynamic scheduling: 12 Seconds
#' # Preparation: none
#' # 00s => start 1, start 2
#' # 01s => end 1, start 3
#' # 02s => end 2, start 4
#' # 04s => end 3, start 5
#' # 06s => end 4, start 6
#' # 08s => end 5
#' # 12s => end 6
#' system.time({LauraeEapply(cl, my_env, function(x) {
#'   Sys.sleep(x)
#'   return(x)
#' })})
#'
#' # Static scheduling: 15 Seconds
#' # Preparation: chunk in two:
#' # -- Worker 1: 1, 2, 3
#' # -- Worker 2: 4, 5, 6
#' # 00s => start 1, start 4
#' # 01s => end 1, start 2
#' # 03s => end 2, start 3
#' # 04s => end 4, start 5
#' # 06s => end 3
#' # 09s => end 5, start 6
#' # 15s => end 6
#' system.time({parLapply(cl, eapply(my_env, function(x) {x}), function(x) {
#'   Sys.sleep(x)
#'   return(x)
#' })})
#'
#' stopCluster(cl)
#' closeAllConnections()
#'
#' # More comprehensive example with timeout, requires package R.utils
#'
#' library(LauraeParallel)
#' library(parallel)
#' suppressPackageStartupMessages(library(R.utils))
#'
#' cl <- makeCluster(2)
#'
#' my_fun <- function(x) {
#'   Sys.sleep(x)
#'   return(x)
#' }
#' invisible(clusterEvalQ(cl = cl, expr = {
#'   suppressPackageStartupMessages(library(R.utils))
#' }))
#' clusterExport(cl = cl, "my_fun")
#' 
#' my_env_fast <- new.env()
#' for (i in 1:6) {
#'   my_env_fast[[as.character(i)]] <- i * 0.1
#' }
#'
#' system.time({data <- LauraeEapply(cl, my_env_fast, function(x) {my_fun(x)})})
#' data
#'
#' # Anything after 0.3 sec of run time or 100 sec of CPU time gets trashed
#' system.time({data <- LauraeEapply(cl, my_env_fast, function(x) {
#'   err <- try(R.utils::withTimeout(my_fun(x), timeout = 100, elapsed = 0.3, onTimeout = "error"))
#'   if (class(err) == "try-error") {
#'     return("ERROR")
#'   } else {
#'     return(err)
#'   }
#' })})
#' data
#'
#' # Anything after 0.3 sec of run time or 0.3 sec of CPU time or 100 sec of run time gets trashed
#' system.time({data <- LauraeEapply(cl, my_env_fast, function(x) {
#'   err <- try(R.utils::withTimeout(my_fun(x), timeout = 100, cpu = 0.3, onTimeout = "error"))
#'   if (class(err) == "try-error") {
#'     return("ERROR")
#'   } else {
#'     return(err)
#'   }
#' })})
#' data
#'
#' stopCluster(cl)
#' closeAllConnections()
#'
#' @rdname LauraeEapply
#'
#' @export

LauraeEapply <- function(cl, x, fun, ...) {
  return(LauraeParallel::LauraeLapply(cl = cl, x = eapply(x, function(x) {x}), fun = fun, ...))
}
