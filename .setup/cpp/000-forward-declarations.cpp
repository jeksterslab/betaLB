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
