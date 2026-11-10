// -----------------------------------------------------------------------------
// edit .setup/cpp/000-forward-declarations.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
#include <RcppArmadillo.h>

#include <algorithm>
#include <cmath>
#include <limits>
#include <string>
#include <vector>

struct LBTarget {
  int family;
  arma::uvec index;
  arma::vec std_x;
  bool std_y;
  bool squared;
};
struct LBState {
  bool valid = false;
  double value = arma::datum::nan;
  double loss = arma::datum::nan;
  arma::vec gradient;
  arma::vec loss_gradient;
  arma::vec smooth;
  arma::mat jacobian;
};
struct LBEndpoint {
  bool ok = false;
  arma::vec par;
  double value = arma::datum::nan;
  double loss = arma::datum::nan;
  double constraint = arma::datum::inf;
  double stationarity = arma::datum::inf;
  int evaluations = 0;
  int iterations = 0;
  int retries = 0;
};

arma::mat LBEffect(const arma::mat& sigma, const arma::vec& units,
                   const LBTarget& target);
LBState LBEvaluate(const arma::vec& par, const arma::mat& sample,
                   const arma::vec& units, const LBTarget& target,
                   const double n);
LBEndpoint LBPolish(const arma::vec& par, const arma::mat& sample,
                    const arma::vec& units, const LBTarget& target,
                    const double n, const double cutoff, const double side,
                    const double scale, const double tolerance,
                    const int maxeval);
LBEndpoint LBRsqEndpoint(const arma::mat& sample, const arma::vec& units,
                         const LBTarget& target, const double n,
                         const double cutoff, const double side,
                         const double scale, const double tolerance);
LBEndpoint LBSolve(const arma::mat& starts, const arma::mat& sample,
                   const arma::vec& units, const LBTarget& target,
                   const double n, const double cutoff, const double side,
                   const double scale, const double tolerance,
                   const int maxeval);
Rcpp::List LBBatchCpp(const arma::mat& sample, const arma::vec& units,
                      const double n, const Rcpp::List& requests,
                      const double tolerance, const int maxeval);
Rcpp::List LBInspectCpp(const arma::vec& par, const arma::mat& sample,
                        const arma::vec& units, const double n,
                        const int family, const arma::uvec& index,
                        const arma::vec& std_x, const bool std_y,
                        const bool squared);
arma::mat SymofVechCpp(const arma::rowvec& x, const arma::uword k);
Rcpp::List StrRegressionofVechSigmaMat(const arma::mat& vechsigmacap,
                                       const arma::uword k);
// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-batch-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Solve All Requested Likelihood Intervals in One Native Call
//'
//' Retain verified failures and warm-start repeated targets across cutoffs.
//' @author Ivan Jacob Agaloos Pesigan
//' @param sample Divisor-n sample covariance.
//' @param units Original variable standard deviations.
//' @param n Analysis sample size.
//' @param requests Validated targets and solver settings.
//' @param tolerance Normalized endpoint verification tolerance.
//' @param maxeval Maximum evaluation budget per endpoint.
//' @return Lower/upper endpoint records for every request.
//' @examples
//' # Called by LB() after input validation and calibration.
//' @noRd
// [[Rcpp::export(.LBBatchCpp)]]
Rcpp::List LBBatchCpp(const arma::mat& sample, const arma::vec& units,
                      const double n, const Rcpp::List& requests,
                      const double tolerance, const int maxeval) {
  Rcpp::List results(requests.size());
  arma::vec warm;
  std::string last_key;
  for (R_xlen_t i = 0; i < requests.size(); ++i) {
    Rcpp::checkUserInterrupt();
    const Rcpp::List request = requests[i];
    const LBTarget target{Rcpp::as<int>(request["family"]),
                          Rcpp::as<arma::uvec>(request["index"]),
                          Rcpp::as<arma::vec>(request["std_x"]),
                          Rcpp::as<bool>(request["std_y"]),
                          Rcpp::as<bool>(request["squared"])};
    arma::mat starts = Rcpp::as<arma::mat>(request["starts"]);
    const double cutoff = Rcpp::as<double>(request["cutoff"]);
    const double scale = Rcpp::as<double>(request["scale"]);
    const std::string key = Rcpp::as<std::string>(request["key"]);
    if (last_key == key && warm.n_elem == starts.n_rows) {
      starts.insert_cols(starts.n_cols, warm);
    }
    Rcpp::List endpoints(2);
    for (int side_id = 0; side_id < 2; ++side_id) {
      LBEndpoint endpoint;
      bool boundary = false;
      if (target.squared && side_id == 0 &&
          Rcpp::as<double>(request["null_lr"]) <= cutoff) {
        const arma::vec null_par = Rcpp::as<arma::vec>(request["null_par"]);
        const LBState zero = LBEvaluate(null_par, sample, units, target, n);
        boundary = zero.valid && std::abs(zero.value) <= tolerance &&
                   zero.loss <= cutoff * (1 + tolerance);
        if (boundary) {
          endpoint.ok = true;
          endpoint.par = null_par;
          endpoint.value = 0;
          endpoint.loss = zero.loss;
          endpoint.constraint = 0;
          endpoint.stationarity = 0;
          endpoint.evaluations = 1;
        }
      }
      if (!boundary) {
        endpoint =
            LBSolve(starts, sample, units, target, n, cutoff,
                    side_id == 0 ? 1.0 : -1.0, scale, tolerance, maxeval);
      }
      const std::string status =
          boundary ? "boundary_zero"
                   : (endpoint.ok ? "ok"
                                  : (endpoint.evaluations >= maxeval
                                         ? "max_eval_failed"
                                         : "verification_failed"));
      endpoints[side_id] = Rcpp::List::create(
          Rcpp::Named("bound") = endpoint.ok ? endpoint.value : NA_REAL,
          Rcpp::Named("status") = status, Rcpp::Named("par") = endpoint.par,
          Rcpp::Named("lr") = endpoint.loss,
          Rcpp::Named("constraint") = endpoint.constraint,
          Rcpp::Named("stationarity") = endpoint.stationarity,
          Rcpp::Named("evaluations") = endpoint.evaluations,
          Rcpp::Named("iterations") = endpoint.iterations,
          Rcpp::Named("retries") = endpoint.retries,
          Rcpp::Named("backend") = "cpp");
      if (endpoint.ok) {
        warm = endpoint.par;
        last_key = key;
      }
    }
    results[i] = endpoints;
  }
  return results;
}
// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-effect-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Smooth Regression Effects and Analytic Covariance Derivatives
//'
//' Differentiate covariance algebra and the symmetric inverse square root.
//' @author Ivan Jacob Agaloos Pesigan
//' @param sigma Candidate covariance in standardized analysis units.
//' @param units Original variable standard deviations.
//' @param target Validated native effect descriptor.
//' @return Matrix: smooth values then lower-triangle derivatives in columns.
//' @examples
//' # Validated against .LBEffect() by the native evaluation tests.
//' @noRd
arma::mat LBEffect(const arma::mat& sigma, const arma::vec& units,
                   const LBTarget& target) {
  const arma::uword k = sigma.n_rows;
  const arma::uword p = k - 1;
  const arma::uword m = k * (k + 1) / 2;
  arma::uvec idx = target.index;
  if (target.family == 5) {
    idx = arma::regspace<arma::uvec>(0, p - 1);
  }
  const bool vector_target = target.family >= 5;
  const arma::uword r = vector_target ? idx.n_elem : 1;
  arma::mat out(r, m + 1, arma::fill::value(arma::datum::nan));
  const arma::mat raw = sigma % (units * units.t());
  const arma::mat a = raw.submat(1, 1, p, p);
  const arma::vec c = raw.col(0).tail(p);
  const double vy = raw(0, 0);
  arma::mat inverse;
  if (!arma::inv_sympd(inverse, a)) {
    return out;
  }
  const arma::vec beta = inverse * c;
  const double error = vy - arma::dot(c, beta);
  if (!(vy > 0 && error > 0)) {
    return out;
  }
  arma::vec beta_scale(p);
  for (arma::uword j = 0; j < p; ++j) {
    beta_scale(j) = std::pow(a(j, j), target.std_x(j) / 2) /
                    std::pow(vy, target.std_y ? 0.5 : 0.0);
  }
  arma::vec value(r);
  double vj = 0;
  double denominator = vy;
  arma::uvec complement;
  arma::mat a_cond, inverse_c, projection, eigvec, inverse_root;
  arma::vec c_cond, beta_c, sd_cond, roots, r_vec;
  if (target.family <= 1) {
    value(0) = beta(idx(0)) * beta_scale(idx(0));
    if (target.family == 1) {
      value(0) -= beta(idx(1)) * beta_scale(idx(1));
    }
  } else if (!vector_target) {
    const arma::uword j = idx(0);
    vj = 1 / inverse(j, j);
    if (target.family == 3) {
      denominator = error + beta(j) * beta(j) * vj;
    } else if (target.family == 4) {
      denominator = error;
    }
    value(0) = beta(j) * std::sqrt(vj / denominator);
  } else {
    std::vector<arma::uword> other;
    for (arma::uword j = 0; j < p; ++j) {
      if (!arma::any(idx == j)) {
        other.push_back(j);
      }
    }
    complement = arma::conv_to<arma::uvec>::from(other);
    a_cond = a.submat(idx, idx);
    c_cond = c.elem(idx);
    if (complement.n_elem > 0) {
      if (!arma::inv_sympd(inverse_c, a.submat(complement, complement))) {
        return out;
      }
      projection = inverse_c * a.submat(complement, idx);
      beta_c = inverse_c * c.elem(complement);
      a_cond -= a.submat(idx, complement) * projection;
      c_cond -= a.submat(idx, complement) * beta_c;
    }
    sd_cond = arma::sqrt(a_cond.diag());
    const arma::mat corr = a_cond / (sd_cond * sd_cond.t());
    arma::vec eigval;
    if (!arma::eig_sym(eigval, eigvec, corr) || eigval.min() <= 0) {
      return out;
    }
    roots = arma::sqrt(eigval);
    inverse_root = eigvec * arma::diagmat(1 / roots) * eigvec.t();
    denominator = target.family == 7 ? error : vy;
    r_vec = c_cond / sd_cond / std::sqrt(denominator);
    value = inverse_root * r_vec;
  }
  out.col(0) = value;
  arma::uword q = 0;
  for (arma::uword col = 0; col < k; ++col) {
    for (arma::uword row = col; row < k; ++row, ++q) {
      arma::mat ds(k, k, arma::fill::zeros);
      ds(row, col) = ds(col, row) = units(row) * units(col);
      const arma::mat da = ds.submat(1, 1, p, p);
      const arma::vec dc = ds.col(0).tail(p);
      const double dvy = ds(0, 0);
      const arma::vec dbeta = inverse * (dc - da * beta);
      const double derror =
          dvy - 2 * arma::dot(dc, beta) + arma::as_scalar(beta.t() * da * beta);
      arma::vec derivative(r);
      if (target.family <= 1) {
        arma::vec db(p);
        for (arma::uword j = 0; j < p; ++j) {
          db(j) = beta_scale(j) * dbeta(j) +
                  beta(j) * beta_scale(j) *
                      (target.std_x(j) * da(j, j) / a(j, j) / 2 -
                       (target.std_y ? dvy / vy / 2 : 0));
        }
        derivative(0) = db(idx(0));
        if (target.family == 1) {
          derivative(0) -= db(idx(1));
        }
      } else if (!vector_target) {
        const arma::uword j = idx(0);
        const double dvj =
            vj * vj * arma::as_scalar(inverse.row(j) * da * inverse.col(j));
        double dd = dvy;
        if (target.family == 3) {
          dd = derror + 2 * beta(j) * dbeta(j) * vj + beta(j) * beta(j) * dvj;
        } else if (target.family == 4) {
          dd = derror;
        }
        derivative(0) = dbeta(j) * std::sqrt(vj / denominator) +
                        value(0) / 2 * (dvj / vj - dd / denominator);
      } else {
        arma::mat dac = da.submat(idx, idx);
        arma::vec dcc = dc.elem(idx);
        if (complement.n_elem > 0) {
          const arma::mat datc = da.submat(idx, complement);
          const arma::mat dacc = da.submat(complement, complement);
          dac -= datc * projection + projection.t() * datc.t() -
                 projection.t() * dacc * projection;
          dcc -= datc * beta_c + a.submat(idx, complement) * inverse_c *
                                     (dc.elem(complement) - dacc * beta_c);
        }
        const arma::vec ratio = dac.diag() / a_cond.diag() / 2;
        const arma::mat corr = a_cond / (sd_cond * sd_cond.t());
        const arma::mat dr =
            dac / (sd_cond * sd_cond.t()) -
            corr % (arma::repmat(ratio, 1, r) + arma::repmat(ratio.t(), r, 1));
        const double dd = target.family == 7 ? derror : dvy;
        const arma::vec drvec = dcc / sd_cond / std::sqrt(denominator) -
                                r_vec % (ratio + dd / denominator / 2);
        arma::mat divided(r, r);
        for (arma::uword i = 0; i < r; ++i) {
          for (arma::uword j = 0; j < r; ++j) {
            divided(i, j) = -1 / (roots(i) * roots(j) * (roots(i) + roots(j)));
          }
        }
        const arma::mat droot =
            eigvec * (divided % (eigvec.t() * dr * eigvec)) * eigvec.t();
        derivative = inverse_root * drvec + droot * r_vec;
      }
      out.col(q + 1) = derivative;
    }
  }
  return out;
}
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
// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-inspect-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Inspect Native Likelihood Algebra for Independent Tests
//'
//' Expose values and derivatives without running the endpoint optimizer.
//' @author Ivan Jacob Agaloos Pesigan
//' @param par Logged lower-Cholesky coordinates.
//' @param sample Divisor-n sample covariance.
//' @param units Original variable standard deviations.
//' @param n Analysis sample size.
//' @param family Native target-family index, zero through seven.
//' @param index Zero-based predictor indices.
//' @param std_x Numeric zero/one standardization flags for predictors.
//' @param std_y Whether to standardize the response.
//' @param squared Whether to evaluate the smooth vector's squared norm.
//' @return Values, gradients, Jacobian and numerical validity flag.
//' @examples
//' # See test-betaLB-native.R for independent R comparisons.
//' @noRd
// [[Rcpp::export(.LBInspectCpp)]]
Rcpp::List LBInspectCpp(const arma::vec& par, const arma::mat& sample,
                        const arma::vec& units, const double n,
                        const int family, const arma::uvec& index,
                        const arma::vec& std_x, const bool std_y,
                        const bool squared) {
  const LBTarget target{family, index, std_x, std_y, squared};
  const LBState out = LBEvaluate(par, sample, units, target, n);
  return Rcpp::List::create(
      Rcpp::Named("valid") = out.valid, Rcpp::Named("value") = out.value,
      Rcpp::Named("loss") = out.loss, Rcpp::Named("gradient") = out.gradient,
      Rcpp::Named("loss_gradient") = out.loss_gradient,
      Rcpp::Named("smooth") = out.smooth,
      Rcpp::Named("jacobian") = out.jacobian);
}
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
// -----------------------------------------------------------------------------
// edit .setup/cpp/betaLB-lb-solve-dot.cpp
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------
//' Solve One Native Likelihood-Region Endpoint
//'
//' A safeguarded BFGS augmented-Lagrangian search precedes KKT verification.
//' The algorithm never substitutes a clipped or Wald endpoint on failure.
//' @author Ivan Jacob Agaloos Pesigan
//' @param starts Deterministic initial parameter vectors in columns.
//' @param sample Divisor-n covariance.
//' @param units Original variable standard deviations.
//' @param target Native target descriptor.
//' @param n Analysis sample size.
//' @param cutoff Positive fixed LR cutoff.
//' @param side One for a lower bound, minus one for an upper bound.
//' @param scale Positive objective normalization.
//' @param tolerance Normalized verification tolerance.
//' @param maxeval Evaluation budget for this endpoint.
//' @return Best verified endpoint or an explicit failure record.
//' @examples
//' # Independently compared with test-only nloptr SLSQP.
//' @noRd
LBEndpoint LBSolve(const arma::mat& starts, const arma::mat& sample,
                   const arma::vec& units, const LBTarget& target,
                   const double n, const double cutoff, const double side,
                   const double scale, const double tolerance,
                   const int maxeval) {
  LBEndpoint best;
  int evaluations = 0;
  int iterations = 0;
  int starts_tried = 0;
  const arma::uword m = starts.n_rows;
  const LBState baseline = LBEvaluate(starts.col(0), sample, units, target, n);
  ++evaluations;
  if (!baseline.valid) {
    return best;
  }
  const arma::uword p = sample.n_rows - 1;
  const bool scalar_correlation =
      p == 1 && ((target.family >= 2) ||
                 (target.family == 0 && target.std_y && target.std_x(0) == 1));
  const bool full_block = target.family >= 5 && target.index.n_elem == p;
  if (maxeval >= 2 && (scalar_correlation || full_block)) {
    LBEndpoint analytic =
        LBRsqEndpoint(sample, units, target, n, cutoff, side, scale, tolerance);
    evaluations += analytic.evaluations;
    if (analytic.ok && side * (analytic.value - baseline.value) <=
                           tolerance * std::max(1.0, scale)) {
      analytic.evaluations = evaluations;
      return analytic;
    }
  }
  std::vector<std::pair<double, arma::uword>> order;
  for (arma::uword j = 0; j < starts.n_cols && evaluations < maxeval; ++j) {
    const LBState initial = LBEvaluate(starts.col(j), sample, units, target, n);
    ++evaluations;
    if (initial.valid) {
      order.emplace_back(side * initial.value, j);
    }
  }
  std::sort(order.begin(), order.end());
  int agreements = 0;
  for (const auto& entry : order) {
    if (evaluations >= maxeval) {
      break;
    }
    ++starts_tried;
    const arma::uword start = entry.second;
    arma::vec par = starts.col(start);
    LBState state = LBEvaluate(par, sample, units, target, n);
    ++evaluations;
    if (!state.valid || evaluations >= maxeval) {
      continue;
    }
    if (evaluations + static_cast<int>(2 * m + 4) < maxeval) {
      LBEndpoint direct = LBPolish(par, sample, units, target, n, cutoff, side,
                                   scale, tolerance, maxeval - evaluations);
      evaluations += direct.evaluations;
      iterations += direct.iterations;
      if (direct.ok && side * (direct.value - baseline.value) <=
                           tolerance * std::max(1.0, scale)) {
        const bool same =
            best.ok && std::abs(direct.value - best.value) <=
                           10 * tolerance * std::max(1.0, std::abs(best.value));
        if (!best.ok || side * direct.value < side * best.value) {
          best = direct;
        }
        agreements = same ? agreements + 1 : 1;
        if (agreements >= 2) {
          break;
        }
        continue;
      }
    }
    const int local_end =
        best.ok ? std::min(maxeval, evaluations + 500) : maxeval;
    double multiplier = 0;
    double penalty = 10;
    double previous_violation = arma::datum::inf;
    for (int outer = 0; outer < 14 && evaluations < local_end; ++outer) {
      arma::mat inverse_hessian = arma::eye(m, m);
      for (int inner = 0; inner < 160 && evaluations < local_end; ++inner) {
        ++iterations;
        const double constraint = state.loss / cutoff - 1;
        const double active = std::max(0.0, multiplier + penalty * constraint);
        const double objective =
            side * state.value / scale +
            (active * active - multiplier * multiplier) / (2 * penalty);
        const arma::vec gradient = side * state.gradient / scale +
                                   active * state.loss_gradient / cutoff;
        if (arma::abs(gradient).max() < 1e-9) {
          break;
        }
        arma::vec direction = -inverse_hessian * gradient;
        if (arma::dot(direction, gradient) >= 0 || !direction.is_finite()) {
          inverse_hessian.eye();
          direction = -gradient;
        }
        const double length = arma::norm(direction);
        if (length > 2) {
          direction *= 2 / length;
        }
        bool accepted = false;
        LBState trial;
        arma::vec candidate;
        double next_active = 0;
        for (int line = 0; line < 36 && evaluations < local_end; ++line) {
          const double fraction = std::ldexp(1.0, -line);
          candidate = par + fraction * direction;
          trial = LBEvaluate(candidate, sample, units, target, n);
          ++evaluations;
          if (!trial.valid) {
            continue;
          }
          next_active =
              std::max(0.0, multiplier + penalty * (trial.loss / cutoff - 1));
          const double next_objective =
              side * trial.value / scale +
              (next_active * next_active - multiplier * multiplier) /
                  (2 * penalty);
          if (next_objective <=
              objective + 1e-4 * fraction * arma::dot(gradient, direction)) {
            accepted = true;
            break;
          }
        }
        if (!accepted) {
          break;
        }
        const arma::vec step = candidate - par;
        const arma::vec next_gradient =
            side * trial.gradient / scale +
            next_active * trial.loss_gradient / cutoff;
        const arma::vec change = next_gradient - gradient;
        const double curvature = arma::dot(step, change);
        if (curvature > 1e-12 * arma::norm(step) * arma::norm(change)) {
          const arma::mat update =
              arma::eye(m, m) - step * change.t() / curvature;
          inverse_hessian = update * inverse_hessian * update.t() +
                            step * step.t() / curvature;
        }
        par = candidate;
        state = trial;
      }
      if (evaluations + static_cast<int>(2 * m + 4) < local_end) {
        LBEndpoint polished =
            LBPolish(par, sample, units, target, n, cutoff, side, scale,
                     tolerance, local_end - evaluations);
        evaluations += polished.evaluations;
        iterations += polished.iterations;
        if (polished.ok && side * (polished.value - baseline.value) <=
                               tolerance * std::max(1.0, scale)) {
          const bool same =
              best.ok &&
              std::abs(polished.value - best.value) <=
                  10 * tolerance * std::max(1.0, std::abs(best.value));
          if (!best.ok || side * polished.value < side * best.value) {
            best = polished;
          }
          agreements = same ? agreements + 1 : 1;
          break;
        }
      }
      const double violation = state.loss / cutoff - 1;
      multiplier = std::max(0.0, multiplier + penalty * violation);
      if (std::abs(violation) > previous_violation / 2) {
        penalty *= 10;
      }
      previous_violation = std::abs(violation);
    }
    if (agreements >= 2) {
      break;
    }
  }
  best.evaluations = evaluations;
  best.iterations = iterations;
  best.retries = std::max(0, starts_tried - 1);
  return best;
}
// -----------------------------------------------------------------------------
// edit functionsCpp/linearAlgebra/linearAlgebra-sym-of-vech-dot.cpp
// (linked into .setup/cpp/; change it in the functionsCpp project)
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------

#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

// Symmetric k x k matrix from its half-vectorization
// (lower triangle, column by column, as .Vech() in R).
arma::mat SymofVechCpp(const arma::rowvec& x, const arma::uword k) {
  arma::mat out(k, k);
  arma::uword idx = 0;
  for (arma::uword j = 0; j < k; j++) {
    for (arma::uword i = j; i < k; i++) {
      out(i, j) = x(idx);
      out(j, i) = x(idx);
      idx++;
    }
  }
  return out;
}

// Half-vectorization of a square matrix
// (lower triangle, column by column, as .Vech() in R).
arma::rowvec VechCpp(const arma::mat& x) {
  const arma::uword k = x.n_rows;
  arma::rowvec out(k * (k + 1) / 2);
  arma::uword idx = 0;
  for (arma::uword j = 0; j < k; j++) {
    for (arma::uword i = j; i < k; i++) {
      out(idx) = x(i, j);
      idx++;
    }
  }
  return out;
}
// -----------------------------------------------------------------------------
// edit
// functions/strRegression/strRegression-str-regression-of-vech-sigma-mat-dot.cpp
// (linked into .setup/cpp/; change it in the functionsCpp project)
// Ivan Jacob Agaloos Pesigan
// -----------------------------------------------------------------------------

#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

arma::mat SymofVechCpp(const arma::rowvec& x, const arma::uword k);

// Regression effect sizes for each row of vech(sigmacap),
// where sigmacap is the covariance matrix of (y, x_1, ..., x_p):
// standardized slopes (betastar), R-squared (rsq),
// semipartial correlations (spcor),
// and squared partial correlations (pcorsq).
// Same quantities as .BetaStarofSigma(), .RSqofSigma(), .SPCor(),
// and .PCorSq() in R. Rows that fail are NA.
// [[Rcpp::export(.StrRegressionofVechSigmaMat)]]
Rcpp::List StrRegressionofVechSigmaMat(const arma::mat& vechsigmacap,
                                       const arma::uword k) {
  const arma::uword n = vechsigmacap.n_rows;
  const arma::uword p = k - 1;
  arma::mat betastar(n, p);
  arma::vec rsq(n);
  arma::mat spcor(n, p);
  arma::mat pcorsq(n, p);
  for (arma::uword r = 0; r < n; r++) {
    const arma::mat sigmacap = SymofVechCpp(vechsigmacap.row(r), k);
    const arma::mat sigmacapx = sigmacap.submat(1, 1, p, p);
    const arma::vec sigmayx = sigmacap.submat(1, 0, p, 0);
    const double sigmaysq = sigmacap(0, 0);
    arma::vec beta;
    bool ok =
        sigmaysq > 0 && arma::all(sigmacapx.diag() > 0) &&
        arma::solve(beta, sigmacapx, sigmayx, arma::solve_opts::likely_sympd);
    arma::mat invrhocapx;
    arma::vec sigmax;
    if (ok) {
      sigmax = arma::sqrt(sigmacapx.diag());
      const arma::mat rhocapx = sigmacapx / (sigmax * sigmax.t());
      ok = arma::inv_sympd(invrhocapx, rhocapx);
    }
    if (ok) {
      const double sigmay = std::sqrt(sigmaysq);
      const arma::vec b = beta % sigmax / sigmay;
      const double r2 = arma::dot(sigmayx, beta) / sigmaysq;
      const arma::vec sr = b % arma::sqrt(1.0 / invrhocapx.diag());
      const arma::vec srsq = arma::square(sr);
      betastar.row(r) = b.t();
      rsq(r) = r2;
      spcor.row(r) = sr.t();
      pcorsq.row(r) = (srsq / (1.0 - (r2 - srsq))).t();
    } else {
      betastar.row(r).fill(arma::datum::nan);
      rsq(r) = arma::datum::nan;
      spcor.row(r).fill(arma::datum::nan);
      pcorsq.row(r).fill(arma::datum::nan);
    }
  }
  return Rcpp::List::create(
      Rcpp::Named("betastar") = betastar, Rcpp::Named("rsq") = rsq,
      Rcpp::Named("spcor") = spcor, Rcpp::Named("pcorsq") = pcorsq);
}
