// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-r-sq-endpoint-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Construct and Verify a Multiple-Correlation Profile Endpoint
//'
//' Whiten predictors and reduce the covariance problem to its response/signal
//' plane. This avoids a singular KKT system for a zero multiple correlation.
//' @author Ivan Jacob Agaloos Pesigan
//' @param sample Divisor-n covariance matrix.
//' @param units Original variable standard deviations.
//' @param target An eligible correlation or full-block target.
//' @param n Analysis sample size.
//' @param cutoff Fixed LR cutoff, retaining the chosen calibration dimension.
//' @param side One for minimizing, minus one for maximizing.
//' @param scale Objective normalization for verification.
//' @param tolerance Normalized verification tolerance.
//' @return Analytically constructed endpoint with independently checked LR/KKT.
//' @examples
//' # Compared with SLSQP at zero and away from zero in the native tests.
//' @noRd
LBEndpoint LBRsqEndpoint(const arma::mat& sample, const arma::vec& units,
                         const LBTarget& target, const double n,
                         const double cutoff, const double side,
                         const double scale, const double tolerance) {
  LBEndpoint out;
  const arma::uword p = sample.n_rows - 1;
  const arma::mat a = sample.submat(1, 1, p, p);
  const double vy = sample(0, 0);
  arma::mat l;
  arma::vec signal;
  if (!arma::chol(l, a, "lower") ||
      !arma::solve(signal, arma::trimatl(l), sample.col(0).tail(p),
                   arma::solve_opts::no_approx)) {
    return out;
  }
  signal /= std::sqrt(vy);
  double r = arma::norm(signal);
  arma::vec direction(p, arma::fill::zeros);
  if (p == 1 && !target.squared) {
    r = signal(0);
    direction(0) = 1;
  } else if (r > 0) {
    direction = signal / r;
  } else {
    direction(0) = 1;
  }
  const double residual = 1 - r * r;
  const double weight = std::exp(cutoff / n) * residual;
  const double root = std::sqrt(weight * residual * std::expm1(cutoff / n));
  const double rho = (r - side * root) / (r * r + weight);
  if (!std::isfinite(rho) || std::abs(rho) >= 1 ||
      (target.squared && side > 0 && rho < 0)) {
    return out;
  }
  const double factor = (1 - r * rho) / (1 - rho * rho);
  arma::mat sigma = sample;
  sigma(0, 0) = vy * factor;
  sigma.submat(1, 1, p, p) =
      l * (arma::eye(p, p) + (factor - 1) * direction * direction.t()) * l.t();
  const arma::vec cross = std::sqrt(vy) * l * (rho * factor * direction);
  sigma.submat(1, 0, p, 0) = cross;
  sigma.submat(0, 1, 0, p) = cross.t();
  arma::mat candidate_l;
  if (!arma::chol(candidate_l, sigma, "lower")) {
    return out;
  }
  out.par.set_size(sample.n_rows * (sample.n_rows + 1) / 2);
  arma::uword q = 0;
  for (arma::uword j = 0; j < sample.n_rows; ++j) {
    for (arma::uword i = j; i < sample.n_rows; ++i, ++q) {
      out.par(q) = i == j ? std::log(candidate_l(i, i)) : candidate_l(i, j);
    }
  }
  const LBState state = LBEvaluate(out.par, sample, units, target, n);
  out.evaluations = 1;
  if (!state.valid) {
    return out;
  }
  const arma::vec g = side * state.gradient / scale;
  const arma::vec h = state.loss_gradient / cutoff;
  const double multiplier = -arma::dot(g, h) / arma::dot(h, h);
  out.constraint = std::abs(state.loss / cutoff - 1);
  out.stationarity =
      arma::abs(g + multiplier * h).max() /
      std::max(1.0, std::max(arma::abs(g).max(),
                             std::abs(multiplier) * arma::abs(h).max()));
  out.value = state.value;
  out.loss = state.loss;
  out.ok = multiplier >= -tolerance && out.constraint <= tolerance &&
           out.stationarity <= tolerance;
  return out;
}
