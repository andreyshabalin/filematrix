suppressPackageStartupMessages(library(filematrix))

fm = fm.create('E:/huge', nrow = 10000000, ncol = 100)
fm[nrow(fm),ncol(fm)] = 1;
close(fm)
