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
		Version: \tab 1.1.0 \cr
		Date: \tab 2016-05-23 \cr
		License: \tab LGPL-3 \cr
		Depends: \tab methods \cr
	}
	
	Interface for working with large matrices stored in files,
	not in computer memory. Supports multiple non-character 
	data types (double, integer, logical and raw) of 
	various sizes (e.g. 8 and 4 byte real values).
	Access to parts of the matrix is done by indexing (e.g. fm[,1]), 
	exactly as with usual R matrices. Supports very large matrices.
	Tested on multi-terabyte matrices. 
	Allows for more than 2^32 rows or columns.
	Allows for quick addition of extra columns to a filematrix.
	Cross-platform as the package has R code only.
    
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
