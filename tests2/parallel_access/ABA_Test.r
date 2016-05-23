library(filematrix)

fm = fm.open('E:/huge', readonly = TRUE)


cat('testing','\n');
for( i in 1:ncol(fm) ) {
	err = sum(fm[,i]==0);
	if(err > 0)
		cat( i, err, '\n');
}
cat('done','\n');
close(fm)
