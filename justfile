test logfile="results.log":
  Rscript tests/blas-benchmark.R 2>&1 | tee tests/{{ logfile }}
lclcran:
  "C:\Program Files\R\R-4.6.0\bin\x64\Rscript" tests/blas-benchmark.R 2>&1 | tee tests/results-x86_64-cran-tp-windows.log
lclopb:
  "C:\Program Files\R\R-4.6.0-openblas\bin\x64\Rscript" tests/blas-benchmark.R 2>&1 | tee tests/results-x86_64-openblas-tp-windows.log
