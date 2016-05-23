#! /gpfs_fs/pharm/tools/R-3.2.5_BLAS/bin/R

### cluster filematrix check
# install.packages('C:/AllWorkFiles/Andrey/R/git/filematrix_1.1.zip', repos = NULL);

library(filematrix)
library(parallel)

n = 10000;
ncl = 16;


fm = fm.create('Y:/temporary/test', n,n);
close(fm)

# lockfile = tempfile();
lockfile = NULL;


func = function(k, lockfile) { # k=1
	library(filematrix)
	fm = 	fm.open('Y:/temporary/test', lockfile = lockfile);
	fm[,k] = rep(k, ncol(fm));
	close(fm);
	return(k);
}



	{
		tic = proc.time();
		cl <- makeCluster(ncl)
		z = clusterApplyLB(cl, 1:n, func, lockfile=lockfile)
		stopCluster(cl)
		toc = proc.time();
		show(toc-tic);
	}


cat('Unfilled entries:',sum( fm.load('Y:/temporary/test') == 0),'\n' );
