library(methods);

### split set of numbers into increasing sequences

# Example
# .index.splitter(c(1,2,3, 3,4,5, -3,-2,-1))
# Returns:
# 
# $start - first value in each sequence,      1 3 -3
# $len - length of each sequence,             3 3 3
# $ix - start position in the input sequence, 1 4 7 10 
# $n - number of sequences,                   3

.index.splitter = function(i) {
	parts = which(c(TRUE, diff(i)!=1,TRUE));
	ind = list( start = i[parts[1:(length(parts)-1)]], len = diff(parts), ix = parts, n = length(parts)-1);
	return(ind);
}

### Exclusive lock on a file
### Used to prevent simultaneous read/write requests to
### the same hard drive.

.file.lock = function(fname = NULL, timeout = 3600000) {
	if (!requireNamespace("RSQLite", quietly = TRUE)) {
		stop("RSQLite needed for file lock to work. Please install it.", call. = FALSE)
	}
	if(is.character(fname)) {
		# library(RSQLite)
		con <- RSQLite::dbConnect(RSQLite::SQLite(), dbname = fname)
		RSQLite::dbGetQuery(con, paste0('PRAGMA busy_timeout = ', timeout));
		lock = function() {
			RSQLite::dbGetQuery(con, 'BEGIN IMMEDIATE TRANSACTION')
		}
		unlock = function() {
			RSQLite::dbGetQuery(con, 'COMMIT TRANSACTION')
		}
		lockedrun = function(expr) {
			on.exit(unlock())
			lock();
			expr
		}
		close = function(){
			RSQLite::dbDisconnect(con);
		}
		return( list(lock=lock, unlock=unlock, lockedrun = lockedrun, close = close ) );
	} else {
		return( list(lock=function(){}, unlock=function(){}, lockedrun = identity, close = function(){}) );
	}
}

### Reference class for the filematrix
setRefClass("filematrix",
	fields = list( 
		fid = "list",                # list with file handle for the binary data file
		nr = "numeric",              # number of rows, access via nrow(fm) and dim(fm)
		nc = "numeric",              # number of columns, access via ncol(fm) and dim(fm)
		type = "character",          # type of values in the matrix (double,integer,logical,raw)
		size = "integer",            # size of each matrix value in the file (1,2,4,8)
		caster = "function",         # function transforming data into the matrix data type
		info.filename = "character", # file name for file matrix description
		data.filename = "character", # file name for file matrix data
		rnames = "character",        # row names, access via rownames(fm)
		cnames = "character",        # column names, access via colnames(fm)
		rnamefile = "character",     # file with row names
		cnamefile = "character",     # file with column names
		filelock = "list"            # file lock mechanism ($lock, $unlock)
	),
	methods = list(
		# Initialize all variables in the class. Called automatically upon creation.
		initialize = function() {
			.self$fid = list();
			.self$nr = 0L;
			.self$nc = 1L;
			.self$type = "double";
			.self$size = 8L;
			.self$setCaster();
			.self$info.filename = "";
			.self$data.filename = "";
			.self$rnames = character();
			.self$cnames = character();
			.self$rnamefile = "";
			.self$cnamefile = "";
			.self$filelock = .file.lock();
		},
		# Set the caster function forcing input to the "type"
		setCaster = function() {
			.self$caster = switch(type,
										 double = function(x){ if(typeof(x) == "double"){return(as.vector(x))} else {return(as.double(x))}},
										 integer =  function(x){ if(typeof(x) == "integer"){return(as.vector(x))} else {return(as.integer(x))}},
										 logical = function(x){ if(typeof(x) == "logical"){return(as.vector(x))} else {return(as.logical(x))}},
										 raw = function(x){ if(typeof(x) == "raw"){return(as.vector(x))} else {return(as.raw(x))}},
										 stop("Unknown data type: ",type));
		},
		# Is filematrix connected to any file?
		isOpen = function() {
			return( length(.self$fid)>0 );
		},
		# Close the file matrix object. Access via close(fm)
		close = function() {
			if( isOpen() ) {
				# filelock$lockedrun({
					base::close.connection( .self$fid[[1]] );
				# });
				.self$fid = list();
				.self$filelock$close();
			} else {
				warning("Inactive filematrix object.");
			}
			initialize();
		},
		# This method is called when the object is being printed.
		show = function() {
			if( isOpen() ) {
				cat(sprintf("%0.f x %0.f filematrix with %d byte '%s' elements",nr,nc,size,type),"\n");
			} else {
				cat("Inactive filematrix object","\n");
			}
		},
		# methods for reading from and writing to the descriptor file "info.filename"
		loadInfo = function() {
			info = readLines( .self$info.filename );
			keep = grep(x = info, pattern = "=", fixed = TRUE);
			info = info[keep];
			ss = strsplit(info, split = "=");
			lst = lapply(ss, "[[", 2);
			names(lst) = sapply(ss, "[[", 1);
			
			if( !all(c("ncol","nrow","size","type") %in% names(lst)) )
				stop(paste0('Malformed filematrix info file: ',.self$info.filename));
			.self$nr = round(as.numeric(lst$nrow));
			.self$nc = round(as.numeric(lst$ncol));
			.self$size = as.integer(lst$size);
			.self$type = lst$type;
			if(!(type %in% c("double","integer","logical","raw"))) {
				stop("\"type\" must be either \"double\",\"integer\",\"logical\", or \"raw\"");
			}
			.self$setCaster();
		},
		saveInfo = function() {
			writeLines(con=.self$info.filename, text=paste0(
				"# Information file for R filematrix object","\n",
				"nrow=", .self$nr,   "\n",
				"ncol=", .self$nc,   "\n",
				"type=", .self$type, "\n",
				"size=", .self$size, "\n"));
		},
		# Get and set dimension names. Access via rownames(fm), colnames(fm), and dimnames(fm).
		getrownames = function() {
			if( length(rnames) > 0 ) {
				rn = rnames;
			} else {
				if(file.exists(rnamefile)) {
					rn = readLines(rnamefile);
					.self$rnames = rn;
				} else {
					rn = NULL;
				}
			}
			return(rn);
		},
		getcolnames = function() {
			if( length(cnames) > 0 ) {
				cn = cnames;
			} else {
				if(file.exists(cnamefile)) {
					cn = readLines(cnamefile);
					.self$cnames = cn;
				} else {
					cn = NULL;
				}
			}
			return(cn);
		},
		getdimnames = function() {
			return(list(getrownames(),getcolnames()));
		},
		setrownames = function(rn) {
			if(length(rn)>0) {
				.self$rnames = rn;
				writeLines( con = rnamefile, text = rnames);
			} else {
				if(file.exists(rnamefile))
					file.remove(rnamefile);
				.self$rnames = character();
			}
			return(invisible(.self));
		},
		setcolnames = function(cn) {
			if(length(cn)>0) {
				.self$cnames = cn;
				writeLines( con = cnamefile, text = cnames);
			} else {
				if(file.exists(cnamefile))
					file.remove(cnamefile);
				.self$cnames = character();
			}
			return(invisible(.self));
		},
		setdimnames = function(nms) {
			if(is.list(nms)) {
				setrownames(nms[[1]]);
				setcolnames(nms[[2]]);
			}
			return(invisible(.self));
		},
		# Delete files
		closeAndDeleteFiles = function() {
			if(!isOpen())
				stop('Filematrix not open, cannot close and delete');

			.self$setcolnames(cn = NULL);
			.self$setrownames(rn = NULL);
			
			file1 = .self$info.filename;
			file2 = .self$data.filename;
			.self$close();
			file.remove(file1);
			file.remove(file2);
			return(invisible(.self));
		},
		# File creation functions
		create = function(filenamebase, nrow = 0, ncol = 1, type = "double", size = NULL, lockfile = NULL) {
			
			filenamebase = gsub(pattern = "\\.desc\\.txt$", replacement = "", x = filenamebase);
			filenamebase = gsub(pattern = "\\.bmat$",       replacement = "", x = filenamebase);
			filenamebase = normalizePath(path = filenamebase, mustWork = FALSE);
			.self$rnamefile =     paste0(filenamebase, ".nmsrow.txt");
			.self$cnamefile =     paste0(filenamebase, ".nmscol.txt");
			.self$info.filename = paste0(filenamebase, ".desc.txt");
			.self$data.filename = paste0(filenamebase, ".bmat");
			.self$filelock = .file.lock(lockfile);

			if( !(type %in% c("double","integer","logical","raw")) ) {
				stop("Data type must be either \"double\",\"integer\",\"logical\", or \"raw\"");
			}
			if(is.null(size)) {
				.self$size = switch(type,
					double = 8L,
					integer = 4L,
					logical = 1L,
					raw = 1L,
					stop("Unknown data type: ",type));
			} else {
				.self$size = as.integer(size);
			}
			
			.self$nc = round(as.double(ncol));
			.self$nr = round(as.double(nrow));
			.self$type = type;
			.self$setCaster();
			
			.self$saveInfo();
			
			filelock$lockedrun({
				fd = file(description = .self$data.filename, open = "w+b");
			});
			.self$fid = list(fd);
			if( nr*nc>0 )
				writeSeq(nr*nc, 0);
		},
		open = function(filenamebase, readonly = FALSE, lockfile = NULL) {
			
			filenamebase = gsub(pattern = "\\.desc\\.txt$", replacement = "", x = filenamebase);
			filenamebase = gsub(pattern = "\\.bmat$",       replacement = "", x = filenamebase);
			filenamebase = normalizePath(path = filenamebase, mustWork = FALSE);
			.self$rnamefile =     paste0(filenamebase, ".nmsrow.txt");
			.self$cnamefile =     paste0(filenamebase, ".nmscol.txt");
			.self$info.filename = paste0(filenamebase, ".desc.txt");
			.self$data.filename = paste0(filenamebase, ".bmat");
			.self$filelock = .file.lock(lockfile);
			
			loadInfo();

			# stopifnot( file.info(data.file.name)$size == nr*nc*size );
			# stopifnot( file.info(data.file.name)$size >= nr*nc*size );
			filelock$lockedrun({
				fd = file(description = .self$data.filename, open = if(readonly){"rb"}else{"r+b"});
			});

			.self$fid = list(fd);
		},
		createFromMatrix = function(filenamebase, mat, size = NULL, lockfile = NULL) {
			# mat = as.matrix(mat);
			create(filenamebase=filenamebase, nrow=NROW(mat), ncol=NCOL(mat), type=typeof(mat), size=size, lockfile=lockfile);
			setdimnames(dimnames(mat));
			writeAll(mat);
			return(invisible(.self));
		},
		# Data access routines. 
		# More conveniently accessed via fm[] interfacee.
		# Arguments are assumed to be round (integers, possibly > 2^32).
		# No check if the object is closed.
		# Both are checked in fm[] interface.

		# fm[start:(start+len-1)]
		readSeq = function(start, len) {
			stopifnot( start>=1 );
			stopifnot( start+len-1 <= nr*nc );
			# filelock$lockedrun({
				seek(con = fid[[1]], where = (start-1)*size, rw = "read");
			# });
			# Reading data of non-naitive size is slow in R. (Why?)
			# This is solved by reading RAW data and using readBin on memory vector.
			# Reading long vectors is currently supported (as of R 3.2.2).
			# Thus currently exclude condition: ( len*as.numeric(size) >= 2^31)
			if( ((size!=8)&&(type=='double')) || ((size!=4)&&(type=='integer')) ) {
				filelock$lockedrun({
					tmp = readBin(con = fid[[1]], n = len*size, what = 'raw');
				});
				return(
					readBin(con = tmp,         n = len, what = type, size = size, endian = 'little')
				);
			} else {
				return( 
					filelock$lockedrun({
						readBin(con = fid[[1]], n = len, what = type, size = size, endian = "little");
					})
				);
			}
		},
		# fm[start:(start+length(value)-1)] = value
		writeSeq = function(start, value) {
			stopifnot( start >= 1L );
			stopifnot( start+length(value)-1 <= nr*nc );
			# filelock$lockedrun({
				seek(con = fid[[1]], where = (start-1L)*size, rw = "write");
			# });
			
			# Writing data of non-naitive size is slow in R. (Why?)
			# This is solved by writing RAW data after using writeBin to convert it into memory vector.
			if( ((size!=8)&&(type=='double')) || ((size!=4)&&(type=='integer')) ) {
				addwrite = function(value) {
					tmp = writeBin(con = raw(), object = caster(value), size = size, endian = "little");
					filelock$lockedrun({
						writeBin(con = fid[[1]], object = tmp);
					});
				}
			} else {
				addwrite = function(value) {
					filelock$lockedrun({
						writeBin(con = fid[[1]], object = caster(value), size = size, endian = "little");
					});
				}
			}
			
			# Writing long vectors is currently NOT supported (as of R 3.2.2, 3.3.0).
			# Thus write in pieces of 128 MB or less.
			if(length(value)*as.numeric(size) < 134217728) {
				addwrite(value);
			} else {
				step1 = 134217728 %/% size;
				mm = length(value);
				nsteps = ceiling(mm/step1);
				for( part in 1:nsteps ) { # part = 1
					# cat( part, 'of', nsteps, '\n');
					fr = (part-1)*step1 + 1;
					to = min(part*step1, mm);
					
					addwrite(value[fr:to]);
				}
				rm(part, step1, mm, nsteps, fr, to);
			}
			# Instead of flush:
			filelock$lockedrun({
				seek(con = fid[[1]], where = 0, rw = "write");
			});
			return(invisible(.self));
		},
		# fm[,start:(start+num-1)]
		readCols = function(start, num) {
			rez = readSeq( (start-1)*nr+1, num*nr );
			# Do not make a vector into a matrix
			# Avoid errors caused by nrow >= 2^31 or ncol >= 2^31
			# as such matrices are not supported
			# excluded: (num > 1) && (nr > 1) && 
			if((nr < 2^31) && (num < 2^31))
				dim(rez) = c(nr, num);
			return(rez);
		},
		# fm[,start:(start+ncol(value)-1)] = value
		writeCols = function(start, value) {
			stopifnot( (length(value)%%nr)==0 );
			writeSeq( (start-1)*nr+1, value);
			return(invisible(.self));
		},
		# fm[i, j:(j+num-1)]
		readSubCol = function(i, j, num) {
			stopifnot( i>=1  );
			stopifnot( j>=1  );
			stopifnot( i<=nr );
			stopifnot( j<=nc );
			stopifnot( i + num - 1 <= nr );
			rez = readSeq( (j-1)*nr+i, num);
			return(rez);
		},
		# fm[i, j:(j+length(value)-1)] = value
		writeSubCol = function(i, j, value) {
			stopifnot( i>=1  );
			stopifnot( j>=1  );
			# stopifnot( i<=nr ); # Redundant
			stopifnot( j<=nc );
			stopifnot( i + length(value) - 1 <= nr );
			writeSeq( (j-1)*nr+i, value);
			return(invisible(.self));
		},
		# fm[]
		readAll = function() {
			return(readCols(1, nc));
		},
		# fm[] = value
		writeAll = function(value) {
			stopifnot( length(value) == nr*nc );
			writeSeq(1, value);
			return(invisible(.self));
		},
		# Append column(s) by expanding the file
		appendColumns = function(mat) {
			if(.self$nr == 0)	{
				.self$nr = NROW(mat);
			}
			stopifnot( (length(mat) %% nr) == 0 );
			naddcols = length(mat) %/% nr;
			oldncols = .self$nc;
			.self$nc = oldncols + naddcols;
			.self$saveInfo();
			writeCols(oldncols+1, mat);
			return(invisible(.self));
		}
	)
)

### Accessing as a usual R matrix 

### Reading via vector or matrix interface.
"[.filematrix" = function(x, i, j) {
	# Basic checks
	if( !x$isOpen() )
		stop( "File matrix is not active");
	if( !missing(i) )
		if( is.double(i) )
			i = floor(i);
	if( !missing(j) )
		if( is.double(j) )
			j = floor(j);
	
	### full matrix access
	if( missing(i) & missing(j) ) {
		return( x$readAll() );
	}
	
	
	### vector access
	if(nargs()==2 & !missing(i)) {
		### checks and logical access
		if( is.logical(i) ) {
			stopifnot( length(i) == x$nr*x$nc );
			i = which(i);
		} else {
			stopifnot( min(i) >= 1 );
			stopifnot( max(i) <= x$nr*x$nc );
		}
		
		ind = .index.splitter(i);
		if(ind$n == 1) {
			return(x$readSeq(ind$start, ind$len));
		}
		rez = vector(x$type, length(i));
		for(a in 1:ind$n) {
			rez[ ind$ix[a]:(ind$ix[a+1]-1) ] =
				x$readSeq(ind$start[a], ind$len[a]);
		}
		return(rez);
	}

	### checks and logical access
	if(!missing(j)) {
		if( is.logical(j) ) {
			stopifnot( length(j) == x$nc );
			j = which(j);
		} else {
			stopifnot( min(j) >= 1 );
			stopifnot( max(j) <= x$nc );
		}
	}
	if(!missing(i)) {
		if( is.logical(i) ) {
			stopifnot( length(i) == x$nr );
			i = which(i);
		} else {
			stopifnot( min(i) >= 1 );
			stopifnot( max(i) <= x$nr );
		}
	}
	
	### column access
	if( missing(i) & !missing(j) ) {
		ind = .index.splitter(j);
		if(ind$n == 1) {
			return(x$readCols(ind$start, ind$len));
		}
		rez = vector(x$type, length(j)*x$nr);
		dim(rez) = c(x$nr, length(j));
		for(a in 1:ind$n) {
			rez[, ind$ix[a]:(ind$ix[a+1]-1) ] = 
					x$readCols(ind$start[a], ind$len[a]);
		}
		return(rez);			
	}
	
	### row access via full access
	if( !missing(i) & missing(j) ) {
				j = 1:x$nc;
	}
	
	### full access
	if( !missing(i) ) {
		rez = vector(x$type, as.double(length(j)) * length(i));
		dim(rez) = c(length(i), length(j));
		if(all(diff(i)==1L)) {
			for(a in seq_along(j)) {
				rez[,a] = x$readSubCol(i[1], j[a], length(i));
			}
			return(rez);	
		} else {
			low = min(i);
			len = max(i) - low + 1;
			inew = i+(1-low);
			for(a in seq_along(j)) {
				vec = x$readSubCol(low, j[a], len);
				rez[,a] = vec[inew];
			}
			return(rez);
		}
	}
	stop("What123??");
}

### Writing via vector or matrix interface.
"[<-.filematrix" = function(x, i, j, value) {
	# Basic checks
	if( !x$isOpen() )
		stop( "File matrix is not open");
	if( !missing(i) )
		if( is.double(i) )
			i = floor(i);
	if( !missing(j) )
		if( is.double(j) )
			j = floor(j);
	
	### full matrix access
	if( missing(i) & missing(j) ) {
		stopifnot(length(value) == x$nr*x$nc);
		x$writeAll(value);
		return(x);
	}

	### vector access
	if(nargs()==3 & !missing(i)) {
		### checks and logical access
		if( is.logical(i) ) {
			stopifnot( length(i) == x$nr*x$nc );
		 	i = which(i);
		} else {
			stopifnot( min(i) >= 1 );
			stopifnot( max(i) <= x$nr*x$nc );
		}
		stopifnot( length(i) == length(value) );
		ind = .index.splitter(i);
		if(ind$n == 1) {
			x$writeSeq(ind$start, value);
			return(x);
		}
		for(a in 1:ind$n) {
			x$writeSeq(ind$start[a], value[ind$ix[a]:(ind$ix[a+1]-1)]);
		}
		return(x);
	}
	
	### checks and logical access
	if(!missing(j)) {
		if( is.logical(j) ) {
			stopifnot( length(j) == x$nc );
			j = which(j);
		} else {
			stopifnot( min(j) >= 1 );
			stopifnot( max(j) <= x$nc );
		}
	}
	if(!missing(i)) {
		if( is.logical(i) ) {
			stopifnot( length(i) == x$nr );
			i = which(i);
		} else {
			stopifnot( min(i) >= 1 );
			stopifnot( max(i) <= x$nr );
		}
	}	
	
	### column access
	if( missing(i) & !missing(j) ) {
		stopifnot( length(j)*x$nr == length(value) );
		ind = .index.splitter(j);
		if(ind$n == 1) {
			x$writeCols(ind$start, value);
			return(x);
		}
		dim(value) = c(x$nr, length(j));
		for(a in 1:ind$n) {
			x$writeCols(ind$start[a], value[,ind$ix[a]:(ind$ix[a+1]-1)]);
		}
		return(x);	
	}
	
	### row access via full access
	if( !missing(i) & missing(j) ) {
		j = 1:x$nc;
	}
	
	### full access
	if( !missing(i) ) {
		# stopifnot( all(diff(i)==1L) );
		stopifnot( length(i)*length(j) == length(value) );
		dim(value) = c(length(i),length(j));
		
		ind = .index.splitter(i);
		for(aj in seq_along(j)) { # a = 1
			for(ai in 1:ind$n) {
				x$writeSubCol(ind$start[ai], j[aj], value[ind$ix[ai]:(ind$ix[ai+1]-1),aj]);
			}
			# x$writeSubCol(i[1], j[a], value[,a]);
		}
		return(x);	
	}
	
	stop("What??");
}

### Creators of filematrix objects

# Create new, erase if exists
fm.create = function(filenamebase, nrow = 0, ncol = 1, type = "double", size = NULL, lockfile = NULL){
	rez = new("filematrix");
	rez$create(filenamebase = filenamebase, nrow = nrow, ncol = ncol, type = type, size = size, lockfile = lockfile);
	return(rez);
}

# From existing matrix
fm.create.from.matrix = function(filenamebase, mat, size = NULL, lockfile = NULL) {
	rez = new("filematrix");
	rez$createFromMatrix(filenamebase = filenamebase, mat = mat, size = size, lockfile = lockfile);
	return(rez);
}

# Open existing file matrix
fm.open = function(filenamebase, readonly = FALSE, lockfile = NULL) {
	rez = new("filematrix");
	rez$open(filenamebase = filenamebase, readonly = readonly, lockfile = lockfile);
	return(rez);
}

# Open and read the the whole matrix in memory.
fm.load = function(filenamebase, lockfile = NULL) {
	fm = fm.open(filenamebase = filenamebase, readonly = TRUE, lockfile = lockfile);
	mat = as.matrix(fm);
	if( is.matrix(mat) )
		dimnames(mat) = dimnames(fm);
	fm$close();
	return(mat);
}

# Create from a text file matrix
fm.create.from.text.file = function(textfilename, filenamebase, skipRows = 1, skipColumns = 1, sliceSize = 1000, omitCharacters = "NA", delimiter = "\t", rowNamesColumn = 1, type="double", size = NULL) {

	s = function(x)formatC(x=x, digits=ceiling(log10(max(x)+1)), big.mark=",", big.interval=3);

	stopifnot( (skipColumns == 0) || (rowNamesColumn <= skipColumns) )
	stopifnot( (skipColumns == 0) || (rowNamesColumn >= 1) )

	fid = file(description = textfilename, open = "rt", blocking = FALSE, raw = FALSE)
	
	# clean object if file is open

	fm = fm.create(filenamebase, nrow = 1, ncol = 1, type = type, size = size);
	dim(fm) = c(0,0);
	
	lines = readLines(con = fid, n = max(skipRows,1L), ok = TRUE, warn = TRUE)
	line1 = tail(lines,1L);
	splt = strsplit(line1, split = delimiter, fixed = TRUE);
	if( skipRows > 0L ) {
		tempcolnames = splt[[1]]; # [ -(1:fileSkipColumns) ];
	} else {
		seek(fid, 0);
	}		
	
	rm( lines, line1, splt );
	
	rowNameSlices = vector("list", 15);

	curSliceId = 0L;
	repeat
	{
		# preallocate data
		curSliceId = curSliceId + 1L;
		if(length(rowNameSlices) < curSliceId) {
			rowNameSlices[[2L*curSliceId]] = NULL;
		}
		
		# read sliceSize rows
		rowtag = character(sliceSize);
		rowvals = vector("list",sliceSize);
		for(i in 1:sliceSize) {
			if( skipColumns > 0L ) {
				temp = scan(file = fid, what = character(), n = skipColumns, quiet = TRUE,sep = delimiter);
			} else {
				temp = "";
			}

			rowtag[i] = temp[rowNamesColumn];#paste(temp,collapse=" ");
			rowvals[[i]] = scan(file = fid, what = double(), nlines = 1, quiet = TRUE, sep = delimiter, na.strings = omitCharacters);
			
			if( length(rowvals[[i]]) == 0L ) {
				if(i==1L) {
					rowtag = matrix(0, 0, 0);
					rowvals = character(0);
				} else 	{
					rowtag  = rowtag[  1:(i-1) ];
					rowvals = rowvals[ 1:(i-1) ];
				}
				break;			
			}
		}
		if( length(rowtag) == 0L ) {
			curSliceId = curSliceId - 1L;
			break;
		}
		rowNameSlices[[curSliceId]] = rowtag;
		data = c(rowvals, recursive = TRUE);
		dim(data) = c(length(rowvals[[1]]), length(rowvals));
# 		data = t(data);
		fm$appendColumns(data);

		if( length(rowtag) < sliceSize ) {
			break;
		}
		cat( "Rows read: ", s(ncol(fm)), "\n");
		flush.console()
	}
	close(fid);
	if( skipRows == 0 ) {
		rownames(fm) = paste0("Col_", 1:nrow(fm));
	} else {
		rownames(fm) = tail(tempcolnames, nrow(fm));
	}
	if( skipColumns == 0 ) {
		colnames(fm) = paste0("Row_", 1:ncol(fm));
	} else {
		colnames(fm) = unlist(rowNameSlices);
	}
	cat("Rows read: ", ncol(fm), " done.\n");
	return(fm);
}


### Common interface methods

setGeneric("close")#, def = function(con){standardGeneric("close")})
setMethod("close", signature(con="filematrix"), function(con) con$close());

setGeneric("as.matrix")
setMethod("as.matrix",  signature(x="filematrix"), function(x) x$readAll());

setGeneric("dim");
setMethod("dim",        signature(x="filematrix"), function(x) c(x$nr, x$nc));
# dim.filematrix = function(x) as.integer(c(x$nr, x$nc));

# setGeneric("dim<-",def = function(x,value){standardGeneric("dim<-")});
setMethod("dim<-",      signature(x="filematrix", value = "ANY"),	function(x, value) {
		x$nr = value[1];
		x$nc = value[2];
		x$saveInfo();
		return( x );
	}
);

setGeneric("length");
setMethod("length",     signature(x="filematrix"),	function(x) x$nr*x$nc);

setGeneric("dimnames");
setMethod("dimnames",   signature(x="filematrix"),	function(x) x$getdimnames());

setGeneric("dimnames<-");
setMethod("dimnames<-", signature(x="filematrix", value = "ANY"), function(x, value) x$setdimnames(value));

setGeneric("rownames");
setMethod("rownames",   signature(x="filematrix"),	function(x) x$getrownames());

setGeneric("rownames<-");
setMethod("rownames<-", signature(x="filematrix", value = "ANY"), function(x, value) x$setrownames(value));

setGeneric("colnames");
setMethod("colnames",   signature(x="filematrix"),	function(x) x$getcolnames());

setGeneric("colnames<-");
setMethod("colnames<-", signature(x="filematrix", value = "ANY"), function(x, value) x$setcolnames(value));

closeAndDeleteFiles = function(con){ con$closeAndDeleteFiles() };



