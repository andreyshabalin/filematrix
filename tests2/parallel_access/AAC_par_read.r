{
	if(!exists("arg")) 
		arg=commandArgs(TRUE)
	if (length(arg)==0) {
		print("No arguments supplied") 
	} else {
		for (i in length(arg):1)
			eval(parse(text=arg[[i]]))
		rm(i);
	}
	rm(arg);
}

cat('start',start,'step',step,'\n');

C:\AllWorkFiles\Andrey\R\git\filematrix\performance_tests\parallel_access\
setwd('C:/AllWorkFiles/Andrey/R/git/filematrix/performance_tests/parallel_access/');

suppressPackageStartupMessages(library(filematrix))

tic = proc.time();

# fm = fm.open('E:/huge', lockfile = 'E:/lock', readonly = TRUE)
fm = fm.open('E:/huge', readonly = TRUE)
for( ccc in seq(start, ncol(fm), by = step) ) {
	err = sum(fm[,ccc]==0);
#	if(err > 0)
	cat( ccc, err, '\n');
}
close(fm);

toc = proc.time();

writeLines(con = paste0('logs/read_nolock_',start,'.txt'), text = as.character(toc-tic));
# writeLines(con = paste0('logs/read_lock_',start,'.txt'), text = as.character(toc-tic));

if(FALSE) {
	step = 8;
	setwd('C:/AllWorkFiles/Andrey/R/git/filematrix/performance_tests/parallel_access/');
	commandfile = 'AAC_par_read.bat'
	content = paste0('start "',1:step,'" /min "C:\\Program Files\\RRO\\R-3.2.2\\bin\\x64\\Rscript.exe" AAC_par_read.r start=',1:step,' step=',step);
	writeLines(con = commandfile, text = content);
}
