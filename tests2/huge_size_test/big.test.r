# install.packages('bigmemory')

bytes = 1.6e12;
size = 1
nr = floor(sqrt(bytes/size))

z = fm.create( 'E:/huge',nr,nr,type = 'raw', size = size)

for( i in 1:100000 ) {
	cat(i,'\n');
	z[i:(i+4),i] = c(13,10,48,49,50);
}
	
z[nrow(z), ncol(z)] = 1;

close(z)


fm = fm.open( 'E:/huge' );


# 

fm = fm.create('D:/testT', ncol = 40e3, nrow = 40e3, type = 'double');

mat = matrix(1:(40e3^2),40e3,40e3);
fm = fm.create.from.matrix('D:/test4i', mat, 4);
fm = fm.create.from.matrix('D:/test8i', mat, 8);
storage.mode(mat) = 'double'
fm = fm.create.from.matrix('D:/test4d', mat, 4);
fm = fm.create.from.matrix('D:/test8d', mat, 8);

fm[nrow(fm),ncol(fm)]
fm[nrow(fm)-1,ncol(fm)-1]
fm[nrow(fm),ncol(fm)-1]
close(fm);

library(filematrix)


# fm = file.matrix.create('D:/test', nrow = 2^32+1, ncol = 2,type = 'raw');
# fm = fm.create('D:/testW', nrow = 2, ncol = 2^32+1, type = 'raw');
fm = fm.create('D:/testT', ncol = 2, nrow = 2^32+1, type = 'raw');
fm[1:2,1:2]
fm[1:2,1:2] = 1:4;
fm[nrow(fm),ncol(fm)]
length(fm)
dim(fm)
fm
fm[nrow(fm),ncol(fm)] = 255;

fm[nrow(fm)+(-1:0),ncol(fm)+(-1:0)];
fm[nrow(fm)+(-1:0),ncol(fm)+(-1:0)] = 255:252
fm$appendColumns(c(6,5));
fm[nrow(fm)+(-1:0),ncol(fm)+(-1:0)];
close(fm)

fm = fm.open('D:/test', readonly = FALSE);
fm
z = fm[,ncol(fm)];
fm$appendColumns(z);


dim(fm)
dim(fm) = rev(dim(fm))

nrow(fm)
nrow(fm) = 2

rownames(fm) = NULL
fm[nrow(fm),ncol(fm)]
close(fm)

z = readBin('D:/test.bmat',what = 'integer', n = 8e9/2);
writeBin(con = 'D:/test2',object = z);


fm = fm.create.from.text.file(filename = 'D:/Kai/mdata_big_sets.txt', filenamebase = 'D:/Kai/fm2/mdata', delimiter = '\t', sliceSize = 100, type = 'integer', size = 2);
close(fm)

fm = fm.create.from.text.file(filename = 'D:/Kai/edata_big_sets.txt', filenamebase = 'D:/Kai/fm2/edata', delimiter = '\t', sliceSize = 100);
close(fm)

fm = file.matrix.open('D:/test');

z = fm$readCols(1,1);
z = fm[,2];

length(fm)

fm[nrow(fm),ncol(fm)] = 1;
fm[nrow(fm),ncol(fm)]
fm[nrow(fm)-(1:0),ncol(fm)-(5:0)] 
# = 10:1


file.matrix.add.columns(fm, matrix(1:4,2,2));


z = fm[,ncol(fm)];

set = floor((seq(1,length(fm), length.out = 1e4)));
for( i in  seq_along(set)) {
	cat(i,'\n');
	fm[set[i]] = i;
}



z = raw(2^32+1);
z[] = as.raw(9);
fm[,1] = z;





file.matrix.append.columns = function(fm, mat) {
	oldn = ncol(fm);
	newn = ncol(fm) + ncol(mat);
	if(nrow(fm) == 0)	{
		nrow(fm) = nrow(mat);
	} else {
		stopifnot(nrow(fm) == nrow(mat));
	}
	ncol(fm) = newn;
	fm[,(oldn+1):newn] = mat;
	return(invisible(fm));
}





frname = 'D:/meQTL_10000';
toname = 'E:/RC2/all_cpgs/meQTLs/meQTL_10000_t';

# frname = 'E:/RC2/matched2snps/tr/AS38_t'
# toname = 'D:/AS38'

buffersize = 1e9;



.fm.transpose.horiz2vert = function(fmin, toname, frbuffer = 1e9){
# 	library(filematrix)

# 	fmin = file.matrix.open(frname, readonly = TRUE);
# 	dim(fmin)
	fmtr = file.matrix.create(toname, nrow = ncol(fmin), ncol = nrow(fmin), type = fmin$type, size = fmin$size);

	step1 = max(1, round(frbuffer/(8*nrow(fmin))));
	mm = ncol(fmin);
	nsteps = ceiling(mm/step1);	
	for( part in 1:nsteps ) { # part=1
		cat( part, 'of', nsteps, '\n');
	 	fr = (part-1)*step1 + 1;
	 	to = min(part*step1, mm);
		
		slice = fmin[,fr:to];
		
		for( j in 1:nrow(fmin) ) { # j=1
# 			fmtr[fr:to,j] = slice[j,];
			fmtr$writeSubCol(fr, j, slice[j,]);
		}
		rm(slice);gc();
	}
	rm(part, step1, mm, nsteps, fr, to);
	
 	colnames(fmtr) = rownames(fmin);
 	rownames(fmtr) = colnames(fmin);

	fmtr$close();
# 	fmin$close();
	
# 	dim(fmtr)
}
.fm.transpose.vert2horiz = function(fmin, toname, frbuffer = 1e9, tobuffer = 10e6){

# 	library(filematrix)


# 	fmin = file.matrix.open(frname, readonly = TRUE);
# 	dim(fmin)
	fmtr = file.matrix.create(toname, nrow = ncol(fmin), ncol = nrow(fmin), type = fmin$type, size = fmin$size);
# 	dim(fmtr)
		

	step1 = max(1, round(frbuffer/(8*ncol(fmin))));
	mm = nrow(fmin);
	nsteps = ceiling(mm/step1);
	for( part in 1:nsteps ) { # part=1
		cat( part, 'of', nsteps, '\n');
	 	fr = (part-1)*step1 + 1;
	 	to = min(part*step1, mm);
# 		fmtr[,fr:to] = t(fmin[fr:to,])

# 		my.lock$lock()
		slice = fmin[fr:to,];
# 		my.lock$unlock();

		step1a = max(1, round(tobuffer/(8*ncol(fmin))));
		mma = nrow(slice);
		nstepsa = ceiling(mma/step1a);
		for( parta in 1:nstepsa ) { # parta=1
# 			cat( parta, 'of', nstepsa, '\n');
		 	fra = (parta-1)*step1a + 1;
		 	toa = min(parta*step1a, mma);
			fmtr[,fr-1L+(fra:toa)] = t(slice[fra:toa,]);
		}
		rm(parta, step1a, mma, nstepsa, fra, toa);
		
		rm(slice);gc();
	}
	rm(part, step1, mm, nsteps, fr, to);
	
# 	colnames(fmtr) = rownames(fmin);
# 	rownames(fmtr) = colnames(fmin);

	fmtr$close();
# 	fmin$close();
}
file.matrix.transpose = function(frname,  toname, buffersize = 1e9) {
	library(filematrix)
	fm = file.matrix.open(frname, readonly = TRUE);
	dm = dim(fm);
	
	if( dm[1]<dm[2] ) {
		.fm.transpose.horiz2vert(fm, toname, frbuffer=buffersize);
	} else {
		.fm.transpose.vert2horiz(fm, toname, frbuffer=ceiling(buffersize*0.9375), tobuffer=ceiling(buffersize*0.0625));
	}
	close(fm);
}
	
file.matrix.transpose(frname, toname, buffersize);
	
	
z = matrix(0,25e3,25e3)	
gc();
z[1,1] = 2;
gc();
z[2,2] = 3;
gc();
a = as.double(z)



	