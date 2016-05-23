\name{filematrix-class}
\Rdversion{1.1}
\docType{class}
\alias{filematrix}
\alias{filematrix-class}
\alias{as.matrix,filematrix-method}
\alias{dim,filematrix-method}
\alias{dim<-,filematrix-method}
\alias{dimnames,filematrix-method}
\alias{dimnames<-,filematrix-method}
\alias{rownames,filematrix-method}
\alias{rownames<-,filematrix-method}
\alias{colnames,filematrix-method}
\alias{colnames<-,filematrix-method}
\alias{length,filematrix-method}
%%\alias{close,filematrix-method}

\alias{[.filematrix}
\alias{[<-.filematrix}



\title{Manipulating file matrices (class \code{"filematrix"})}
\description{
	\code{filematrix} is a class for working with very large matrices from files in data storage, not held in computer memory. It is intended as a simple, efficient solution to handling big data (i.e., datasets larger than memory capacity) in R. \cr 
	A new filematrix can be created with \code{\link{fm.create}}, \code{\link{fm.create.from.matrix}}, and \code{\link{fm.create.from.text.file}} functions. An existing filematrix can be opened for random access with \code{\link{fm.open}} or loaded fully in memory with \code{\link{fm.load}}.
	
	A filematrix can be handled as an ordinary matrix in R.
	
	It can be read from and written to via usual indexing with possible omission of indices. \cr
	For example: \code{fm[1:3,2:4]} and \code{fm[,2:4]}.
	
	The values can also be accessed with single indexing (vector-like access). \cr
	For example: \code{fm[3:7]} and \code{fm[4:7] = 1:4}.
	
	A whole filematrix can be read into an ordinary R matrix using \code{as.matrix} function or empty indexing \code{fm[]}.
	
	The dimensions of filematrix can be obtained via \code{dim}, \code{nrow} and \code{ncol} functions and modified with \code{dim} function. \cr
	For example: \code{dim(fm)} and \code{dim(fm) = c(10,100)}.
	
	The number of elements in filematrix is returned by \code{length} function.
	
	A filematrix can have row and column names. They can be accessed using the usual functions \code{rownames}, \code{colnames}, and \code{dimnames}.
	
	A filematrix can be closed after use with \code{close} command. 
	Please note, however, that there is no risk of losing modifications to a filematrix if an object is not closed, as all changes are instantly written to disk by default.
}
\usage{
\method{[}{filematrix}(x,i,j)
\method{[}{filematrix}(x,i,j) <- value

%%	\S4method{[}{filematrix}(x)
\S4method{as.matrix}{filematrix}(x)

\S4method{dim}{filematrix}(x)
\S4method{dim}{filematrix}(x) <- value

\S4method{length}{filematrix}(x)

\S4method{rownames}{filematrix}(x)
\S4method{rownames}{filematrix}(x) <- value

\S4method{colnames}{filematrix}(x)
\S4method{colnames}{filematrix}(x) <- value

\S4method{dimnames}{filematrix}(x)
\S4method{dimnames}{filematrix}(x) <- value
}
\arguments{
 \item{x}{
  	A filematrix object (\code{filematrix}).
 }
 \item{i,j}{
 }
 \item{value}{
  	A new value to replace the element/s specified to the left of the arrow.
 }
}


\keyword{classes}
\section{Methods}{
 \describe{
  \item{\code{isOpen}}{ Returns \code{TRUE} is the filematrix is open. }
  \item{\code{readAll()}:}{ Return the whole matrix. \cr
   Same as \code{fm[]} or \code{as.matrix(fm)}}
  \item{\code{writeAll(value)}:}{ Fill in the whole matrix. \cr    
   Same as \code{fm[] = value}}
  \item{\code{readSubCol(i, j, num)}:}{ Read \code{num} values in column \code{j} starting with row \code{i}. \cr 
   Same as \code{fm[i:(i+num-1), j]} }
  \item{\code{writeSubCol(i, j, value)}:}{ Write values in column \code{j} starting with row \code{i}. \cr     
   Same as \code{fm[i:(i+length(value)-1), j] = value} }
  \item{\code{readCols(start, num)}:}{ Read \code{num} columns starting with column \code{start}. \cr
   Same as \code{fm[, start:(start+num-1)] }}
  \item{\code{writeCols(start, value)}:}{ Write columns starting with column \code{start}. \cr
   Same as \code{fm[, start:(start+ncol(value)-1)] = value }}
  \item{\code{readSeq(start, len)}:}{ Read \code{len} values from the matrix starting with \code{start}-th value. \cr
   Same as \code{fm[start:(start+len-1)]} }
  \item{\code{writeSeq(start, value)}:}{ Write values in the matrix starting with \code{start}-th value. \cr
   Same as \code{fm[start:(start+length(value)-1)] = value}  }
  \item{\code{appendColumns(mat)}}{ Increases filematrix by adding more columns (to the right side of the matrix). Matrix \code{mat} must have the same number of rows. \cr 
   Performs the same operation as \code{fm = cbind(fm, mat)} for ordinary matrices.}
 }
}

%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~


%\references{
%	The package website: \url{http://shabal.in/}
%}

\author{
	Andrey A Shabalin \email{ashabalin@vcu.edu}
}

\seealso{
	For function creating and opening file matrices see \code{\link{fm.create}}.
	
	Run \code{browseVignettes("filematrix")} for the list of vignettes.
}
