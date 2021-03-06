% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_seu.R
\name{save_seurat}
\alias{save_seurat}
\title{Save seurat object to <project>/output/sce/<feature>_seu.rds}
\usage{
save_seurat(..., prefix = "unfiltered", proj_dir = getwd())
}
\arguments{
\item{...}{named arguments specifying seurat objects list of seurat objects; default "gene" and "transcript"}

\item{proj_dir}{}
}
\value{

}
\description{
Save seurat object to <project>/output/sce/<feature>_seu.rds
}
\examples{
\dontrun{
save_seurat(gene = feature_seus$gene, transcript = feature_seus$transcript, proj_dir = proj_dir)

save_seurat(gene = feature_seus$gene, transcript = feature_seus$transcript, prefix = "remove_nonPRs", proj_dir = proj_dir)

}
}
