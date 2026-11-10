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
