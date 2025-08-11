get_bactools_logo <- function() {
    logo <- "
         __________________
        /                /|
       /                / |
      /________________/  |
      |               |   |
      |    BACTOOLS   |   |
      |               |   |
      |               |  /
      |_______________|/
    "
    # Colorize: outline blue, pages yellow, "BACTOOLS" green
    logo <- stringr::str_replace_all(logo, "_", crayon::blue("_"))
    logo <- stringr::str_replace_all(logo, "/", crayon::yellow("/"))
    logo <- stringr::str_replace_all(logo, "\\|", crayon::yellow("|"))
    logo <- stringr::str_replace_all(logo, "BACTOOLS", crayon::green("BACTOOLS"))

    banner <- "
   ____            _             _             
  |  _ \\          | |           | |            
  | |_) | __ _ ___| |_ ___  _ __| |_ ___  _ __ 
  |  _ < / _` / __| __/ _ \\| '__| __/ _ \\| '__|
  | |_) | (_| \\__ \\ || (_) | |  | || (_) | |   
  |____/ \\__,_|___/\\__\\___/|_|   \\__\\___/|_|   
    "
    return(c(logo, banner))
}
