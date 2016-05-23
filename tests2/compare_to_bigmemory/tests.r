library(bigmemory)

?bigmemory

unlink('E:/big8bm.bmat');
unlink('E:/big8bm.info');

z = filebacked.big.matrix(1e5,1e5, 'double', backingfile = 'big8bm.bmat',
								  backingpath = 'E:/', descriptorfile = 'big8bm.info')

tic = proc.time()
for( i in 1:ncol(z) ) {
	z[,i] = i + 1:nrow(z);
}
flush(z);
toc = proc.time()

show(toc-tic)
rm(z);gc();


# user  system elapsed 
# 357.19   68.90 1330.52 
# 


# library(bigmemory)

z = fm.create('E:/big8f',1e5,1e5)

tic = proc.time()
for( i in 1:ncol(z) ) {
	z[,i] = i + 1:nrow(z);
}
# flush(z);
close(z)
toc = proc.time()

show(toc-tic)

# user  system elapsed 
# 237.22   88.60  632.43 




z = fm.create('D:/big4f',1e5,1e5, size = 4)

tic = proc.time()
for( i in 1:ncol(z) ) {
	z[,i] = i + 1:nrow(z);
}
# flush(z);
close(z)
toc = proc.time()

show(toc-tic)

# user  system elapsed 
# 354.78   82.36  439.11 
# 313.53   77.64  392.74 

z = fm.create('D:/big4i',1e5,1e5, type = 'integer')

tic = proc.time()
for( i in 1:ncol(z) ) {
	z[,i] = i + (1:nrow(z));
	
	# z$writeCols(i, i + (1:nrow(z)))
}
# flush(z);
close(z)
toc = proc.time()

show(toc-tic)
# user  system elapsed 
# 112.88   36.38  288.82 

a = 1L+(1:100000);
is.vector(a);
dim(a) = c(length(a),1);
is.vector(a);
z$writeCols(1, matrix(1:(nrow(z)*2),ncol = 2))



