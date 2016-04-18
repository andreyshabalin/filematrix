\name{fm.create}
\alias{fm.create}
\alias{fm.create.from.matrix}
\alias{fm.open}
\alias{fm.load}
\alias{fm.create.from.text.file}
\alias{close,filematrix-method}
\alias{closeAndDeleteFiles}

\title{
	Functions to create a new, or open an existing, filematrix
}
\description{
 %Create a new or open existing \code{\linkS4class{filematrix}} object.
 
 \code{fm.create} creates a new filematrix. If a filematrix with this name exists, it is overwritten.
 
 \code{fm.create.from.matrix} creates a new filematrix from an existing R matrix.
 
 \code{fm.open} opens an existing filematrix.
 
 \code{fm.load} loads entire existing filematrix into memory as an ordinary R matrix.
 
 \code{fm.create.from.text.file} reads a matrix from a text file and saves it into a new file-backed matrix. The rows in the text file become columns in the file-backed matrix.
 
 ###  !!!!!!!!! As mentioned below this needs some unpacking. The transpose piece, in particular, seems arbitrary and odd.    !!!!!!!
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

fm.load( filenamebase, lockfile = NULL)

fm.create.from.text.file(
    textfilename, 
    filenamebase, 
    skipRows = 1, 
    skipColumns = 1, 
    sliceSize = 1000, 
    omitCharacters = "NA", 
    delimiter = "\t", 
    rowNamesColumn = 1, 
    type="double", 
    size = NULL)

\S4method{close}{filematrix}(con)

closeAndDeleteFiles( con )

}
\arguments{
 \item{filenamebase}{
  Name without extension for the files storing the filematrix. \cr
  The file \code{<filenamebase>.bmat} keeps the matrix values and \code{<filenamebase>.desc.txt} stores the matrix dimensions, data type, and data type size.
  Names of rows and columns, if set, are stored in \code{<filenamebase>.nmsrow.txt} and \code{<filenamebase>.nmscol.txt}.
 }
 \item{nrow}{
  Number of rows in the matrix. Values over 2^32 are supported.
 }
 \item{ncol}{
  Number of columns in the matrix. Values over 2^32 are supported.
 }
 \item{type}{
  The type of values stored in the matrix. Must be either \code{"double"}, \code{"integer"}, \code{"logical"}, or \code{"raw"}.
 }
 \item{size}{
  Size of each item of the matrix in bytes. \cr
  Default values are 8 for \code{"double"}, 4 for \code{"integer"}, and 1 for \code{"logical"} and \code{"raw"}. \cr
  Do not set if not sure.
 }
 \item{mat}{
 	Regular R matrix, to be copied into a new filematrix.
 }
 \item{readonly}{
  If \code{TRUE}, the values in the opened filematrix cannot be changed.
 }
 \item{textfilename}{
  Name of the text file with matrix data, to be copied into a new filematrix.
 }
 \item{skipRows}{
  Number of rows with column names. The matrix values are expected after first \code{skipRows} rows of the file. Can be zero.
 }
 \item{skipColumns}{
  Number of columns before matrix values begin. Can be zero.
 }
 \item{sliceSize}{
  The text file with matrix is read in chuncks of \code{sliceSize} rows.
  ## !!!!!!   The sliceSize stuff needs elaboration and/or clarification. Another sentence explaining the method would help.  !!!!!!!!!
 }
 \item{omitCharacters}{
  The text string representing missing values.
 }
 \item{delimiter}{
  The delimiter separating values in the text matrix file.
 }
 \item{rowNamesColumn}{
  The row names are taken from the \code{rowNamesColumn}-th column of the text file.
 }
 \item{con}{
  A filematrix.
 }
 \item{lockfile}{
  Optional. Name of a lock file. Used to avoid simultaneous operations by multiple R instances accessing the same filematrix or a different filematrix on the same hard drive. Do not use if not sure.
 }
}

\details{
  Once created or opened, a filematrix object can be accessed as an ordinary matrix using both vector \code{fm[]} and matrix \code{fm[,]} indexing. 
  The indices can be integer or logical vectors.
}
\value{
	Returns a \code{\linkS4class{filematrix}} object.
	The object can be closed with \code{close} command or closed and removed with \code{\link{closeAndDeleteFiles}} command.
}
%\references{
%	The package website: \url{http://shabal.in/}
%}
\author{
	Andrey Shabalin \email{ashabalin@vcu.edu}
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  For more on the use of filematrices see \code{\linkS4class{filematrix}}.
}
\examples{
filename = tempfile();

fm = fm.create(filenamebase=filename, nrow=10, ncol=10);

fm[1:3,1:3] = 1:9;

print(fm[1:4,1:4])

close(fm);

file.remove(paste0(filename,".bmat"));
file.remove(paste0(filename,".desc.txt"));
}
%\keyword{ file }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
