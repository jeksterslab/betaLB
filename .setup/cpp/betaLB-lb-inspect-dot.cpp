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
