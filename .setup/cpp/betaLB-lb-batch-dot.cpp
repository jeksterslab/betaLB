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
