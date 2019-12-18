gregtheme <- function (base_size = 11, base_family = "Arial", base_line_size = 0.5, 
                       base_rect_size = 0.5, shading_color = "grey85", line_color = "black") 
{
  theme_grey(base_size = base_size, base_family = base_family, 
             base_line_size = base_line_size, base_rect_size = base_rect_size) %+replace% 
    
    theme(axis.line = element_line(colour = NA),
          axis.text = element_text(colour = "black", size = base_size-3),
          legend.background = element_rect(fill = shading_color, colour = shading_color),
          legend.key = element_rect(fill = shading_color, colour = shading_color), complete = TRUE,
          legend.text = element_text(size = base_size-1),
          legend.title = element_text(size = base_size-1),
          panel.background = element_rect(fill = "white", colour = NA), 
          panel.border = element_rect(linetype = "solid", fill = NA, colour = line_color, size = base_line_size),
          panel.grid = element_line(colour = NA),
          plot.margin = unit(c(0.5,0.5,0.5,0.5), "cm"),
          plot.title = element_text(size = base_size, hjust = 0.5, vjust = 3),
          strip.background = element_rect(fill = shading_color, colour = line_color, size = base_line_size),
          strip.text = element_text(size = base_size-2),
          strip.text.x = element_text(margin = margin(c(5,10,5,10)))
    )
}
