geom_enterotype <- function(mapping = NULL, data = NULL, stat = "identity",  position = "identity", 
                            alpha = 0.3, prop = 0.5, ..., lineend = "butt", linejoin = "round", 
                            linemitre = 1, arrow = NULL, na.rm = FALSE, parse = FALSE, 
                            nudge_x = 0, nudge_y = 0, label.padding = unit(0.15, "lines"), 
                            label.r = unit(0.15, "lines"), label.size = 0.1, 
                            show.legend = TRUE, inherit.aes = TRUE) {
  library(ggplot2)
  # create new stat and geom for PCA scatterplot with ellipses
  StatEllipse <- ggproto("StatEllipse", Stat, 
                         required_aes = c("x", "y"), 
                         compute_group = function(., data, scales, level = 0.75, segments = 51, ...) {
                           library(MASS)
                           dfn <- 2
                           dfd <- length(data$x) - 1
                           if (dfd < 3) {
                             ellipse <- rbind(c(NA, NA))
                           } else {
                             v <- cov.trob(cbind(data$x, data$y))
                             shape <- v$cov
                             center <- v$center
                             radius <- sqrt(dfn * qf(level, dfn, dfd))
                             angles <- (0:segments) * 2 * pi/segments
                             unit.circle <- cbind(cos(angles), sin(angles))
                             ellipse <- t(center + radius * t(unit.circle %*% chol(shape)))
                           }
                           ellipse <- as.data.frame(ellipse)
                           colnames(ellipse) <- c("x", "y")
                           return(ellipse)
                         })
  
  # write new ggproto 
  GeomEllipse <- ggproto("GeomEllipse", Geom, 
                         draw_group = function(data, panel_scales, coord) {
                           n <- nrow(data)
                           if (n == 1) 
                             return(zeroGrob())
                           munched <- coord_munch(coord, data, panel_scales)
                           munched <- munched[order(munched$group), ]
                           first_idx <- !duplicated(munched$group)
                           first_rows <- munched[first_idx, ]
                           grid::pathGrob(munched$x, munched$y, default.units = "native", 
                                          id = munched$group, 
                                          gp = grid::gpar(col = first_rows$colour, 
                                                          fill = alpha(first_rows$fill, first_rows$alpha), lwd = first_rows$size * .pt, lty = first_rows$linetype))
                         }, 
                         default_aes = aes(colour = "NA", fill = "grey20", size = 0.5, linetype = 1, alpha = NA, prop = 0.5), 
                         handle_na = function(data, params) {
                           data
                         }, 
                         required_aes = c("x", "y"), 
                         draw_key = draw_key_path
  )
  
  # create a new stat for PCA scatterplot with lines which totally directs to the center
  StatConline <- ggproto("StatConline", Stat, 
                         compute_group = function(data, scales) {
                           library(miscTools)
                           library(MASS)
                           df <- data.frame(data$x,data$y)
                           mat <- as.matrix(df)
                           center <- cov.trob(df)$center
                           names(center)<- NULL 
                           mat_insert <- insertRow(mat, 2, center )
                           for(i in 1:nrow(mat)) {
                             mat_insert <- insertRow( mat_insert, 2*i, center )
                             next
                           }
                           mat_insert <- mat_insert[-c(2:3),]
                           rownames(mat_insert) <- NULL
                           mat_insert <- as.data.frame(mat_insert,center)
                           colnames(mat_insert) =c("x","y")
                           return(mat_insert)
                         },
                         required_aes = c("x", "y")
                         
  )
  
  # create a new stat for PCA scatterplot with center labels
  StatLabel <- ggproto("StatLabel" ,Stat,
                       compute_group = function(data, scales) {
                         library(MASS)
                         df <- data.frame(data$x,data$y)
                         center <- cov.trob(df)$center
                         names(center)<- NULL 
                         center <- t(as.data.frame(center))
                         center <- as.data.frame(cbind(center))
                         colnames(center) <- c("x","y")
                         rownames(center) <- NULL
                         return(center)
                       },
                       required_aes = c("x", "y")
  )
  
  
  layer1 <- layer(data = data, mapping = mapping, stat = stat, geom = GeomPoint, 
                  position = position, show.legend = show.legend, inherit.aes = inherit.aes, 
                  params = list(na.rm = na.rm, ...))
  layer2 <- layer(stat = StatEllipse, data = data, mapping = mapping, geom = GeomEllipse, position = position, show.legend = FALSE, 
                  inherit.aes = inherit.aes, params = list(na.rm = na.rm, prop = prop, alpha = alpha, ...))
  layer3 <- layer(data = data, mapping = mapping, stat =  StatConline, geom = GeomPath, 
                  position = position, show.legend = show.legend, inherit.aes = inherit.aes, 
                  params = list(lineend = lineend, linejoin = linejoin, 
                                linemitre = linemitre, arrow = arrow, alpha=0.3, na.rm = na.rm, ...))
  if (!missing(nudge_x) || !missing(nudge_y)) {
    if (!missing(position)) {
      stop("Specify either `position` or `nudge_x`/`nudge_y`", 
           call. = FALSE)
    }
    position <- position_nudge(nudge_x, nudge_y)
  }
  layer4 <- layer(data = data, mapping = mapping, stat = StatLabel, geom = GeomLabel, 
                  position = position, show.legend = FALSE, inherit.aes = inherit.aes, 
                  params = list(parse = parse, label.padding = label.padding, 
                                label.r = label.r, label.size = label.size, na.rm = na.rm, ...))
  #return(list(layer1,layer3,layer4))
  return(list(layer1,layer2,layer3,layer4))
}

## Define PCA with a correlation matrix #############

PCA <- function(cov_matrix, ind_label, pop_label, x_axis, y_axis, ellipse, index_exclude=vector())
 {
  m <- as.matrix(cov_matrix)
  m[is.na(m)]<- median(m, na.rm = T)
  m<-m[setdiff(seq_along(ind_label), index_exclude),setdiff(seq_along(ind_label), index_exclude)] ## Remove 4SJH, four 3Ps individuals, and contaminated ones
  e <- eigen(m)
  e_value<-e$values
  x_variance<-e_value[x_axis]/sum(e_value)*100
  y_variance<-e_value[y_axis]/sum(e_value)*100
  e <- as.data.frame(e$vectors)
  e <- cbind(ind_label, pop_label, e) ## with the above individuals removed
  #colnames(e)[3:331]<-paste0("PC",1:329)
  colnames(e)[3:(dim(e)[1])]<-paste0("PC",1:(dim(e)[1]-2)) ## with the above individuals removed
  colnames(e)[1:2]<-c("individual", "population")
  assign("pca_table", e, .GlobalEnv)
  
  PCA_plot<-ggplot(data=e[,],aes(x=e[,x_axis+2], y=e[,y_axis+2], color=population,label=population)) + 
    geom_point(aes(shape=population), alpha=1, size=3) +
    scale_shape_manual(values = c(rep(c(15,16,17,18),7), 15, 16)) +
    theme(
      axis.text.x = element_blank(),
      axis.text.y = element_blank()
    ) +
    xlab(paste0("PC", x_axis, "(",round(x_variance,2),"%)")) +
    ylab(paste0("PC", y_axis ,"(",round(y_variance,2),"%)")) 
  if(ellipse==T){
    PCA_plot <- PCA_plot + geom_enterotype(alpha=0)
  } 
  print(PCA_plot)
}

## Define DAPC function ########

DAPC <- function (x_axis, y_axis) {
  fit <- lda(population ~ ., data=pca_table[,2:51], na.action="na.omit", CV=F, output = "Scatterplot")
  plda <- predict(object = fit,
                  newdata = pca_table[,2:51])
  prop.lda = fit$svd^2/sum(fit$svd^2)
  dataset = data.frame(group = pca_table[,2], lda = plda$x)
  DAPC_plot<- ggplot(dataset, aes(dataset[,1+x_axis], dataset[,1+y_axis], color= group, label=group)) + 
    geom_point(aes(colour = group, shape = group), size = 2.5) + 
    scale_shape_manual(values = c(rep(c(15,16,17,18),7), 15, 16)) +
    labs(x = paste0("LD", x_axis," (", percent(prop.lda[x_axis]), ")", sep=""),
         y = paste0("LD", y_axis, " (", percent(prop.lda[y_axis]), ")", sep="")) +
    geom_enterotype(alpha=0) 
  print(DAPC_plot)
}
