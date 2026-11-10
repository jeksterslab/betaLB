// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-polish-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Verify and Refine a Native Likelihood Endpoint
//'
//' Newton refinement of KKT equations uses differences of analytic gradients,
//' a residual line search, and an independently recomputed final loss.
//' @author Ivan Jacob Agaloos Pesigan
//' @param par Initial endpoint coordinates.
//' @param sample Divisor-n analysis covariance.
//' @param units Original variable standard deviations.
//' @param target Native target descriptor.
//' @param n Analysis sample size.
//' @param cutoff Positive likelihood-ratio cutoff.
//' @param side One for minimizing, minus one for maximizing.
//' @param scale Positive objective normalization.
//' @param tolerance Normalized constraint and stationarity tolerance.
//' @param maxeval Remaining evaluation budget.
//' @return Verified endpoint record; invalid endpoints retain a failure flag.
//' @examples
//' # Exercised by reference/native endpoint comparisons.
//' @noRd
LBEndpoint LBPolish(const arma::vec& par, const arma::mat& sample,
                    const arma::vec& units, const LBTarget& target,
                    const double n, const double cutoff, const double side,
                    const double scale, const double tolerance,
                    const int maxeval) {
  LBEndpoint out;
  out.par = par;
  const arma::uword m = par.n_elem;
  LBState state = LBEvaluate(out.par, sample, units, target, n);
  ++out.evaluations;
  if (!state.valid ||
      arma::dot(state.loss_gradient, state.loss_gradient) == 0) {
    return out;
  }
  arma::vec h = state.loss_gradient / cutoff;
  double multiplier =
      -arma::dot(side * state.gradient / scale, h) / arma::dot(h, h);
  for (int iteration = 0; iteration < 12; ++iteration) {
    ++out.iterations;
    const arma::vec g = side * state.gradient / scale;
    h = state.loss_gradient / cutoff;
    arma::vec residual(m + 1);
    residual.head(m) = g + multiplier * h;
    residual(m) = state.loss / cutoff - 1;
    if (arma::abs(residual).max() < tolerance * 0.01) {
      break;
    }
    if (out.evaluations + static_cast<int>(2 * m + 2) >= maxeval) {
      break;
    }
    arma::mat hessian(m, m);
    bool valid = true;
    for (arma::uword j = 0; j < m; ++j) {
      const double delta = 1e-5 * (1 + std::abs(out.par(j)));
      arma::vec plus = out.par;
      arma::vec minus = out.par;
      plus(j) += delta;
      minus(j) -= delta;
      const LBState a = LBEvaluate(plus, sample, units, target, n);
      const LBState b = LBEvaluate(minus, sample, units, target, n);
      out.evaluations += 2;
      if (!a.valid || !b.valid) {
        valid = false;
        break;
      }
      hessian.col(j) =
          (side * (a.gradient - b.gradient) / scale +
           multiplier * (a.loss_gradient - b.loss_gradient) / cutoff) /
          (2 * delta);
    }
    if (!valid) {
      break;
    }
    hessian = (hessian + hessian.t()) / 2;
    arma::mat system(m + 1, m + 1, arma::fill::zeros);
    system.submat(0, 0, m - 1, m - 1) = hessian;
    system.submat(0, m, m - 1, m) = h;
    system.submat(m, 0, m, m - 1) = h.t();
    arma::vec step;
    if (!arma::solve(step, system, residual, arma::solve_opts::no_approx)) {
      break;
    }
    bool accepted = false;
    for (int j = 0; j <= 16 && out.evaluations + 1 < maxeval; ++j) {
      const double fraction = std::ldexp(1.0, -j);
      const arma::vec candidate = out.par - fraction * step.head(m);
      const double next_multiplier = multiplier - fraction * step(m);
      const LBState trial = LBEvaluate(candidate, sample, units, target, n);
      ++out.evaluations;
      if (!trial.valid) {
        continue;
      }
      arma::vec trial_residual(m + 1);
      trial_residual.head(m) = side * trial.gradient / scale +
                               next_multiplier * trial.loss_gradient / cutoff;
      trial_residual(m) = trial.loss / cutoff - 1;
      if (arma::dot(trial_residual, trial_residual) <
          arma::dot(residual, residual)) {
        out.par = candidate;
        state = trial;
        multiplier = next_multiplier;
        accepted = true;
        break;
      }
    }
    if (!accepted) {
      break;
    }
  }
  state = LBEvaluate(out.par, sample, units, target, n);
  ++out.evaluations;
  if (state.valid) {
    const arma::vec g = side * state.gradient / scale;
    h = state.loss_gradient / cutoff;
    out.constraint = std::abs(state.loss / cutoff - 1);
    out.stationarity =
        arma::abs(g + multiplier * h).max() /
        std::max(1.0, std::max(arma::abs(g).max(),
                               std::abs(multiplier) * arma::abs(h).max()));
    out.loss = state.loss;
    out.value = state.value;
    out.ok = multiplier >= -tolerance && out.constraint <= tolerance &&
             out.stationarity <= tolerance;
  }
  return out;
}
