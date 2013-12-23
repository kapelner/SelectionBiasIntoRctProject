setwd("c:/users/kapelner/workspace/StatTurk/data_analysis")

X = as.data.frame(read.csv("dumps/statturk_dump_01_20_13__06_03.csv"))
dim(X)
colnames(X)

#create some new vars, drop some, and recode others
X$comments_length = nchar(as.character(X$turker_comments))
X$turker_comments = NULL #just read em in excel
X$time_elapsed = (X$subject_finished_at - X$subject_started_at) / 60
X$time_demographic = (X$demographic_started_at - X$subject_started_at)
X$time_study = (X$study_finished - X$study_started)
X$treatment = ifelse(X$treatment == "true", 1, 0)
X$income = ifelse(X$income > 1000, X$income / 1000, X$income)

#drop records that don't comport with reality
X = X[X$time_elapsed <= 14, ]
X = X[X$time_study > 20 & X$time_study < 14 * 60, ]
#drop some records with missing data
X = na.omit(X)
X = X[X$big_5_5 != 0, ]
X = X[X$big_5_4 != 0, ]
X = X[X$big_5_3 != 0, ]
X = X[X$big_5_2 != 0, ]
X = X[X$big_5_1 != 0, ]

#some records should be factors
X$study_num = as.factor(X$study_num)


#pull out uniques for each study
Xsc = X[X$study_name == "sunk_cost_theater", ]
Xpr = X[X$study_name == "priming_dilemma", ]
Xfr = X[X$study_name == "framing_beer", ]

#drop responses that don't make sense
Xfr = Xfr[Xfr$response > 0 & Xfr$response <= 25, ]
Xsc = Xsc[Xsc$response >= 0 & Xsc$response <= 9, ]
Xpr = Xpr[Xpr$response %in% c(0, 1), ]

#pull out arms
Xfr_rand = Xfr[Xfr$experimental_arm == "R" & Xfr$study_num == 1, ]
Xfr_sel = Xfr[Xfr$experimental_arm == "S" & Xfr$study_num == 1, ]
Xfr_anal = rbind(Xfr_rand, Xfr_sel)
dim(Xfr_rand)
dim(Xfr_sel)
Xpr_rand = Xpr[Xpr$experimental_arm == "R" & Xpr$study_num == 1, ]
Xpr_sel = Xpr[Xpr$experimental_arm == "S" & Xpr$study_num == 1, ]
Xpr_anal = rbind(Xpr_rand, Xpr_sel)
dim(Xpr_rand)
dim(Xpr_sel)
Xsc_rand = Xsc[Xsc$experimental_arm == "R" & Xsc$study_num == 1, ]
Xsc_sel = Xsc[Xsc$experimental_arm == "S" & Xsc$study_num == 1, ]
Xsc_anal = rbind(Xsc_rand, Xsc_sel)
dim(Xsc_rand)
dim(Xsc_sel)
nrow(Xfr_rand[Xfr_rand$treatment == 1, ])
nrow(Xfr_rand[Xfr_rand$treatment == 0, ])
nrow(Xfr_sel[Xfr_sel$treatment == 1, ])
nrow(Xfr_sel[Xfr_sel$treatment == 0, ])
nrow(Xpr_rand[Xpr_rand$treatment == 1, ])
nrow(Xpr_rand[Xpr_rand$treatment == 0, ])
nrow(Xpr_sel[Xpr_sel$treatment == 1, ])
nrow(Xpr_sel[Xpr_sel$treatment == 0, ])
nrow(Xsc_rand[Xsc_rand$treatment == 1, ])
nrow(Xsc_rand[Xsc_rand$treatment == 0, ])
nrow(Xsc_sel[Xsc_sel$treatment == 1, ])
nrow(Xsc_sel[Xsc_sel$treatment == 0, ])

#investigate some variables
hist(Xsc$time_elapsed, br = 200)
hist(Xsc$time_demographic, br = 200)
hist(X$time_study, br = 200)
table(X$comments_length)
table(Xsc$experimental_arm)
table(Xsc$treatment)
table(Xsc$num_page_reloads)
table(Xsc$splash_views_before_starting)
table(Xsc$splash_views_after_starting)
hist(Xsc$age, br = 100)
table(Xsc$gender)
table(Xsc$urban_rural)
table(Xsc$num_children)
table(Xsc$employment_status)
table(Xsc$marital_status)
hist(Xsc$income, br = 100)
hist(Xsc$income[Xsc$income < 200], br = 100)
table(Xsc$religion)
table(Xsc$belief_in_divine)
table(Xsc$race)
table(Xsc$participate_in_study)
table(Xsc$english_first_language)
table(Xsc$nfc_1)
table(Xsc$nfc_2)
table(Xsc$big_5_1)
table(Xsc$big_5_2)
table(Xsc$big_5_3)
table(Xsc$big_5_4)
table(Xsc$big_5_5)
table(X$study_num)
table(X$study_name)
table(Xsc$response)
hist(Xfr$response, br = 100)
table(Xpr$response)
table(Xsc$num_page_nav_away)

mod = lm(response ~ treatment, data = Xfr_anal)
summary(mod)

mod = lm(response ~ treatment * experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xfr_anal)
summary(mod)

mod = lm(response ~ treatment + experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xfr_anal)
summary(mod)



mod = lm(response ~ treatment * experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xfr_anal)
summary(mod)

mod = lm(response ~ treatment + experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xfr_anal)
summary(mod)




mod = lm(response ~ treatment * experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xsc_anal)
summary(mod)

mod = lm(response ~ treatment + experimental_arm + 
				comments_length +
				time_study + 
				race + 
				belief_in_divine + 
				marital_status + 
				gender + 
				highest_education + 
				urban_rural + 
				born_here + 
				nfc_1 + 
				nfc_2 + 
				big_5_1 + 
				big_5_2 + 
				big_5_3 + 
				big_5_4 + 
				big_5_5 + 
				english_first_language + 
				time_demographic + 
				num_page_nav_away, 
		data = Xsc_anal)
summary(mod)

mod = lm(response ~ treatment + comments_length + study_num + time_study + race + belief_in_divine + marital_status + gender + urban_rural + born_here + nfc_1 + nfc_2 + big_5_1 + big_5_2 + big_5_3 + big_5_4 + big_5_5 + english_first_language + time_demographic + num_page_nav_away, data = Xsc_anal)
summary(mod)

plot(Xfr_anal$experimental_arm, Xfr_anal$response)
plot(Xpr_anal$experimental_arm, Xpr_anal$response)
plot(Xsc_anal$experimental_arm, Xsc_anal$response)

mod = lm(Xsc$response ~ treatment * experimental_arm + comments_length + study_num + time_study + race + belief_in_divine + marital_status + gender + urban_rural + born_here + nfc_1 + nfc_2 + big_5_1 + big_5_2 + big_5_3 + big_5_4 + big_5_5 + english_first_language + time_demographic + num_page_nav_away, data = Xsc)
summary(mod)

mod = lm(Xpr$response * 100 ~ treatment * experimental_arm + comments_length + study_num + time_study + race + belief_in_divine + marital_status + gender + urban_rural + born_here + nfc_1 + nfc_2 + big_5_1 + big_5_2 + big_5_3 + big_5_4 + big_5_5 + english_first_language + time_demographic + num_page_nav_away, data = Xpr)
summary(mod)

# [1] "task_id"                      "mturk_worker_id"              "subject_started_at"          
# [4] "subject_finished_at"          "ip_address"                   "experimental_arm"            
# [7] "treatment"                    "num_page_reloads"             "splash_views_before_starting"
#[10] "splash_views_after_starting"  "demographic_started_at"       "age"                         
#[13] "gender"                       "urban_rural"                  "highest_education"           
#[16] "marital_status"               "employment_status"            "num_children"                
#[19] "income"                       "religion"                     "belief_in_divine"            
#[22] "race"                         "participate_in_study"         "born_here"                   
#[25] "english_first_language"       "nfc_1"                        "nfc_2"                       
#[28] "big_5_1"                      "big_5_2"                      "big_5_3"                     
#[31] "big_5_4"                      "big_5_5"                      "demographic_completed_at"    
#[34] "study_num"                    "study_started"                "study_name"                  
#[37] "response"                     "study_finished"               "num_page_nav_away"           
#[40] "outlier_data_point"           "turker_comments"     




boxplot(Xfr_anal[Xfr_anal$experimental_arm == "R", ]$response, 
		Xfr_anal[Xfr_anal$experimental_arm == "S", ]$response, 
		Xfr_anal[Xfr_anal$treatment == 1, ]$response, 
		Xfr_anal[Xfr_anal$treatment == 0, ]$response, 
		Xfr_anal[Xfr_anal$experimental_arm == "R" & Xfr_anal$treatment == 1, ]$response, 
		Xfr_anal[Xfr_anal$experimental_arm == "S" & Xfr_anal$treatment == 1, ]$response, 
		Xfr_anal[Xfr_anal$experimental_arm == "R" & Xfr_anal$treatment == 0, ]$response, 
		Xfr_anal[Xfr_anal$experimental_arm == "S" & Xfr_anal$treatment == 0, ]$response,		
		names = c("R", "S", "T", "C", "RT", "ST", "RC", "SC"), main = "Framing Study Results", ylab = "Amount for Beer Paid")

points(c(mean(Xfr_anal[Xfr_anal$experimental_arm == "R", ]$response), 
	mean(Xfr_anal[Xfr_anal$experimental_arm == "S", ]$response), 
	mean(Xfr_anal[Xfr_anal$treatment == 1, ]$response), 
	mean(Xfr_anal[Xfr_anal$treatment == 0, ]$response), 
	mean(Xfr_anal[Xfr_anal$experimental_arm == "R" & Xfr_anal$treatment == 1, ]$response), 
	mean(Xfr_anal[Xfr_anal$experimental_arm == "S" & Xfr_anal$treatment == 1, ]$response), 
	mean(Xfr_anal[Xfr_anal$experimental_arm == "R" & Xfr_anal$treatment == 0, ]$response), 
	mean(Xfr_anal[Xfr_anal$experimental_arm == "S" & Xfr_anal$treatment == 0, ]$response)), col = "blue", lwd = 4)

barplot(c(mean(Xpr_anal[Xpr_anal$experimental_arm == "R", ]$response), 
		mean(Xpr_anal[Xpr_anal$experimental_arm == "S", ]$response), 
		mean(Xpr_anal[Xpr_anal$treatment == 1, ]$response), 
		mean(Xpr_anal[Xpr_anal$treatment == 0, ]$response), 
		mean(Xpr_anal[Xpr_anal$experimental_arm == "R" & Xpr_anal$treatment == 1, ]$response), 
		mean(Xpr_anal[Xpr_anal$experimental_arm == "S" & Xpr_anal$treatment == 1, ]$response), 
		mean(Xpr_anal[Xpr_anal$experimental_arm == "R" & Xpr_anal$treatment == 0, ]$response), 
		mean(Xpr_anal[Xpr_anal$experimental_arm == "S" & Xpr_anal$treatment == 0, ]$response)),		
		names = c("R", "S", "T", "C", "RT", "ST", "RC", "SC"), 
		main = "Priming Study Results", ylim = c(0.8, 1), xpd = FALSE, ylab = "Percent Who Cooperate")



boxplot(Xsc_anal[Xsc_anal$experimental_arm == "R", ]$response, 
		Xsc_anal[Xsc_anal$experimental_arm == "S", ]$response, 
		Xsc_anal[Xsc_anal$treatment == 1, ]$response, 
		Xsc_anal[Xsc_anal$treatment == 0, ]$response, 
		Xsc_anal[Xsc_anal$experimental_arm == "R" & Xsc_anal$treatment == 1, ]$response, 
		Xsc_anal[Xsc_anal$experimental_arm == "S" & Xsc_anal$treatment == 1, ]$response, 
		Xsc_anal[Xsc_anal$experimental_arm == "R" & Xsc_anal$treatment == 0, ]$response, 
		Xsc_anal[Xsc_anal$experimental_arm == "S" & Xsc_anal$treatment == 0, ]$response,		
		names = c("R", "S", "T", "C", "RT", "ST", "RC", "SC"), main = "Sunk Cost Study Results", ylab = "Feeling for Attending Theatre",ylim = c(0,9))

points(c(mean(Xsc_anal[Xsc_anal$experimental_arm == "R", ]$response), 
				mean(Xsc_anal[Xsc_anal$experimental_arm == "S", ]$response), 
				mean(Xsc_anal[Xsc_anal$treatment == 1, ]$response), 
				mean(Xsc_anal[Xsc_anal$treatment == 0, ]$response), 
				mean(Xsc_anal[Xsc_anal$experimental_arm == "R" & Xsc_anal$treatment == 1, ]$response), 
				mean(Xsc_anal[Xsc_anal$experimental_arm == "S" & Xsc_anal$treatment == 1, ]$response), 
				mean(Xsc_anal[Xsc_anal$experimental_arm == "R" & Xsc_anal$treatment == 0, ]$response), 
				mean(Xsc_anal[Xsc_anal$experimental_arm == "S" & Xsc_anal$treatment == 0, ]$response)), col = "blue", lwd = 4)



t.test(Xfr_anal[Xfr_anal$experimental_arm == "R", ]$response, Xfr_anal[Xfr_anal$experimental_arm == "S", ]$response)


plot(Xpr_anal$experimental_arm, Xpr_anal$response)
t.test(Xpr_anal[Xpr_anal$experimental_arm == "R", ]$response, Xpr_anal[Xpr_anal$experimental_arm == "S", ]$response)


plot(Xsc_anal$experimental_arm, Xsc_anal$response)
t.test(Xsc_anal[Xsc_anal$experimental_arm == "R", ]$response, Xsc_anal[Xsc_anal$experimental_arm == "S", ]$response)


plot(Xfr_anal$experimental_arm, Xfr_anal$response)
plot(Xpr_anal$experimental_arm, Xpr_anal$response)
plot(Xsc_anal$experimental_arm, Xsc_anal$response)


####POWER

Xfr_first = Xfr[1:100, ]
mod = lm(response ~ treatment * experimental_arm + comments_length + study_num + time_study + race + belief_in_divine + marital_status + gender + urban_rural + born_here + nfc_1 + nfc_2 + big_5_1 + big_5_2 + big_5_3 + big_5_4 + big_5_5 + english_first_language + time_demographic + num_page_nav_away, data = Xfr_first)
summary(mod)

sigsq = sum(mod$residuals^2 / 72)



effects = c(0.01, 0.05, 0.1, 0.15, 0.20, 0.25, 0.5, 0.75)
rs = c(100, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
powers = matrix(NA, length(rs), length(effects))

rownames(powers) = rs
colnames(powers) = effects
for (i in 1 : length(rs)){
	for (j in 1 : length(effects)){
		r = rs[i]
		effect = effects[j]
		Fstar = qf(0.95, 1, 4 * (r - 1))
		powers[i, j] = 1 - pf(Fstar, 1, 4 * (r - 1), 4 * r * effect^2 / sigsq)		
	}
}
xtable(powers)


#t(Xfr$subject_started_at)[1]
#[1] 1352344310
#> sort(Xfr$subject_started_at)[nrow(Xfr)]
#[1] 1356928482
#> 1356928482-1352344310
#[1] 4584172
#> 4584172 / 3600
#[1] 1273.381
#> 1273.381/24
#[1] 53.05754 ####about 53 days / 7 weeks





