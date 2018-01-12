\name{fm.create}
\alias{fm.create}
\alias{fm.create.from.matrix}
\alias{fm.open}
\alias{fm.load}
\alias{fm.create.from.text.file}
\alias{close,filematrix-method}
\alias{closeAndDeleteFiles}

\title{
    Functions to Create a New, or Open an Existing Filematrix
}
\description{
    Create a new or open existing \code{\linkS4class{filematrix}} object.
    
    \code{fm.create} creates a new filematrix.
    If a filematrix with this name exists, it is overwritten (destroyed).
    
    \code{fm.create.from.matrix} creates a new filematrix copy of
    an existing R matrix.
    
    \code{fm.open} opens an existing filematrix for read/write access.
    
    \code{fm.load} loads entire existing filematrix
    into memory as an ordinary R matrix.
    
    \code{fm.create.from.text.file} reads a matrix from a text file
    into a new filematrix.
    The rows in the text file become columns in the filematrix.
    The transposition happens because the text files stores data by rows and
    filematrices store data by columns.
 }
\usage{
fm.create( 
    filenamebase,
    nrow = 0,
    ncol = 1,
    type = "double",
    size = NULL,
    lockfile = NULL)
    
fm.create.from.matrix( 
    filenamebase,
    mat,
    size = NULL,
    lockfile = NULL)

fm.open(
    filenamebase,
    readonly = FALSE,
    lockfile = NULL)

fm.load(filenamebase, lockfile = NULL)

fm.create.from.text.file(
    textfilename,
    filenamebase,
    skipRows = 1,
    skipColumns = 1,
    sliceSize = 1000,
    omitCharacters = "NA",
    delimiter = "\t",
    rowNamesColumn = 1,
    type = "double",
    size = NULL)

\S4method{close}{filematrix}(con)

closeAndDeleteFiles(con)

}
\arguments{
    \item{filenamebase}{
        Name without extension for the files storing the filematrix. \cr
        The file \code{<filenamebase>.bmat} keeps the matrix values and
        \code{<filenamebase>.desc.txt} stores the matrix dimensions,
        data type, and data type size.
        Names of rows and columns, if defined, are stored in
        \code{<filenamebase>.nmsrow.txt} and \code{<filenamebase>.nmscol.txt}.
    }
    \item{nrow}{
        Number of rows in the matrix. Values over 2^32 are supported.
    }
    \item{ncol}{
        Number of columns in the matrix. Values over 2^32 are supported.
    }
    \item{type}{
        The type of values stored in the matrix.
        Can be either \code{"double"}, \code{"integer"}, 
        \code{"logical"}, or \code{"raw"}.
    }
    \item{size}{
        Size of each item of the matrix in bytes. \cr
        Default values are 8 for \code{"double"}, 4 for \code{"integer"}, and 
        1 for \code{"logical"} and \code{"raw"}. \cr
        Do not change if not sure.
    }
    \item{mat}{
        Regular R matrix, to be copied into a new filematrix.
    }
    \item{readonly}{
        If \code{TRUE}, the values in the opened filematrix cannot be changed.
    }
    \item{textfilename}{
        Name of the text file with matrix data,
        to be copied into a new filematrix.
    }
    \item{skipRows}{
        Number of rows with column names.
        The matrix values are expected after first \code{skipRows}
        rows of the file.
        Can be zero.
    }
    \item{skipColumns}{
        Number of columns before matrix values begin.
        Can be zero.
    }
    \item{sliceSize}{
        The text file with matrix is read in chuncks of \code{sliceSize} rows.
        This is a performance tuning parameter, it does not affect the outcome.
    }
    \item{omitCharacters}{
        The text string representing missing values.
        Default value is \code{NA}.
    }
    \item{delimiter}{
        The delimiter separating values in the text matrix file.
    }
    \item{rowNamesColumn}{
        The row names are taken from the \code{rowNamesColumn}-th 
        column of the text file. 
        By default, row names are extracted from the first column.
    }
    \item{con}{
        A filematrix object.
    }
    \item{lockfile}{
        Optional. Name of a lock file (file is overwritten).
        Used to avoid simultaneous operations by multiple R instances
        accessing the same filematrix or
        different filematrices on the same hard drive.
        Do not use if not sure.
    }
}

\details{
    Once created or opened, a filematrix object can be accessed
    as an ordinary matrix using both matrix \code{fm[,]} and
    vector \code{fm[]} indexing.
    The indices can be integer (no zeros) or logical vectors.
}
\value{
    Returns a \code{\linkS4class{filematrix}} object.
    The object can be closed with \code{close} command or 
    closed and deleted from disk with \code{\link{closeAndDeleteFiles}} command.
}
\author{
    Andrey A Shabalin \email{ashabalin@vcu.edu}
}
\seealso{
    For more on the use of filematrices see \code{\linkS4class{filematrix}}.
    
    Run \code{browseVignettes("filematrix")} for the list of vignettes.
}
\examples{
# Create a 10x10 matrix
fm = fm.create(filenamebase=tempfile(), nrow=10, ncol=10)

# Change values in the top 3x3 corner
fm[1:3,1:3] = 1:9

# View the values in the top 4x4 corner
fm[1:4,1:4]

# Close and delete the filematrix
closeAndDeleteFiles(fm)
}
