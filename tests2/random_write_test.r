n = 20;
fm = fm.create(filenamebase = 'E:/test', n, n)
mat = matrix(0, n, n);


rownames(fm) = as.character(1:nrow(fm));
colnames(fm) = as.character(1:ncol(fm));

### Fully indexed access

k = 10;
for( test in 1:100 ) {

	cat('Fully indexed access', test,'\n');
	rowset = sample.int(n, size = k);
	colset = sample.int(n, size = k);
	
	value = matrix( runif(length(rowset)*length(colset)), length(rowset), length(colset));
	
	stopifnot( all( fm[rowset, colset] == mat[rowset, colset] ) );

	fm[rowset, colset] = value;
	mat[rowset, colset] = value;
}
stopifnot( all( as.matrix(fm) == mat ) );


### All columns access

k = 10;
for( test in 1:100 ) {
	
	cat('All columns access', test,'\n');
	colset = sample.int(n, size = k);
	
	value = matrix( runif(length(rowset)*n), length(rowset), n);
	
	stopifnot( all( fm[rowset, ] == mat[rowset, ] ) );

	fm[rowset, ] = value;
	mat[rowset, ] = value;
}
stopifnot( all( as.matrix(fm) == mat ) );


### All rows access

k = 10;
for( test in 1:100 ) {
	
	cat('All rows access', test,'\n');
	colset = sample.int(n, size = k);
	
	value = matrix( runif(n*length(colset)), n, length(colset));
	
	stopifnot( all( fm[, colset] == mat[, colset] ) );

	fm[, colset] = value;
	mat[, colset] = value;
}
stopifnot( all( as.matrix(fm) == mat ) );


### Vector access

k = 10;
for( test in 1:100 ) {
	
	cat('Vector access', test,'\n');
	set = sample.int(n^2, size = k^2);
	
	value = runif(k^2);
	
	stopifnot( all( fm[set] == mat[set] ) );
	
	fm[set] = value;
	mat[set] = value;
}
stopifnot( all( as.matrix(fm) == mat ) );

fm$closeAndDeleteFiles();
# 
# 
# a = 1:1e9;
# b = as.vector(a)
