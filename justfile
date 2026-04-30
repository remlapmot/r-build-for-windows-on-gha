test logfile="results.log":
  Rscript tests/blas-benchmark.R 2>&1 | tee tests/{{ logfile }}
