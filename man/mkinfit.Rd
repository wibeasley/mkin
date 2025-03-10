\name{mkinfit}
\alias{mkinfit}
\title{
  Fit a kinetic model to data with one or more state variables
}
\description{
  This function maximises the likelihood of the observed data using
  the Port algorithm \code{\link{nlminb}}, and the specified initial or fixed
  parameters and starting values.  In each step of the optimsation, the kinetic
  model is solved using the function \code{\link{mkinpredict}}. The parameters
  of the selected error model are fitted simultaneously with the degradation
  model parameters, as both of them are arguments of the likelihood function.

  Per default, parameters in the kinetic models are internally transformed in
  order to better satisfy the assumption of a normal distribution of their
  estimators.
}
\usage{
mkinfit(mkinmod, observed,
  parms.ini = "auto",
  state.ini = "auto",
  err.ini = "auto",
  fixed_parms = NULL, fixed_initials = names(mkinmod$diffs)[-1],
  from_max_mean = FALSE,
  solution_type = c("auto", "analytical", "eigen", "deSolve"),
  method.ode = "lsoda",
  use_compiled = "auto",
  control = list(eval.max = 300, iter.max = 200),
  transform_rates = TRUE,
  transform_fractions = TRUE,
  quiet = FALSE,
  atol = 1e-8, rtol = 1e-10, n.outtimes = 100,
  error_model = c("const", "obs", "tc"),
  error_model_algorithm = c("d_3", "direct", "twostep", "threestep", "fourstep", "IRLS"),
  reweight.tol = 1e-8, reweight.max.iter = 10,
  trace_parms = FALSE, ...)
}
\arguments{
  \item{mkinmod}{
    A list of class \code{\link{mkinmod}}, containing the kinetic model to be
    fitted to the data, or one of the shorthand names ("SFO", "FOMC", "DFOP",
    "HS", "SFORB", "IORE"). If a shorthand name is given, a parent only degradation
    model is generated for the variable with the highest value in
    \code{observed}.
  }
  \item{observed}{
    A dataframe with the observed data.  The first column called "name" must
    contain the name of the observed variable for each data point. The second
    column must contain the times of observation, named "time".  The third
    column must be named "value" and contain the observed values. Zero values
    in the "value" column will be removed, with a warning, in order to
    avoid problems with fitting the two-component error model. This is not
    expected to be a problem, because in general, values of zero are not
    observed in degradation data, because there is a lower limit of detection.
  }
  \item{parms.ini}{
    A named vector of initial values for the parameters, including parameters
    to be optimised and potentially also fixed parameters as indicated by
    \code{fixed_parms}.  If set to "auto", initial values for rate constants
    are set to default values.  Using parameter names that are not in the model
    gives an error.

    It is possible to only specify a subset of the parameters that the model
    needs. You can use the parameter lists "bparms.ode" from a previously
    fitted model, which contains the differential equation parameters from this
    model. This works nicely if the models are nested. An example is given
    below.
  }
  \item{state.ini}{
    A named vector of initial values for the state variables of the model. In
    case the observed variables are represented by more than one model
    variable, the names will differ from the names of the observed variables
    (see \code{map} component of \code{\link{mkinmod}}). The default is to set
    the initial value of the first model variable to the mean of the time zero
    values for the variable with the maximum observed value, and all others to 0.
    If this variable has no time zero observations, its initial value is set to 100.
  }
  \item{err.ini}{
    A named vector of initial values for the error model parameters to be
    optimised.  If set to "auto", initial values are set to default values.
    Otherwise, inital values for all error model parameters must be
    given.
  }
  \item{fixed_parms}{
    The names of parameters that should not be optimised but rather kept at the
    values specified in \code{parms.ini}.
  }
  \item{fixed_initials}{
    The names of model variables for which the initial state at time 0 should
    be excluded from the optimisation. Defaults to all state variables except
    for the first one.
  }
  \item{from_max_mean}{
    If this is set to TRUE, and the model has only one observed variable, then
    data before the time of the maximum observed value (after averaging for each
    sampling time) are discarded, and this time is subtracted from all
    remaining time values, so the time of the maximum observed mean value is
    the new time zero.
  }
  \item{solution_type}{
    If set to "eigen", the solution of the system of differential equations is
    based on the spectral decomposition of the coefficient matrix in cases that
    this is possible. If set to "deSolve", a numerical ode solver from package
    \code{\link{deSolve}} is used. If set to "analytical", an analytical
    solution of the model is used. This is only implemented for simple
    degradation experiments with only one state variable, i.e. with no
    metabolites. The default is "auto", which uses "analytical" if possible,
    otherwise "deSolve" if a compiler is present, and "eigen" if no
    compiler is present and the model can be expressed using eigenvalues and
    eigenvectors.  This argument is passed on to the helper function
    \code{\link{mkinpredict}}.
  }
  \item{method.ode}{
    The solution method passed via \code{\link{mkinpredict}} to
    \code{\link{ode}} in case the solution type is "deSolve". The default
    "lsoda" is performant, but sometimes fails to converge.
  }
  \item{use_compiled}{
    If set to \code{FALSE}, no compiled version of the \code{\link{mkinmod}}
    model is used in the calls to \code{\link{mkinpredict}} even if a compiled
    version is present.
  }
  \item{control}{
    A list of control arguments passed to \code{\link{nlminb}}.
  }
  \item{transform_rates}{
    Boolean specifying if kinetic rate constants should be transformed in the
    model specification used in the fitting for better compliance with the
    assumption of normal distribution of the estimator. If TRUE, also
    alpha and beta parameters of the FOMC model are log-transformed, as well
    as k1 and k2 rate constants for the DFOP and HS models and the break point
    tb of the HS model.  If FALSE, zero is used as a lower bound for the rates
    in the optimisation.
  }
  \item{transform_fractions}{
    Boolean specifying if formation fractions constants should be transformed in the
    model specification used in the fitting for better compliance with the
    assumption of normal distribution of the estimator. The default (TRUE) is
    to do transformations. If TRUE, the g parameter of the DFOP and HS
    models are also transformed, as they can also be seen as compositional
    data. The transformation used for these transformations is the
    \code{\link{ilr}} transformation.
  }
  \item{quiet}{
    Suppress printing out the current value of the negative log-likelihood
    after each improvement?
  }
  \item{atol}{
    Absolute error tolerance, passed to \code{\link{ode}}. Default is 1e-8,
    lower than in \code{\link{lsoda}}.
  }
  \item{rtol}{
    Absolute error tolerance, passed to \code{\link{ode}}. Default is 1e-10,
    much lower than in \code{\link{lsoda}}.
  }
  \item{n.outtimes}{
    The length of the dataseries that is produced by the model prediction
    function \code{\link{mkinpredict}}. This impacts the accuracy of
    the numerical solver if that is used (see \code{solution_type} argument.
    The default value is 100.
  }
  \item{error_model}{
    If the error model is "const", a constant standard deviation
    is assumed.

    If the error model is "obs", each observed variable is assumed to have its
    own variance.

    If the error model is "tc" (two-component error model), a two component
    error model similar to the one described by Rocke and Lorenzato (1995) is
    used for setting up the likelihood function.  Note that this model deviates
    from the model by Rocke and Lorenzato, as their model implies that the
    errors follow a lognormal distribution for large values, not a normal
    distribution as assumed by this method.
  }
  \item{error_model_algorithm}{
    If the error model is "const", the error model algorithm is ignored,
    because no special algorithm is needed and unweighted (also known as
    ordinary) least squares fitting can be applied.

    The default algorithm "d_3" will directly minimize the negative
    log-likelihood and - independently - also use the three step algorithm
    described below. The fit with the higher likelihood is returned.

    The algorithm "direct" will directly minimize the negative
    log-likelihood.

    The algorithm "twostep" will minimize the negative log-likelihood
    after an initial unweighted leas squares optimisation step.

    The algorithm "threestep" starts with unweighted least squares,
    then optimizes only the error model using the degradation model
    parameters found, and then minimizes the negative log-likelihood
    with free degradation and error model parameters.

    The algorithm "fourstep" starts with unweighted least squares,
    then optimizes only the error model using the degradation model
    parameters found, then optimizes the degradation model again
    with fixed error model parameters, and finally minimizes the negative
    log-likelihood with free degradation and error model parameters.

    The algorithm "IRLS" starts with unweighted least squares,
    and then iterates optimization of the error model parameters and subsequent
    optimization of the degradation model using those error model parameters,
    until the error model parameters converge.
  }
  \item{reweight.tol}{
    Tolerance for the convergence criterion calculated from the error model
    parameters in IRLS fits.
  }
  \item{reweight.max.iter}{
    Maximum number of iterations in IRLS fits.
  }
  \item{trace_parms}{
    Should a trace of the parameter values be listed?
  }
  \item{\dots}{
    Further arguments that will be passed on to \code{\link{deSolve}}.
  }
}
\value{
  A list with "mkinfit" in the class attribute.  A summary can be obtained by
  \code{\link{summary.mkinfit}}.
}
\seealso{
  Plotting methods \code{\link{plot.mkinfit}} and \code{\link{mkinparplot}}.

  Comparisons of models fitted to the same data can be made using \code{\link{AIC}}
  by virtue of the method \code{\link{logLik.mkinfit}}.

  Fitting of several models to several datasets in a single call to
  \code{\link{mmkin}}.
}
\note{
  When using the "IORE" submodel for metabolites, fitting with
  "transform_rates = TRUE" (the default) often leads to failures of the
  numerical ODE solver. In this situation it may help to switch off the
  internal rate transformation.
}
\source{
  Rocke, David M. und Lorenzato, Stefan (1995) A two-component model for
  measurement error in analytical chemistry. Technometrics 37(2), 176-184.
}
\author{
  Johannes Ranke
}
\examples{
# Use shorthand notation for parent only degradation
fit <- mkinfit("FOMC", FOCUS_2006_C, quiet = TRUE)
summary(fit)

# One parent compound, one metabolite, both single first order.
# Use mkinsub for convenience in model formulation. Pathway to sink included per default.
SFO_SFO <- mkinmod(
  parent = mkinsub("SFO", "m1"),
  m1 = mkinsub("SFO"))
# Fit the model to the FOCUS example dataset D using defaults
print(system.time(fit <- mkinfit(SFO_SFO, FOCUS_2006_D,
                           solution_type = "eigen", quiet = TRUE)))
coef(fit)
endpoints(fit)
\dontrun{
# deSolve is slower when no C compiler (gcc) was available during model generation
print(system.time(fit.deSolve <- mkinfit(SFO_SFO, FOCUS_2006_D,
                           solution_type = "deSolve")))
coef(fit.deSolve)
endpoints(fit.deSolve)
}

# Use stepwise fitting, using optimised parameters from parent only fit, FOMC
\dontrun{
FOMC_SFO <- mkinmod(
  parent = mkinsub("FOMC", "m1"),
  m1 = mkinsub("SFO"))
# Fit the model to the FOCUS example dataset D using defaults
fit.FOMC_SFO <- mkinfit(FOMC_SFO, FOCUS_2006_D, quiet = TRUE)
# Use starting parameters from parent only FOMC fit
fit.FOMC = mkinfit("FOMC", FOCUS_2006_D, quiet = TRUE)
fit.FOMC_SFO <- mkinfit(FOMC_SFO, FOCUS_2006_D, quiet = TRUE,
  parms.ini = fit.FOMC$bparms.ode)

# Use stepwise fitting, using optimised parameters from parent only fit, SFORB
SFORB_SFO <- mkinmod(
  parent = list(type = "SFORB", to = "m1", sink = TRUE),
  m1 = list(type = "SFO"))
# Fit the model to the FOCUS example dataset D using defaults
fit.SFORB_SFO <- mkinfit(SFORB_SFO, FOCUS_2006_D, quiet = TRUE)
fit.SFORB_SFO.deSolve <- mkinfit(SFORB_SFO, FOCUS_2006_D, solution_type = "deSolve",
                                 quiet = TRUE)
# Use starting parameters from parent only SFORB fit (not really needed in this case)
fit.SFORB = mkinfit("SFORB", FOCUS_2006_D, quiet = TRUE)
fit.SFORB_SFO <- mkinfit(SFORB_SFO, FOCUS_2006_D, parms.ini = fit.SFORB$bparms.ode, quiet = TRUE)
}

\dontrun{
# Weighted fits, including IRLS
SFO_SFO.ff <- mkinmod(parent = mkinsub("SFO", "m1"),
                      m1 = mkinsub("SFO"), use_of_ff = "max")
f.noweight <- mkinfit(SFO_SFO.ff, FOCUS_2006_D, quiet = TRUE)
summary(f.noweight)
f.obs <- mkinfit(SFO_SFO.ff, FOCUS_2006_D, error_model = "obs", quiet = TRUE)
summary(f.obs)
f.tc <- mkinfit(SFO_SFO.ff, FOCUS_2006_D, error_model = "tc", quiet = TRUE)
summary(f.tc)
}

}
\keyword{ optimize }
