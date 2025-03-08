\name{logLik.mkinfit}
\alias{logLik.mkinfit}
\title{
  Calculated the log-likelihood of a fitted mkinfit object
}
\description{
  This function simply calculates the product of the likelihood densities
  calculated using \code{\link{dnorm}}, i.e. assuming normal distribution,
  with of the mean predicted by the degradation model, and the
  standard deviation predicted by the error model.

  The total number of estimated parameters returned with the value
  of the likelihood is calculated as the sum of fitted degradation
  model parameters and the fitted error model parameters.
}
\usage{
  \method{logLik}{mkinfit}(object, ...)
}
\arguments{
  \item{object}{
    An object of class \code{\link{mkinfit}}.
  }
  \item{\dots}{
    For compatibility with the generic method
  }
}
\value{
  An object of class \code{\link{logLik}} with the number of
  estimated parameters (degradation model parameters plus variance
  model parameters) as attribute.
}
\seealso{
  Compare the AIC of columns of \code{\link{mmkin}} objects using
  \code{\link{AIC.mmkin}}.
}
\examples{
  \dontrun{
  sfo_sfo <- mkinmod(
    parent = mkinsub("SFO", to = "m1"),
    m1 = mkinsub("SFO")
  )
  d_t <- FOCUS_2006_D
  f_nw <- mkinfit(sfo_sfo, d_t, quiet = TRUE) # no weighting (weights are unity)
  f_obs <- mkinfit(sfo_sfo, d_t, error_model = "obs", quiet = TRUE)
  f_tc <- mkinfit(sfo_sfo, d_t, error_model = "tc", quiet = TRUE)
  AIC(f_nw, f_obs, f_tc)
  }
}
\author{
  Johannes Ranke
}
