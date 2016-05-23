# arg = c('start=1','step=8')
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


suppressPackageStartupMessages(library(filematrix))

# fm = fm.open('E:/huge', lockfile = 'E:/lock')
fm = fm.open('E:/huge')
for( ccc in seq(start, ncol(fm), by = step) ) {
	cat(ccc,'\n');
	fm[,ccc] = rep(ccc, nrow(fm));
}
close(fm);


if(FALSE) {
	step = 8;
	setwd('C:/AllWorkFiles/Andrey/R/git/filematrix/performance_tests/parallel_access/');
	commandfile = 'AAB_par_write.bat'
	content = paste0('start "',1:step,'" /min "C:\\Program Files\\RRO\\R-3.2.2\\bin\\x64\\Rscript.exe" AAB_par_write.r start=',1:step,' step=',step);
	writeLines(con = commandfile, text = content);
}
