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
