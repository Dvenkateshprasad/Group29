library(tuneR)
library(seewave)
library(warbleR)
options(warn = -1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  print ("USAGE ERROR!")
  print ("Expected 1 Argument: Supplied ")
  print (length(args))
  
  stop()
}

location = args[1]
soundLocation = paste(location, "/test", sep = "")
textLocation = location


specan3 <-
  function(X,
           bp = c(0, 22),
           wl = 2048,
           threshold = 5) {
    if (class(X) == "data.frame") {
      if (all(c("test.files", "selec",
                "start", "end") %in% colnames(X)))
      {
        start <- as.numeric(unlist(X$start))
        end <- as.numeric(unlist(X$end))
        test.files <- as.character(unlist(X$test.files))
        selec <- as.character(unlist(X$selec))
      }
    } 
    

    
    #return warning if not all sound files were found
    fs <-
      list.files(path = getwd(),
                 pattern = ".wav$",
                 ignore.case = TRUE)
    if (length(unique(test.files[(test.files %in% fs)])) != length(unique(test.files)))
      cat(paste(length(unique(test.files)) - length(unique(test.files[(test.files %in% fs)])),
                ".wav file(s) not found"))
    
    #count number of sound files in working directory and if 0 stop
    d <- which(test.files %in% fs)
    if (length(d) == 0) {
      stop("The .wav files are not in the working directory")
    }  else {
      start <- start[d]
      end <- end[d]
      selec <- selec[d]
      test.files <- test.files[d]
    }
    
   

      lapp <- pbapply::pblapply
    
    options(warn = 0)
    cat("Measuring acoustic parameters: \n")
    x <- as.data.frame(lapp(1:length(start), function(i) {
      print(paste("Analysing ", test.files[i]))
      r <-
        tuneR::readWave(
          file.path(getwd(), test.files[i]),
          from = start[i],
          to = end[i],
          units = "seconds"
        )
      
      b <-
        bp #in case bp its higher than can be due to sampling rate
      if (b[2] > ceiling(r@samp.rate / 2000) - 1)
        b[2] <- ceiling(r@samp.rate / 2000) - 1
      
      #frequency spectrum analysis
      songspec <- seewave::spec(r, f = r@samp.rate, plot = FALSE)
      analysis <-
        seewave::specprop(
          songspec,
          f = r@samp.rate,
          flim = c(0, 280 / 1000),
          plot = FALSE
        )
      
      #save parameters
      meanfreq <- analysis$mean / 1000
      sd <- analysis$sd / 1000
      median <- analysis$median / 1000
      Q25 <- analysis$Q25 / 1000
      Q75 <- analysis$Q75 / 1000
      IQR <- analysis$IQR / 1000
      skew <- analysis$skewness
      kurt <- analysis$kurtosis
      sp.ent <- analysis$sh
      sfm <- analysis$sfm
      mode <- analysis$mode / 1000
      centroid <- analysis$cent / 1000
      
      #Frequency with amplitude peaks
      peakf <-
        seewave::fpeaks(songspec, f = r@samp.rate, wl = wl, nmax = 3, plot = FALSE)[1, 1]
      
      #Fundamental frequency parameters
      ff <-
        seewave::fund(
          r,
          f = r@samp.rate,
          ovlp = 50,
          threshold = threshold,
          fmax = 280,
          ylim = c(0, 280 / 1000),
          plot = FALSE,
          wl = wl
        )[, 2]
      meanfun <- mean(ff, na.rm = T)
      minfun <- min(ff, na.rm = T)
      maxfun <- max(ff, na.rm = T)
      
      #Dominant frecuency parameters
      y <-
        seewave::dfreq(
          r,
          f = r@samp.rate,
          wl = wl,
          ylim = c(0, 280 / 1000),
          ovlp = 0,
          plot = F,
          threshold = threshold,
          bandpass = b * 1000,
          fftw = TRUE
        )[, 2]
      meandom <- mean(y, na.rm = TRUE)
      mindom <- min(y, na.rm = TRUE)
      maxdom <- max(y, na.rm = TRUE)
      dfrange <- (maxdom - mindom)
      duration <- (end[i] - start[i])
      
      #modulation index calculation
      changes <- vector()
      for (j in which(!is.na(y))) {
        change <- abs(y[j] - y[j + 1])
        changes <- append(changes, change)
      }
      if (mindom == maxdom)
        modindx <- 0
      else
        modindx <- mean(changes, na.rm = T) / dfrange
      
      #save results
      return(
        c(
          meanfreq,
          sd,
          median,
          Q25,
          Q75,
          IQR,
          skew,
          kurt,
          sp.ent,
          sfm,
          mode,
          centroid,
          peakf,
          meanfun,
          minfun,
          maxfun,
          meandom,
          mindom,
          maxdom,
          dfrange,
          modindx
        )
      )
    }))
    
    #change result names
    rownames(x) <-
      c(
        "meanfreq",
        "sd",
        "median",
        "Q25",
        "Q75",
        "IQR",
        "skew",
        "kurt",
        "sp.ent",
        "sfm",
        "mode",
        "centroid",
        "peakf",
        "meanfun",
        "minfun",
        "maxfun",
        "meandom",
        "mindom",
        "maxdom",
        "dfrange",
        "modindx"
      )

    x <- data.frame(test.files, as.data.frame(t(x)))
    
    colnames(x)[1] <- c("test.files")
    rownames(x) <- c(1:nrow(x))

    return(x)
  }

processFolder <- function(folderName) {
  # Start with empty data.frame.
  data <- data.frame()
  
  # Get list of files in the folder.
  list <- list.files(folderName, '\\.wav')
  
  # Add file list to data.frame for processing.
  for (fileName in list) {
    row <- data.frame(fileName, 0, 0, 20)
    data <- rbind(data, row)
  }
  
  # Set column names.
  names(data) <- c('test.files', 'selec', 'start', 'end')
  
  # Move into folder for processing.
  setwd(folderName)
  
  # Process files.
  acoustics <- specan3(data)
  print("Acoustics Extraction Done")
  # Move back into parent folder.
  View(acoustics)
  
  setwd(textLocation)
  write.table(acoustics,
              "features.csv",
              sep = ",",
              row.names = FALSE)
}

processFolder(soundLocation)