# Copyright (C) 2019 Johannes Ranke
# Contact: jranke@uni-bremen.de

# This file is part of the R package mkin

# mkin is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>

context("Special cases of mkinfit calls")

SFO_SFO.ff.nosink <- mkinmod(
  parent = mkinsub("SFO", "m1", sink = FALSE),
  m1 = mkinsub("SFO"), quiet = TRUE, use_of_ff = "max")

SFO_SFO.ff <- mkinmod(
  parent = mkinsub("SFO", "m1"),
  m1 = mkinsub("SFO"), quiet = TRUE, use_of_ff = "max")

test_that("mkinfit stops to prevent and/or explain user errors", {
  expect_error(mkinfit("foo", FOCUS_2006_A))
  expect_error(mkinfit(3, FOCUS_2006_A))

  # We remove zero observations from FOCUS_2006_D beforehand in
  # order to avoid another expect_warning in the code
  FOCUS_2006_D <- subset(FOCUS_2006_D, value != 0)
  # We get a warning if we use transform_fractions = FALSE with formation fractions
  # and an error if any pathway to sink is turned off as well
  expect_warning(
    expect_error(
      mkinfit(SFO_SFO.ff.nosink, FOCUS_2006_D, transform_fractions = FALSE, quiet = TRUE),
      "turn off pathways to sink"
      ),
    "sum of formation fractions")

  expect_error(mkinfit(SFO_SFO.ff, FOCUS_2006_D, transform_fractions = TRUE,
                       parms.ini = c(f_parent_to_m1 = 0.5), fixed_parms = "f_parent_to_m1", quiet = TRUE),
   "not supported")

  expect_error(mkinfit(SFO_SFO.ff, FOCUS_2006_D,
                       parms.ini = c(f_parent_to_m1 = 1.1), quiet = TRUE),
   "sum up to more than 1")

  expect_error(mkinfit(SFO_SFO.ff, FOCUS_2006_D, solution_type = "analytical"), "not implemented")

  expect_error(mkinfit("FOMC", FOCUS_2006_A, solution_type = "eigen"), "coefficient matrix not present")
})

test_that("mkinfit stops early when a low maximum number of iterations is specified", {
  expect_warning(mkinfit("SFO", FOCUS_2006_A, control = list(iter.max = 1), quiet = TRUE),
                 "iteration limit reached without convergence")
})

test_that("mkinfit warns if a specified initial parameter value is not in the model", {
  expect_warning(mkinfit("SFO", FOCUS_2006_A, parms.ini = c(k_xy = 0.1), quiet = TRUE),
                 "not used in the model")
})

test_that("We get reproducible output if quiet = FALSE", {
  # We cannot expect parameter and sum of squares traces to be the same across platforms
  skip_on_cran()
  skip_on_travis()
  expect_known_output(mkinfit("DFOP", FOCUS_2006_C, reweight.method = "tc", trace_parms = TRUE),
    file = "DFOP_FOCUS_C_messages.txt")
})

test_that("We get warnings in case of overparameterisation", {
  skip_on_cran() # On winbuilder the following fit does not give a warning
  skip_on_travis() # Neither on travis
  expect_warning(f <- mkinfit("FOMC", FOCUS_2006_A, quiet = TRUE), "not converge")
  # We do get Hessians and the related output after the switch to using numDeriv::hessian()
  #s2 <- expect_warning(summary(mkinfit("DFOP", FOCUS_2006_A, quiet = TRUE)), "singular system")
})
