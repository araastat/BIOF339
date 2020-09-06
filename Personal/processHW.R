library(fs)

setwd('~/Dropbox/BIOF339_Fall2019/Homeworks/HW9')

fnames <- dir_ls('.', glob = '*.R*')
for( f in fnames){
  file_move(f, stringr::str_replace_all(f, ' ', '_'))
}

fnames <- dir_ls('.', glob='*.R*')
for (f in fnames) {
  tryCatch(
    rmarkdown::render(f, quiet=TRUE),
    error = function(e){
      message(paste0('Error processing ', f))
    },
    finally = message(paste0('Processed ',f))
  )
}
