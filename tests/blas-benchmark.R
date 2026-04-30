# blas-benchmark.R
# Run with: Rscript.exe blas-benchmark.R

cat("==== BLAS / LAPACK configuration ====\n")
si <- sessionInfo()
cat("R version:        ", R.version.string, "\n")
cat("Platform:         ", R.version$platform, "\n")
cat("BLAS:             ",
    if (!is.null(si$BLAS) && nzchar(si$BLAS)) si$BLAS
    else extSoftVersion()[["BLAS"]], "\n")
cat("LAPACK:           ",
    if (!is.null(si$LAPACK) && nzchar(si$LAPACK)) si$LAPACK
    else extSoftVersion()[["LAPACK"]], "\n")
cat("LAPACK version:   ", La_version(), "\n")
cat("Logical CPUs:     ", parallel::detectCores(logical = TRUE), "\n")
cat("Physical cores:   ", parallel::detectCores(logical = FALSE), "\n")
for (v in c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS",
            "MKL_NUM_THREADS", "BLIS_NUM_THREADS",
            "R_HOME", "R_ARCH")) {
  cat(sprintf("%-22s %s\n", paste0(v, ":"), Sys.getenv(v, "<unset>")))
}
cat("\n")

set.seed(1)

bench <- function(label, expr, reps = 3) {
  expr <- substitute(expr)
  times <- numeric(reps)
  for (i in seq_len(reps)) {
    gc(verbose = FALSE)
    times[i] <- system.time(eval(expr, envir = parent.frame()))[["elapsed"]]
  }
  cat(sprintf("%-32s  best=%7.3fs  median=%7.3fs  (n=%d)\n",
              label, min(times), median(times), reps))
  invisible(times)
}

n_gemm   <- 3000
n_chol   <- 3000
n_solve  <- 3000
n_svd    <- 1500
n_eigen  <- 1500

cat("==== Building test matrices ====\n")
t0 <- proc.time()[["elapsed"]]
A <- matrix(rnorm(n_gemm * n_gemm), n_gemm, n_gemm)
B <- matrix(rnorm(n_gemm * n_gemm), n_gemm, n_gemm)
S <- crossprod(matrix(rnorm(n_chol * n_chol), n_chol, n_chol)) + diag(n_chol)
b <- rnorm(n_solve)
M <- matrix(rnorm(n_svd * n_svd), n_svd, n_svd)
Sym <- (function(x) (x + t(x)) / 2)(matrix(rnorm(n_eigen * n_eigen),
                                           n_eigen, n_eigen))
cat(sprintf("Setup time: %.2fs\n\n", proc.time()[["elapsed"]] - t0))

cat("==== Benchmarks ====\n")
bench(sprintf("DGEMM   %d x %d",  n_gemm, n_gemm),  A %*% B)
bench(sprintf("crossprod %d",     n_gemm),          crossprod(A))
bench(sprintf("Cholesky %d",      n_chol),          chol(S))
bench(sprintf("solve(S, b) %d",   n_solve),         solve(S, b))
bench(sprintf("solve(S)    %d",   n_solve),         solve(S))
bench(sprintf("SVD      %d",      n_svd),           svd(M))
bench(sprintf("sym eigen %d",     n_eigen),         eigen(Sym, symmetric = TRUE))

cat("\nDone.\n")
