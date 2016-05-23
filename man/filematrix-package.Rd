\name{filematrix-package}
\alias{filematrix-package}
%\alias{filematrix}
\docType{package}
\title{
 File-backed numeric matrix.
}
\description{
 File-Backed Matrix Class with Convenient Read and Write Access
}
\details{
	\tabular{ll}{
		Package: \tab filematrix \cr
		Type: \tab Package \cr
		Version: \tab 1.1 \cr
		Date: \tab 2016-03-21 \cr
		License: \tab LGPL-3 \cr
		Depends: \tab methods \cr
	}
	
	Interface for working with large matrices from files in data storage, not held in computer memory.
     Supports multiple data types (double, integer, logical and raw) of different sizes (e.g. 4, 2, or 1 byte integers).
     Access to parts of the matrix is done by indexing, exactly as with usual R matrices.
     Supports very large matrices (tested on 1 terabyte matrix), allowing for more than 2^32 rows or columns.
     Cross-platform as a pure R implementation; does not rely on memory mapped files or any explicit C code.
	
	A new \code{file.matrix} object can be created with \code{\link{fm.create}} and \code{\link{fm.create.from.matrix}}. Existing \code{file.matrix} files can be opened with \code{\link{fm.open}}.
	
	Once a \code{file.matrix} is created or opened it can be accessed as a regular \code{\link{matrix}} object in R.
	All changes to \code{file.matrix} object are instantly recorded in the respective files, unless \code{readonly} mode is specified.
}
\note{
Due to lack of 64 bit integer data type in R, the package uses double values for calculation of indices. The precision of double data type is sufficient for indexing matrices up to 8,192 terabytes in size.
}
\author{
	Andrey A Shabalin \email{ashabalin@vcu.edu}
%	Maintainer: Andrey A Shabalin <ashabalin@vcu.edu>
}
%\references{
	%The package website: \url{http://shabal.in/}
%}

\keyword{ filematrix }
\seealso{
	See \code{\link{fm.create}} and \code{\linkS4class{filematrix}} for reference.
	
	Run \code{browseVignettes("filematrix")} for the list of vignettes.
}
