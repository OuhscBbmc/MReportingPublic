rm(list=ls(all=TRUE))

########## Production of reports from .Rmd files ###
#./Vignettes/Questions
path_index <- base::file.path("./index.Rmd")
# path_ghPages<- base::file.path("./gh-pages-setup.Rmd")
# path_toolbox<- base::file.path("./toolbox-install.Rmd")
# path_TipsTricks <- base::file.path("./tips-and-tricks.Rmd")
# path_DrawingLines <- base::file.path("./bits/drawing-lines/Drawing-lines.Rmd")
# # Lab Log
# path_12_09_2014 <- base::file.path("./12-09-2014.Rmd")
# path_19_09_2014 <- base::file.path("./19-09-2014.Rmd")
# path_26_09_2014 <- base::file.path("./26-09-2014.Rmd")

# pathMDFilesFunding <- list.files("./funding", full.names=TRUE, recursive=TRUE)
# pathMDFiles <- c(pathMDFilesFunding)

patternToBuild <- "(?<!README)\\.(R){0,1}md$" #Gets all 'Rmd' and 'md' files, that aren't named `README`.
pathFilesToBuild <- list.files(full.names=TRUE, recursive=TRUE)
pathFilesToBuild <- grep(patternToBuild, pathFilesToBuild, perl=TRUE, value=TRUE)

# pathFilesToBuild

# #  Define groups of reports 
# labLogs <- c(path_26_09_2014)
# pathRmdFiles <- c(path_index) #path_ghPages,path_toolbox, path_TipsTricks)
# Place report paths HERE ###########
# buildthese <- c(allReports) ##########
# buildthese <- c( labLogs)

####################################

testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
for( pathFile in pathFilesToBuild ) {
  #   pathMd <- base::gsub(pattern=".Rmd$", replacement=".md", x=pathRmd)
  rmarkdown::render(input = pathFile, 
                    output_format=c(
                      # "pdf_document"
                      #,"md_document"
                      "html_document"
                    ),
                    clean=TRUE)
}

# base::system("bundle exec jekyll build")
# Or run this from the terminal to keep RStudio free to execute it's own stuff: `bundle exec jekyll serve` at localhost:4000
