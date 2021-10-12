# helper functions

theme_github <- function(){
    theme_minimal() +
    theme(
        panel.grid.major.x = element_line(colour = "white", linetype = "dotted"),
        panel.grid.minor.x = element_line(colour = "black", linetype = "dotted"),
        panel.grid.major.y = element_line(colour = "white", linetype = "dotted"),
        panel.grid.minor.y = element_line(colour = "black", linetype = "dotted"),
        panel.background = element_rect(fill = "transparent", colour = NA),
        axis.text = element_text(size = 12, colour = "#ad03fc"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(colour = "#ad03fc", size = 12), 
        axis.line = element_line(colour = "#ad03fc", size = 1)
    )
}
