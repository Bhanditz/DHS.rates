# CHMORT5 function: calculate Children death probabilities
# NBIRTHS function: calculate approximated number of children exposed to the risk of mortality
# NBIRTHSW function: calculate weighted approximated number of children exposed to the risk of mortality
# DEFT function: calculate approximated design effect
# Mahmoud Elkasabi
# 04/03/2018
# Edited on 06/10/2018
# Edited on 09/12/2018
# Edited on 01/05/2019
# Edited on 01/13/2019 -- added CHMORTp

### Child mortality rates
CHMORT5 <- function(Data.Name, PeriodEnd = NULL) {
      ageseg <- list(c(0, 1), c(1, 3), c(3, 6), c(6, 12), c(12, 24), c(24, 36), c(36, 48), c(48, 60))
      names(ageseg) <- c(1, 2, 3, 4, 5, 6, 7, 8)

      deathprob <- numeric(length = 8)
      names(deathprob) <- names(ageseg)

      for (i in seq_along(ageseg)) {
        segdata <- Data.Name[which((Data.Name$b7 >= ageseg[[i]][1]) | is.na(Data.Name$b7)), ]

        segdata$exposure <- NA

        segdata$exposure[segdata$b3 >= (segdata$tl - ageseg[[i]][2]) &
                           segdata$b3 < (segdata$tl - ageseg[[i]][1]) ] <- 0.5

        segdata$exposure[segdata$b3 >= (segdata$tl - ageseg[[i]][1]) &
                           segdata$b3 < (segdata$tu - ageseg[[i]][2]) ] <- 1

        segdata$exposure[segdata$b3 >= (segdata$tu - ageseg[[i]][2]) &
                           segdata$b3 < (segdata$tu - ageseg[[i]][1]) ] <- 0.5

        segdata$death <- NA

        segdata$death[segdata$b3 >= (segdata$tl - ageseg[[i]][2]) &
                        segdata$b3 < (segdata$tl - ageseg[[i]][1]) &
                        (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- 0.5

        segdata$death[segdata$b3 >= (segdata$tl - ageseg[[i]][1]) &
                        segdata$b3 < (segdata$tu - ageseg[[i]][2]) &
                        (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- 1

        segdata$death[segdata$b3 >= (segdata$tu - ageseg[[i]][2]) &
                        segdata$b3 < (segdata$tu - ageseg[[i]][1]) &
                        (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- ifelse(is.null(PeriodEnd) , 1, 0.5)

        segdata$death[is.na(segdata$b7)] <- 0

        deathprob[names(ageseg)[i]] <- sum(segdata$death * segdata$rweight, na.rm = TRUE) / (sum(segdata$exposure * segdata$rweight, na.rm = TRUE))
      }

      mort_rates <- list(
        c(data.frame(dpro = deathprob[1:1])),
        c(data.frame(dpro = deathprob[1:4])),
        c(data.frame(dpro = deathprob[5:8])),
        c(data.frame(dpro = deathprob[1:8]))
      )
      names(mort_rates) <- c("NNMR", "IMR", "CMR", "U5MR")

      mort_res <- numeric(length = 5)
      names(mort_res) <- c("NNMR", "PNNMR", "IMR", "CMR", "U5MR")

      for (i in seq_along(mort_rates)) {
        mort <- mort_rates[[i]]
        mort_label <- names(mort_rates)[i]
        mort$dpro <- (1 - mort$dpro)

        dpromat <- data.matrix(mort$dpro)
        product <- matrixStats::colProds(dpromat)

        mort_res[mort_label] <- (abs(1 - product) * 1000)
      }
      mort_res[2] <- mort_res[3] - mort_res[1]

      list(mort_res)
    }

### Child mortality probabilities
CHMORTp <- function(Data.Name, PeriodEnd = NULL) {
  ageseg <- list(c(0, 1), c(1, 3), c(3, 6), c(6, 12), c(12, 24), c(24, 36), c(36, 48), c(48, 60))
  names(ageseg) <- c("0", "1-2", "3-5", "6-11", "12-23", "24-35", "36-47", "48-59")

  deathprobn <- numeric(length = 8)
  names(deathprobn) <- names(ageseg)
  deathprobd <- numeric(length = 8)
  names(deathprobd) <- names(ageseg)
  wdeathprob <- numeric(length = 8)
  names(wdeathprob) <- names(ageseg)
  wdeathprobn <- numeric(length = 8)
  names(wdeathprobn) <- names(ageseg)
  wdeathprobd <- numeric(length = 8)
  names(wdeathprobd) <- names(ageseg)

  for (i in seq_along(ageseg)) {
    segdata <- Data.Name[which((Data.Name$b7 >= ageseg[[i]][1]) | is.na(Data.Name$b7)), ]

    segdata$exposure <- NA

    segdata$exposure[segdata$b3 >= (segdata$tl - ageseg[[i]][2]) &
                       segdata$b3 < (segdata$tl - ageseg[[i]][1]) ] <- 0.5

    segdata$exposure[segdata$b3 >= (segdata$tl - ageseg[[i]][1]) &
                       segdata$b3 < (segdata$tu - ageseg[[i]][2]) ] <- 1

    segdata$exposure[segdata$b3 >= (segdata$tu - ageseg[[i]][2]) &
                       segdata$b3 < (segdata$tu - ageseg[[i]][1]) ] <- 0.5

    segdata$death <- NA

    segdata$death[segdata$b3 >= (segdata$tl - ageseg[[i]][2]) &
                    segdata$b3 < (segdata$tl - ageseg[[i]][1]) &
                    (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- 0.5

    segdata$death[segdata$b3 >= (segdata$tl - ageseg[[i]][1]) &
                    segdata$b3 < (segdata$tu - ageseg[[i]][2]) &
                    (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- 1

    segdata$death[segdata$b3 >= (segdata$tu - ageseg[[i]][2]) &
                    segdata$b3 < (segdata$tu - ageseg[[i]][1]) &
                    (segdata$b7 >= ageseg[[i]][1] & segdata$b7 < ageseg[[i]][2])] <- ifelse(is.null(PeriodEnd) , 1, 0.5)

    segdata$death[is.na(segdata$b7)] <- 0

    wdeathprob[names(ageseg)[i]] <- sum(segdata$death * segdata$rweight, na.rm = TRUE) /
      (sum(segdata$exposure * segdata$rweight, na.rm = TRUE))
    wdeathprobn[names(ageseg)[i]] <- sum(segdata$death * segdata$rweight, na.rm = TRUE)
    wdeathprobd[names(ageseg)[i]] <- sum(segdata$exposure * segdata$rweight, na.rm = TRUE)
    deathprobn[names(ageseg)[i]] <- sum(segdata$death, na.rm = TRUE)
    deathprobd[names(ageseg)[i]] <- sum(segdata$exposure, na.rm = TRUE)
  }

  CHMORT8 <- cbind.data.frame(round(wdeathprob, 4), round(wdeathprobn,2), round(wdeathprobd,2),
                              round(deathprobn,2), round(deathprobd,2))

  names(CHMORT8) <- c("PROBABILITY", "W.DEATHS", "W.EXPOSURE", "DEATHS", "EXPOSURE")

  list(CHMORT8)[[1]]
}

### N: Total births contributed to the calculations
NBIRTHS <- function(Data.Name) {
      BirthNg <- list(c(0, 1), c(1, 12), c(0, 12), c(12, 60), c(0, 60))
      names(BirthNg) <- c("NNMR", "PNNMR", "IMR", "CMR", "U5MR")

      BirthN <- numeric(length = 5)
      names(BirthN) <- names(BirthNg)

      for (i in seq_along(BirthNg)) {
        segdata <- Data.Name[which((Data.Name$b7 >= BirthNg[[i]][1]) | is.na(Data.Name$b7)), ]

        segdata$exposure <- NA

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tl - BirthNg[[i]][1]) ] <- 0.5

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][1]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][2]) ] <- 1

        segdata$exposure[segdata$b3 >= (segdata$tu - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][1]) ] <- 0.5

        BirthN[names(BirthNg)[i]] <- sum(segdata$exposure, na.rm = TRUE)

      }

      list(BirthN)
    }

### WN: Total births contributed to the calculations _ weighted
NBIRTHSW <- function(Data.Name) {
      BirthNg <- list(c(0, 1), c(1, 12), c(0, 12), c(12, 60), c(0, 60))
      names(BirthNg) <- c("NNMR", "PNNMR", "IMR", "CMR", "U5MR")

      BirthNW <- numeric(length = 5)
      names(BirthNW) <- names(BirthNg)

      for (i in seq_along(BirthNg)) {
        segdata <- Data.Name[which((Data.Name$b7 >= BirthNg[[i]][1]) | is.na(Data.Name$b7)), ]

        segdata$exposure <- NA

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tl - BirthNg[[i]][1]) ] <- 0.5

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][1]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][2]) ] <- 1

        segdata$exposure[segdata$b3 >= (segdata$tu - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][1]) ] <- 0.5

        BirthNW[names(BirthNg)[i]] <- sum(segdata$exposure * segdata$rweight, na.rm = TRUE)
      }

      list(BirthNW)
    }

### DEFT: design effect
DEFT <- function(Data.Name) {
      BirthNg <- list(c(0, 1), c(1, 12), c(0, 12), c(12, 60), c(0, 60))
      names(BirthNg) <- c("NNMR", "PNNMR", "IMR", "CMR", "U5MR")

      Deft <- numeric(length = 5)
      names(Deft) <- names(BirthNg)

      for (i in seq_along(BirthNg)) {
        segdata <- Data.Name[which((Data.Name$b7 >= BirthNg[[i]][1]) | is.na(Data.Name$b7)), ]

        segdata$exposure <- 0

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tl - BirthNg[[i]][1]) ] <- 0.5

        segdata$exposure[segdata$b3 >= (segdata$tl - BirthNg[[i]][1]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][2]) ] <- 1

        segdata$exposure[segdata$b3 >= (segdata$tu - BirthNg[[i]][2]) &
                           segdata$b3 < (segdata$tu - BirthNg[[i]][1]) ] <- 0.5

        segdata$death <- 0

        segdata$death[segdata$b3 >= (segdata$tl - BirthNg[[i]][2]) &
                        segdata$b3 < (segdata$tl - BirthNg[[i]][1]) &
                        (segdata$b7 >= BirthNg[[i]][1] & segdata$b7 < BirthNg[[i]][2])] <- 0.5

        segdata$death[segdata$b3 >= (segdata$tl - BirthNg[[i]][1]) &
                        segdata$b3 < (segdata$tu - BirthNg[[i]][2]) &
                        (segdata$b7 >= BirthNg[[i]][1] & segdata$b7 < BirthNg[[i]][2])] <- 1

        segdata$death[segdata$b3 >= (segdata$tu - BirthNg[[i]][2]) &
                        segdata$b3 < (segdata$tu - BirthNg[[i]][1]) &
                        (segdata$b7 >= BirthNg[[i]][1] & segdata$b7 < BirthNg[[i]][2])] <- 0.5

        segdata$death[is.na(segdata$b7)] <- 0

        dstrat<-survey::svydesign(id = ~v021, strata = ~v022, weights = ~rweight, data = segdata)

        Deft[names(BirthNg)[i]] <- sqrt(survey::deff(survey::svyratio(~death, ~exposure, dstrat, deff = "replace")))
      }

      list(Deft)
    }
