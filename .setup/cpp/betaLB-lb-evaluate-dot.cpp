// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-evaluate-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Evaluate Native Likelihood and Target Gradients
//'
//' Chain covariance derivatives through logged Cholesky coordinates.
//' @author Ivan Jacob Agaloos Pesigan
//' @param par Unconstrained Cholesky coordinates in lower-column order.
//' @param sample Positive-definite divisor-n sample covariance.
//' @param units Original variable standard deviations.
//' @param target Validated native target descriptor.
//' @param n Analysis sample size.
//' @return Native evaluation record, marked invalid on numerical failure.
//' @examples
//' # Compared with the independent R evaluation in native tests.
//' @noRd
LBState LBEvaluate(const arma::vec& par, const arma::mat& sample,
                   const arma::vec& units, const LBTarget& target,
                   const double n) {
  LBState out;
  const arma::uword k = sample.n_rows;
  const arma::uword m = k * (k + 1) / 2;
  if (par.n_elem != m || !par.is_finite()) {
    return out;
  }
  arma::mat l(k, k, arma::fill::zeros);
  arma::uword q = 0;
  for (arma::uword j = 0; j < k; ++j) {
    for (arma::uword i = j; i < k; ++i, ++q) {
      l(i, j) = i == j ? std::exp(par(q)) : par(q);
    }
  }
  if (!l.is_finite() || arma::any(l.diag() <= 0)) {
    return out;
  }
  const arma::mat sigma = l * l.t();
  arma::mat sample_l, inv_u, temp, white;
  if (!arma::chol(sample_l, sample, "lower") ||
      !arma::solve(inv_u, arma::trimatu(l.t()), arma::eye(k, k),
                   arma::solve_opts::no_approx) ||
      !arma::solve(temp, arma::trimatl(l), sample,
                   arma::solve_opts::no_approx) ||
      !arma::solve(white, arma::trimatl(l), temp.t(),
                   arma::solve_opts::no_approx)) {
    return out;
  }
  out.loss = n * (2 * arma::sum(arma::log(l.diag())) -
                  2 * arma::sum(arma::log(sample_l.diag())) +
                  arma::trace(white) - static_cast<double>(k));
  const arma::mat inverse = inv_u * inv_u.t();
  const arma::mat loss_g = n * (inverse - inverse * sample * inverse);
  const arma::mat loss_l = 2 * loss_g * l;
  const arma::mat effect = LBEffect(sigma, units, target);
  if (!effect.is_finite()) {
    return out;
  }
  out.smooth = effect.col(0);
  out.jacobian = effect.cols(1, m);
  arma::vec derivative;
  if (target.squared) {
    out.value = arma::dot(out.smooth, out.smooth);
    derivative = 2 * out.jacobian.t() * out.smooth;
  } else {
    out.value = out.smooth(0);
    derivative = out.jacobian.row(0).t();
  }
  arma::mat g(k, k, arma::fill::zeros);
  q = 0;
  for (arma::uword j = 0; j < k; ++j) {
    for (arma::uword i = j; i < k; ++i, ++q) {
      g(i, j) = g(j, i) = derivative(q) * (i == j ? 1.0 : 0.5);
    }
  }
  const arma::mat target_l = 2 * g * l;
  out.gradient.set_size(m);
  out.loss_gradient.set_size(m);
  q = 0;
  for (arma::uword j = 0; j < k; ++j) {
    for (arma::uword i = j; i < k; ++i, ++q) {
      const double factor = i == j ? l(i, i) : 1;
      out.gradient(q) = target_l(i, j) * factor;
      out.loss_gradient(q) = loss_l(i, j) * factor;
    }
  }
  out.valid = std::isfinite(out.value) && std::isfinite(out.loss) &&
              out.gradient.is_finite() && out.loss_gradient.is_finite();
  return out;
}
