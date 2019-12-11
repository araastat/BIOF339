my_curveFit <- function(x, rspn, eq, param, effv, rtype = 'quantal', sigLev = 0.05, ...){
	# NLS curve fitting for monotonic and non-monotonic equations
	# x a vector of treatment concentration
	# rspn a vector or matrix
	# for non-monotonic curve fitting, Brain_Consens, BCV, Hill_five, and Biphasic are highly recommended.
	# rtype response type: quantal, continuous, hormesis

	
	#############################################################
	## source('ECx.R')
	
	if (missing(x) || missing(rspn) || missing(eq) || missing(param)) stop('argument missing')
	#print('Please set the right rtype: quantal, continuous, hormesis')
	cat('\nProcessing', rtype, 'quantal dose-response data\n')
	n <- length(x) # the number of concentrations
	mode(param) <- "numeric"
	m <- length(param) # the number of parameters
	
	if (is.vector(rspn)){
		if (n != length(rspn)) stop("concentration and response should be in the same length")
		rspn <- as.matrix(rspn)
		y <- rspn
	}else if (is.matrix(rspn)){
		size <- dim(rspn)
		y <- rowMeans(rspn)
		if(n != size[1]) stop("concentration and response should be paired")
	}
	
	# non-monotonic or monotonic
	if(eq == 'Brain_Consens' || eq == 'BCV' || eq == 'Cedergreen' || eq == 'Beckon' || eq == 'Biphasic' || eq == 'Hill_five') Hormesis <- TRUE else Hormesis <- FALSE
	
	# define equation expression
	fun <- switch(eq,
		# For Hill equation: EC50 = EC50; Hill = m(Hill coefficient); Maximum = Top; Minimum = Bottom
		Hill = 'y ~ 1 / (1 + (EC50 / x)^Hill)',
		# Howard GJ, Webster TF. 2009. Generalized concentration addition: A method for examining mixtures containing partial agonists. J. Theor. Biol. 259:469~477
		# Hill function with slope parameter 1. EC50 is EC50 here.
		Hill_two = 'y ~ Hill * x / (EC50 + x)',
		Hill_three = 'y ~ Maximum /(1 + (EC50 / x)^Hill)',
		Hill_four = 'y ~ Minimum + (Maximum - Minimum) / (1 + (EC50 / x)^Hill)',
		Hill_five = 'y ~ 1 - (1 + (Maximum - 1) / (1 + (EC50 / x)^Hill)) * (1 - 1 / (1 + (Minimum / x)^Epsilon))',
		# Hill_nine = 'y ~ (Maximum / (1 + (EC50 / x)^Hill)) * (Maximum_one / (1 + (Minimum / x)^Epsilon)) * (Maximum_two / (1 + (EC50_two / x)^Hill_two))',
		Weibull = 'y ~ 1 - exp(-exp(EC50 + Hill * log10(x)))',
		Weibull_three = 'y ~ Maximum * (1 - exp(-exp(EC50 + Hill * log10(x))))',
		Weibull_four = 'y ~ Maximum + (Minimum - Maximum) * exp(-exp(EC50 + Hill * log10(x)))',		
		Logit = 'y ~ 1/(1 + exp((-EC50) - Hill * log10(x)))',
		Logit_three = 'y ~ Maximum / (1 + exp((-EC50) - Hill * log10(x)))',
		Logit_four = 'y ~ Minimum + (Maximum - Minimum) / (1 + exp((-EC50) - Hill * log10(x)))',
		BCW = 'y ~ 1 - exp(-exp(EC50 + Hill * ((x^Maximum - 1) / Maximum)))',
		BCL = 'y ~ (1 + exp(-EC50 - Hill *((x^Maximum - 1) / Maximum)))^(-1)',
		GL = 'y ~ 1 / (1 + exp(-EC50 - Hill * log10(x)))^Maximum',
		# An equation to describe dose responses where there isstimulatin of growth at low doses. 1989. Weed Research.
		Brain_Consens = 'y ~ 1 - (1 + EC50 * x) / (1 + exp(Hill * Maximum) * x^Hill)',
		# Vanewijk, P. H. and Hoekstra, J.A. Calculation of the EC50 and its confidence interval when subtoxic stimulus is present. 1993, Ecotoxicol. Environ. Saf.
		BCV = 'y ~ 1 - EC50 * (1 + Hill * x) / (1 + (1 + 2 * Hill * Maximum) * (x / Maximum)^Minimum)',
		# Cedergreen, N., Ritz, C., Streibig, J.C., 2005. Improved empirical models describing hormesis. Environ. Toxicol. Chem. 24, 3166~3172
		Cedergreen = 'y ~ 1 - (1 + EC50 * exp(-1 / (x^Hill))) / (1 + exp(Maximum * (log(x) - log(Minimum))))',
		# Beckon, W. et.al. 2008. A general approach to modeling biphasic relationships. Environ. Sci. Technol. 42, 1308~1314.
		Beckon = 'y ~ (EC50 + (1 - (EC50) / (1 + (Hill / x)^Maximum))) / (1 + (x / Minimum)^Epsilon)',
		# Zhu X-W, et.al . 2013. Modeling non-monotonic dose-response relationships: Model evaluation and hormetic quantities exploration. Ecotoxicol. Environ. Saf. 89:130~136;
		Biphasic = 'y ~ EC50 - EC50 / (1 + 10^((x - Hill) * Maximum)) + (1 - EC50) / (1 + 10^((Minimum - x) * Epsilon))'
	)
	
	## checking minpack.lm package, use the nlsLM or built-in nls for curve fitting
	#if(require(minpack.lm)){
	dframe <- data.frame(x, y)
	
	if(requireNamespace("minpack.lm", quietly = TRUE)){
		# print("use the minpack.lm package")
		
		if(eq == "Weibull" || eq == "Logit" || eq == "Hill" || eq == "Hill_two"){
			fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2]), control = nls.lm.control(maxiter = 1000), ...)
			#fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2]))
		}else if(eq == "BCW" || eq == "BCL" || eq == "GL" || eq == 'Brain_Consens' || eq == "Hill_three" || eq == 'Weibull_three' || eq == 'Logit_three'){
			fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3]), control = nls.lm.control(maxiter = 1000), ...)
		
		}else if(eq == 'BCV'|| eq == 'Cedergreen' || eq == "Hill_four" || eq == 'Weibull_four' || eq == 'Logit_four'){
			#fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4]), ...)
			fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4]), control = nls.lm.control(maxiter = 1000), ...)
		}else if(eq == 'Beckon' || eq == 'Biphasic' || eq == 'Hill_five'){
			fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4], Epsilon = param[5]), control = nls.lm.control(maxiter = 1000), ...)
			#fit <- minpack.lm::nlsLM(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4], Epsilon = param[5]))
		}else{
			stop('input the right equation name')
		}
		#detach(package: minpack.lm)
	
	}else {
		warning('please install package minpack.lm')
		if(eq == "Weibull" || eq == "Logit" || eq == "Hill" || eq == "Hill_two"){
			fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2]), control = nls.lm.control(maxiter = 1000))
		
		}else if(eq == "BCW" || eq == "BCL" || eq == "GL" || eq == 'Brain_Consens' || eq == "Hill_three" || eq == 'Weibull_three' || eq == 'Logit_three'){
			fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3]), control = nls.lm.control(maxiter = 1000))
		
		}else if(eq == 'BCV'|| eq == 'Cedergreen' || eq == "Hill_four" || eq == 'Weibull_four' || eq == 'Logit_four'){
			#fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4]), control = nls.lm.control(maxiter = 1000))
			fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4]), control = nls.lm.control(maxiter = 1000))
		}else if(eq == 'Beckon' || eq == 'Biphasic' || eq == 'Hill_five'){
			fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4], Epsilon = param[5]), control = nls.lm.control(maxiter = 1000))
			#fit <- nls(fun, data = dframe, start = list(EC50 = param[1], Hill = param[2], Maximum = param[3], Minimum = param[4], Epsilon = param[5]))
		}else{
			stop('input the right equation name')
		}
	}
	
	fitInfo <- summary(fit) # fitting information
	yhat <- predict(fit, x) # y prediction
	res <- as.vector(residuals(fit))
	sst <- sum((y - mean(y))^2) # total sum of squares
	sse <- sum(res^2) # sum of squared errors
	r2 <- 1 - sse / sst # coefficient of determination
	adjr2 <- 1 - sse * (n - 1) / (sst * (n - m)) # adjusted coefficient of determination
	rmse <- sqrt(sse / (n - m)) # root-mean-square error
	mae <- sum(abs(res)) / n # mean absolute error
	#Spiess A-N, Neumeyer N. 2010. An evaluation of R2 as an inadequate measure for nonlinear models in pharmacological and biochemical research: A Monte Carlo approach. BMC Pharmacol. 10: 11.
	lnL <- 0.5 * (-n * (log(2 * pi) + 1 - log(n) + log(sse)))
	aic <- 2 * m - 2 * lnL # Akaike information criterion 
	aicc <- aic + 2 * m * (m + 1) / (n - m - 1)
	bic <- m * log(n) - 2 * lnL # Bayesian information criterion
	sta <- t(c(r2, adjr2, mae, rmse, aic, aicc, bic))
	colnames(sta) <- c('r2', 'adjr2', 'MAE', 'RMSE', 'AIC', 'AICc', 'BIC')
	
	paramHat <- coef(fit)	
	jac <- mixtox::jacobian(eq, x, paramHat) # jacobian matrix calculation
	probT <- qt(1 - sigLev / 2, n - m) # the student t distribution
	mse <- rmse^2  # squared residual standard error
	covPara <- mse * solve(t(jac) %*% jac)  # covariance matrix of the parameter estimates
	
	gap.PI <- sqrt(mse + diag(jac %*% covPara %*% t(jac))) # prediction intervals
	gap.CI <- sqrt(diag(jac %*% covPara %*% t(jac))) # confidence intervals
	
	PI.up <- yhat + probT * gap.PI # PI upper bound
	PI.low <- yhat - probT * gap.PI # PI lower bound
	CI.up <- yhat + probT * gap.CI # CI upper bound
	CI.low <- yhat - probT * gap.CI # CI lower bound
	crcInfo <- cbind(x, yhat, rspn, PI.low, PI.up, CI.low, CI.up)
	
	# compute highest stimulation (minimum effect) of the J-shaped curve and associated concentration. 
	# Brain_Consens, BCV, Cedergreen, Beckon, Biphasic
	if(Hormesis == TRUE){
		rtype <- 'hormesis'
		if(eq == 'Brain_Consens') EC50 = paramHat[1]; Hill = paramHat[2]; Maximum = paramHat[3]
		if(eq == 'BCV' || eq == 'Cedergreen') EC50 <- paramHat[1]; Hill <- paramHat[2]; Maximum <- paramHat[3]; Minimum <- paramHat[4]
		if(eq == 'Beckon' || eq == 'Biphasic' || eq == 'Hill_five') EC50 <- paramHat[1]; Hill <- paramHat[2]; Maximum <- paramHat[3]; Minimum <- paramHat[4]; Epsilon <- paramHat[5]
	
		if (eq == 'Brain_Consens') f <- function(x) 1 - (1 + EC50 * x) / (1 + exp(Hill * Maximum) * x^Hill)
		if(eq == 'BCV') f <- function(x) 1 - EC50 * (1 + Hill * x) / (1 + (1 + 2 * Hill * Maximum) * (x / Maximum)^Minimum)
		if(eq == 'Cedergreen') f <- function(x) 1 - (1 + EC50 * exp(-1 / (x^Hill))) / (1 + exp(Maximum * (log(x) - log(Minimum))))
		if(eq == 'Beckon') f <- function(x) (EC50 + (1 - (EC50) / (1 + (Hill / x)^Maximum))) / (1 + (x / Minimum)^Epsilon)
		if(eq == 'Biphasic') f <- function(x) EC50 - EC50 / (1 + 10^((x - Hill) * Maximum)) + (1 - EC50) / (1 + 10^((Minimum - x) * Epsilon))
		if(eq == 'Hill_five') f <- function(x) 1 - (1 + (Maximum - 1) / (1 + (EC50 / x)^Hill)) * (1 - 1 / (1 + (Minimum / x)^Epsilon))
		
		# intervals for finding the minimum
		intv <- c(x[1], x[length(x) - 1])

		minxy <- tryCatch({
			minxy <- optimize(f, intv)
		}, warning = function(w){
			message("Input an optimal intv")
		}, finally = {
			minxy <- list(minimum = NULL, objective = NULL)
		})
		minx <- minxy$minimum
		miny <- minxy$objective
	}

	## checking argument
	if(!missing(effv)){
		if(rtype == 'quantal' || rtype == 'continuous'){
			## effect concentration and confidence intervals 
			ecx <- mixtox::ECx(eq, paramHat, effv, rtype = rtype)
		}else if (rtype == 'hormesis'){
			effv <- sort(effv)
			ecx <- mixtox::nmECx(eq, paramHat, effv, minx)
		}
	}else{
		ecx <- NULL
	}
	
	#rspnRange <- CEx(eq, paramHat, c(0, Inf))
	rspnRange <- mixtox::CEx(eq, paramHat, c(0, 1e30))
	
	if(Hormesis == FALSE){
		if(is.list(ecx)){
			list(fitInfo = fitInfo, eq = eq, p = paramHat, res = res, sta = sta, crcInfo = crcInfo, effvAbs = ecx$effvAbs, ecx = ecx$ecx, rtype = rtype, rspnRange = rspnRange)
		}else{
			list(fitInfo = fitInfo, eq = eq, p = paramHat, res = res, sta = sta, crcInfo = crcInfo, ecx = ecx, rtype = rtype, rspnRange = rspnRange)
		}
	}else{
		list(fitInfo = fitInfo, eq = eq, p = paramHat, res = res, sta = sta, minx = minx, miny = miny, crcInfo = crcInfo, ecx = ecx, rtype = rtype, rspnRange = rspnRange)
	}
}
