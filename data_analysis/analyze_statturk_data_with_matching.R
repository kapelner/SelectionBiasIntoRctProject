setwd("c:/users/kapelner/workspace/StatTurk/data_analysis")

Xorig = as.data.frame(read.csv("dumps/statturk_dump_01_20_13__06_03.csv"))
dim(Xorig)
colnames(Xorig)

#create some new vars, drop some, and recode others
Xorig$comments_length = nchar(as.character(Xorig$turker_comments))
Xorig$turker_comments = NULL
Xorig$time_elapsed = (Xorig$subject_finished_at - Xorig$subject_started_at) / 60
Xorig$time_demographic = (Xorig$demographic_started_at - Xorig$subject_started_at)
Xorig$time_study = (Xorig$study_finished - Xorig$study_started)
Xorig$treatment = ifelse(Xorig$treatment == "true", 1, 0)
Xorig$income = ifelse(Xorig$income > 1000, Xorig$income / 1000, Xorig$income)

#drop records that don't comport with reality
Xorig = Xorig[Xorig$time_elapsed <= 14, ]
Xorig = Xorig[Xorig$time_study > 20 & Xorig$time_study < 14 * 60, ]

#drop records with missing data
Xorig = na.omit(Xorig)
Xorig = Xorig[Xorig$big_5_5 != 0 & Xorig$big_5_5 != "", ]
Xorig = Xorig[Xorig$big_5_4 != 0, ]
Xorig = Xorig[Xorig$big_5_3 != 0, ]
Xorig = Xorig[Xorig$big_5_2 != 0, ]
Xorig = Xorig[Xorig$big_5_1 != 0, ]
Xorig = Xorig[Xorig$nfc_1 != 0, ]
Xorig = Xorig[Xorig$nfc_2 != 0, ]

#make sure no pesky extra factors are hiding out anywhere after removing the missing data in the lines above
Xorig$big_5_5 = as.factor(as.character(Xorig$big_5_5))
Xorig$big_5_4 = as.factor(as.character(Xorig$big_5_4))
Xorig$big_5_3 = as.factor(as.character(Xorig$big_5_3))
Xorig$big_5_2 = as.factor(as.character(Xorig$big_5_2))
Xorig$big_5_1 = as.factor(as.character(Xorig$big_5_1))
Xorig$nfc_1 = as.factor(as.character(Xorig$nfc_1))
Xorig$nfc_2 = as.factor(as.character(Xorig$nfc_2))

#some attributes should be analyzed factors
Xorig$study_num = as.factor(Xorig$study_num)

#we only want to analyze the beer framing results at the moment
Xfr = Xorig[Xorig$study_name == "framing_beer", ]
#kill rows that don't make sense
Xfr = Xfr[Xfr$response > 0 & Xfr$response <= 25, ]


#kill columns that aren't real data
Xfr$task_id = NULL
Xfr$study_name = NULL
Xfr$mturk_worker_id = NULL
Xfr$subject_started_at = NULL
Xfr$subject_finished_at = NULL
Xfr$experimental_arm = NULL
Xfr$ip_address = NULL
Xfr$demographic_started_at = NULL
Xfr$demographic_completed_at = NULL
Xfr$study_started = NULL
Xfr$study_finished = NULL
Xfr$outlier_data_point = NULL

mod = lm(response ~ ., Xfr)
summary(mod)


############# Simulate our matching algorithm on this historical data:
## If subject goes to reservoir, keep T/C as original
## If subject is matched and they get the original T/C after match, keep the match
## otherwise, remove that subject from the data
## start with n_study < n and you'll wind up with less than that based on the number that are thrown out

#simulation params
Nsim = 100
n_study = 200 ### our method only works on low n studies
EFF_ZERO = 1e-10
prob_match_cutoff_lambda = 0.025

beta_matches = array(NA, Nsim)
beta_se_matches = array(NA, Nsim)
beta_regression = array(NA, Nsim)
beta_se_regression = array(NA, Nsim)
sub_ns = array(NA, Nsim)


for (nsim in 1 : Nsim){
	cat(nsim, "/", Nsim)
	#scramble the order of the participants for each run
	X = Xfr[sample(1 : nrow(Xfr), n_study), ]
	#pull out true indicator of treatment and true y
	true_trt = X$treatment
	y_true = X$response
	X$treatment = NULL
	X$response = NULL
	
	#make model matrix (turn factor cols into dummy cols)
	Xmodel = as.data.frame(model.matrix(lm(y_true ~ ., X)))
	#kill intercept
	Xmodel = Xmodel[, 2 : ncol(Xmodel)]
	#kill some rows otherwise det = 0. Also - can't include anything but true covariates (no elapsed time, no comments length, etc which are recorded after experiment)
	colSums(Xmodel)
	Xmodelsub = Xmodel[, c("age", "genderM", "urban_ruralU", "income", "belief_in_divineY", "raceBL", "employment_statusUN", "num_children", "born_hereY", "marital_statusS", "highest_educationSC")]
	
	cor(Xmodelsub)
	det(var(Xmodelsub))
	
	p = ncol(Xmodelsub)
	head(Xmodelsub)
#	sum(round(cor(Xmodel),3) > 0.5)
	
	indic_T = array(NA, n_study) 
	#initialize the reservoir
	match_indic = array(-1, n_study) #0 indicates reservoir
	
	for (i_match in 1 : n_study){
		
		xs_to_date = Xmodelsub[1 : i_match, ]
		#if there is nothing in the reservoir, randomize and add it to reservoir
		if (length(match_indic[match_indic == 0]) == 0 || i_match <= p + 1){ # || abs(det(var(xs_to_date))) < EFF_ZERO
			indic_T[i_match] = true_trt[i_match]
			match_indic[i_match] = 0
			cat(".")
		} else {
			#first calculate the threshold we're operating at
			
			S_xs_inv = ginv(var(xs_to_date))
			F_crit =  qf(prob_match_cutoff_lambda, p, i_match - p)
			T_cutoff_sq = p * (n_study - 1) / (n_study - p) * F_crit
			#now iterate over all items in reservoir and take the minimum distance x
			reservoir_indices = which(match_indic == 0)
			x_star = Xmodelsub[i_match, ]
			sqd_distances = array(NA, length(reservoir_indices))
			for (r in 1 : length(reservoir_indices)){
				sqd_distances[r] = 1 / 2 * 
						as.matrix(x_star - Xmodelsub[reservoir_indices[r], ]) %*%
						S_xs_inv %*%
						t(x_star - Xmodelsub[reservoir_indices[r], ])			
			}
#			cat(paste("i_match", i_match, "sqd_distances", paste(sqd_distances, collapse = ", "), "T_cutoff_sq", T_cutoff_sq, "\n"))
			
			#find minimum distance index
			min_sqd_dist_index = which(sqd_distances == min(sqd_distances))
#			if (length(sqd_distances[min_sqd_dist_index]) > 1 || length(T_cutoff_sq) > 1){
#				cat(paste("i_match", i_match, "sqd_distances[min_sqd_dist_index]", paste(sqd_distances[min_sqd_dist_index], collapse = "!!!!!!!!!!!!!!!!"), "T_cutoff_sq", paste(T_cutoff_sq, collapse = "!!!!!!!!!!!!!!!!"), "\n"))
#				print(xs_to_date)
#			}
			#if it's smaller than the threshold, we're in business: match it
			#but ONLY if it matches the true randomization
			min_dist_sqs = sqd_distances[min_sqd_dist_index][1]
			if (min_dist_sqs < T_cutoff_sq){
				min_sqd_dist_res_ind = reservoir_indices[min_sqd_dist_index]
				if (1 - indic_T[min_sqd_dist_res_ind] == true_trt[i_match]){
					match_num = max(match_indic) + 1
					match_indic[min_sqd_dist_res_ind] = match_num
					match_indic[i_match] = match_num
					indic_T[i_match] = 1 - indic_T[min_sqd_dist_res_ind]
					cat("|")
#					cat("made match", match_num, "!\n")
				} else {
					cat("x")
#					cat("ditched a row!\n")
				}
			} else { #otherwise, randomize and add it to the reservoir ie keep the original randomization
				indic_T[i_match] = true_trt[i_match]
				match_indic[i_match] = 0
				cat(".")
			}
		}
	}
	
	indic_T_sub = indic_T[!is.na(indic_T)]
	y_true_sub = y_true[!is.na(indic_T)]
	match_indic_sub = match_indic[!is.na(indic_T)]
	Xy = Xmodelsub[!is.na(indic_T), ]
	sub_ns[nsim] = length(indic_T_sub)
	
	cat("   sub_n:", sub_ns[nsim])
	#now use our estimator
	#get reservoir data
	Xyleft = Xy[match_indic_sub == 0, ]
	YleftT = y_true_sub[indic_T_sub == 1]
	YleftC = y_true_sub[indic_T_sub == 0]
	r_bar = mean(YleftT) - mean(YleftC)
	
	#get reservoir sample sizes
	nR = nrow(Xyleft)
	nRT = length(YleftT)
	nRC = length(YleftC)
	
	#get d_i's and its sample avgs
	ydiffs = array(NA, max(match_indic_sub))
	yTs = array(NA, max(match_indic_sub))
	yCs = array(NA, max(match_indic_sub))
	for (match_id in 1 : max(match_indic_sub)){
		yT = y_true_sub[indic_T_sub == 1 & match_indic_sub == match_id]
		yC = y_true_sub[indic_T_sub == 0 & match_indic_sub == match_id]
		ydiffs[match_id] = yT - yC
		yTs[match_id] = yT
		yCs[match_id] = yC
	}
	Dbar = mean(ydiffs)
	pval = cor.test(yTs, yCs)$p.value
	cat(" corrpval:", pval)
	plot(yTs, yCs, main = paste("pval:", pval))
	
	
	#compute reservoir sample variance
	ssqR = (var(YleftT) * (nRT - 1) + var(YleftC) * (nRC - 1)) / (nR - 2) * (1 / nRT + 1 / nRC)
	ssqM = var(ydiffs) / length(ydiffs)
	
	w_star = ssqR / (ssqR + ssqM)
	
	b_T_est = w_star * Dbar + (1 - w_star) * r_bar
	b_T_est_var = ssqR * ssqM / (ssqR + ssqM)
	b_T_est_sd = sqrt(b_T_est_var)
	
#	z_stat = b_T_est / b_T_est_sd
#	
#	pval = 2 * (1 - pnorm(z_stat))
	
	beta_matches[nsim] = b_T_est
	beta_se_matches[nsim] = b_T_est_sd
	
	#do a linear regression for comparison purposes with same sub_n
	X = Xfr[sample(1 : nrow(Xfr), sub_ns[nsim]), ]
#	Xmodel = as.data.frame(model.matrix(lm(response ~ treatment + age + gender + urban_rural + 
#									income + belief_in_divine + race + employment_status + 
#									num_children + born_here + marital_status + highest_education, X)))
#	#kill intercept
#	Xmodel = Xmodel[, 2 : ncol(Xmodel)]
#	#kill some rows otherwise det = 0. Also - can't include anything but true covariates (no elapsed time, no comments length, etc which are recorded after experiment)
#	colSums(Xmodel)
#	#same as above except with treatment!!!!
#	Xmodelsub = Xmodel[, c("treatment", "age", "genderM", "urban_ruralU", "income", "belief_in_divineY", "raceBL", "employment_statusUN", "num_children", "born_hereY", "marital_statusS", "highest_educationSC")]
	
#	X$raceBL = ifelse(as.character(X$race) == "BL", 1, 0)
#	X$employment_statusUN = ifelse(as.character(X$employment_status) == "UN", 1, 0)
#	X$marital_statusS = ifelse(as.character(X$marital_status) == "S", 1, 0)
#	X$highest_educationSC = ifelse(as.character(X$highest_education) == "SC", 1, 0)
#	X$born_here = ifelse(as.character(X$born_here) == "Y", 1, 0)
#	X$gender = ifelse(as.character(X$gender) == "M", 1, 0)
#	X$belief_in_divine = ifelse(as.character(X$belief_in_divine) == "Y", 1, 0)
#	X$urban_rural = ifelse(as.character(X$urban_rural) == "Y", 1, 0)
	
#	linear_mod = lm(response ~ treatment + 
#					age + gender + 
#					urban_rural + income + 
#					belief_in_divine + raceBL + 
#					employment_statusUN + num_children + 
#					born_here + marital_statusS + highest_educationSC, X)
	linear_mod = lm(response ~ treatment, X)
	beta_regression[nsim] = coef(summary(linear_mod))[2, 1]
	beta_se_regression[nsim] = coef(summary(linear_mod))[2, 2]
	cat("\n")
}

#check results
mean(beta_matches, na.rm=T)
mean(beta_regression, na.rm=T)

mean(beta_se_matches^2, na.rm=T)
mean(beta_se_regression^2, na.rm=T)

mean(beta_se_regression^2, na.rm=T) / mean(beta_se_matches^2, na.rm=T)
1 - (mean(beta_se_regression^2, na.rm=T) / mean(beta_se_matches^2, na.rm=T))^-1

t.test(beta_se_matches, beta_se_regression)
mean(sub_ns)

#test bart
Xfr$raceBL = ifelse(as.character(Xfr$race) == "BL", 1, 0)
Xfr$employment_statusUN = ifelse(as.character(Xfr$employment_status) == "UN", 1, 0)
Xfr$marital_statusS = ifelse(as.character(Xfr$marital_status) == "S", 1, 0)
Xfr$highest_educationSC = ifelse(as.character(Xfr$highest_education) == "SC", 1, 0)
Xfr$born_here = ifelse(as.character(Xfr$born_here) == "Y", 1, 0)
Xfr$gender = ifelse(as.character(Xfr$gender) == "M", 1, 0)
Xfr$belief_in_divine = ifelse(as.character(Xfr$belief_in_divine) == "Y", 1, 0)
Xfr$urban_rural = ifelse(as.character(Xfr$urban_rural) == "Y", 1, 0)

linear_mod = lm(response ~ treatment + 
				age + gender + 
				urban_rural + income + 
				belief_in_divine + raceBL + 
				employment_statusUN + num_children + 
				born_here + marital_statusS + highest_educationSC, Xfr)
summary(linear_mod)



directory_where_code_is = getwd() #usually we're on a linux box and we'll just navigate manually to the directory
#if we're on windows, then we're on the dev box, so use a prespecified directory
if (.Platform$OS.type == "windows"){
	directory_where_code_is = "C:\\Users\\kapelner\\workspace\\CGMBART_GPL"
}
setwd(directory_where_code_is)
source("r_scripts/bart_package.R")
source("r_scripts/bart_package_plots.R")
source("r_scripts/bart_package_variable_selection.R")
source("r_scripts/bart_package_f_tests.R")
set_bart_machine_num_cores(4)
bart_machine = build_bart_machine(Xfr[, c("age", "gender", "urban_rural", "income", "belief_in_divine", "raceBL", "employment_statusUN", "num_children", "born_here", "marital_statusS", "highest_educationSC")], 
		Xfr$response,
		num_trees = 200,
		num_burn_in = 1000,
		num_iterations_after_burn_in = 1000)
bart_machine
plot_convergence_diagnostics(bart_machine)
bart_machine$PseudoRsq
bart_machine$L2_err
plot_y_vs_yhat(bart_machine)
plot_sigsqs_convergence_diagnostics(bart_machine)

library(randomForest)
rf = randomForest(x = Xfr[, c("age", "gender", "urban_rural", "income", "belief_in_divine", "raceBL", "employment_statusUN", "num_children", "born_here", "marital_statusS", "highest_educationSC")], y = Xfr$response)
#find R^2
yhat = predict(rf, Xfr[, c("age", "gender", "urban_rural", "income", "belief_in_divine", "raceBL", "employment_statusUN", "num_children", "born_here", "marital_statusS", "highest_educationSC")])
plot(Xfr$response, yhat)
abline(a = 0, b = 1)
sse = sum((Xfr$response - yhat)^2)
sst = sum((Xfr$response - mean(Xfr$response))^2)
Pseudo_Rsq_rf = 1 - sse / sst
Pseudo_Rsq_rf
