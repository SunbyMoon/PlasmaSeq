\name{@ANNOBJPREFIX@UNIPROT}
\alias{@ANNOBJPREFIX@UNIPROT}
\alias{@ANNOBJPREFIX@UNIPROT2PROBE}
\title{Map Uniprot accession numbers with Entrez Gene identifiers}  
\description{ 
  @ANNOBJPREFIX@UNIPROT is an R object that contains mappings between 
  Entrez Gene identifiers and Uniprot accession numbers.    
}
\details{
  This object is a simple mapping of Entrez Gene identifiers
  \url{http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=gene} to Uniprot
  Accessions.

  Mappings were based on data provided by: 
  \url{http://www.ensembl.org/biomart/martview/}
}

\examples{
    x <- @ANNOBJPREFIX@UNIPROT
    # Get the entrez gene IDs that are mapped to an Uniprot ID
    mapped_genes <- mappedkeys(x)
    # Convert to a list
    xx <- as.list(x[mapped_genes])
    if(length(xx) > 0) {
      # Get the Uniprot IDs for the first five genes
      xx[1:5]
      # Get the first one
      xx[[1]]
    }
}
\keyword{datasets}



