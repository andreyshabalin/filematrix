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
    \code{filematrix} is a class for working with very large matrices
    stored in files, not held in computer memory.
    It is intended as a simple, efficient solution to handling big numeric data
    (i.e., datasets larger than memory capacity) in R. \cr
    A new filematrix can be created with \code{\link{fm.create}}.
    It can be created from an existing R matrix
    with \code{\link{fm.create.from.matrix}}.
    A text file with a matrix can be scanned and converted into a filematrix
    with \code{\link{fm.create.from.text.file}}.
    An existing filematrix can be opened for read/write access
    with \code{\link{fm.open}} or loaded fully in memory
    with \code{\link{fm.load}}.
    
    A filematrix can be handled as an ordinary matrix in R.
    
    It can be read from and written to via usual indexing
    with possible omission of indices.\cr
    For example: \code{fm[1:3,2:4]} and \code{fm[,2:4]}.
    
    The values can also be accessed as a vector
    with single indexing.\cr
    For example: \code{fm[3:7]} and \code{fm[4:7] = 1:4}.
    
    A whole filematrix can be read memory as an ordinary R matrix 
    with \code{as.matrix} function or empty indexing \code{fm[]}.
    
    The dimensions of filematrix can be obtained via \code{dim}, 
    \code{nrow} and \code{ncol} functions and 
    modified with \code{dim} function.\cr
    For example: \code{dim(fm)} and \code{dim(fm) = c(10,100)}.
    
    The number of elements in filematrix is returned by \code{length} function.
    
    A filematrix can have row and column names.
    They can be accessed using the standard functions
    \code{rownames}, \code{colnames}, and \code{dimnames}.
    
    A filematrix can be closed after use with \code{close} command.
    Note, however, that there is no risk of losing modifications 
    to a filematrix if an object is not closed, 
    as all changes are written to disk without delay.
}
\usage{
\method{[}{filematrix}(x,i,j)
\method{[}{filematrix}(x,i,j) <- value

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
        Row/column indices specifying elements to extract or replace.
    }
    \item{value}{
        A new value to replace the indexed element(s).
    }
}


\keyword{classes}
\section{Methods}{
\describe{
    \item{\code{isOpen}}{
        Returns \code{TRUE} is the filematrix is open.
    }
    \item{\code{readAll()}:}{ Return the whole matrix. \cr
        Same as \code{fm[]} or \code{as.matrix(fm)}
    }
    \item{\code{writeAll(value)}:}{
        Fill in the whole matrix. \cr    
        Same as \code{fm[] = value}
    }
    \item{\code{readSubCol(i, j, num)}:}{
        Read \code{num} values in column \code{j} starting with row \code{i}.\cr
        Same as \code{fm[i:(i+num-1), j]} 
    }
    \item{\code{writeSubCol(i, j, value)}:}{
        Write values in the column \code{j} starting with row \code{i}. \cr    
        Same as \code{fm[i:(i+length(value)-1), j] = value}
    }
    \item{\code{readCols(start, num)}:}{
        Read \code{num} columns starting with column \code{start}. \cr
        Same as \code{fm[, start:(start+num-1)] }
    }
    \item{\code{writeCols(start, value)}:}{
        Write columns starting with column \code{start}. \cr
        Same as \code{fm[, start:(start+ncol(value)-1)] = value }
    }
    \item{\code{readSeq(start, len)}:}{
        Read \code{len} values from the matrix starting with 
        \code{start}-th value. \cr
        Same as \code{fm[start:(start+len-1)]} }
    \item{\code{writeSeq(start, value)}:}{
        Write values in the matrix starting with \code{start}-th value. \cr
        Same as \code{fm[start:(start+length(value)-1)] = value} 
    }
    \item{\code{appendColumns(mat)}}{
        Increases filematrix by adding columns to the right side of the matrix.
        Matrix \code{mat} must have the same number of rows. \cr 
        Same as \code{fm = cbind(fm, mat)} for ordinary matrices.}
    }
}
\value{
    \code{length} function returns the number of elements in the filematrix.

    Functions \code{colnames}, \code{rownames}, and \code{dimnames} return 
    the same values as their counterparts for the regular R matrices.
}

\author{
    Andrey A Shabalin \email{andrey.shabalin@gmail.com}
}

\seealso{
    For function creating and opening file matrices see
    \code{\link{fm.create}}.
    
    Run \code{browseVignettes("filematrix")} for the list of vignettes.
}
