class AdminController < ExperimentalAdminController
  include StatisticsTools
  
  def dashboard
    ts = Task.all.select{|t| t.completed? and t.id > 805} #bugs before 762... that data doesn't count
    @ntot = ts.length
    
    #first handle the R arm
    tsr = ts.select{|t| t.random_study_arm?}
    @n_r = tsr.length
    
    tsr_beer_trt = tsr.select{|t| t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "framing_beer"}}.reject{|s| s.outlier}
    tsr_religious_trt = tsr.select{|t| t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "priming_dilemma"}}.reject{|s| s.outlier}
    tsr_theater_trt = tsr.select{|t| t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "sunk_cost_theater"}}.reject{|s| s.outlier}
    tsr_beer_con = tsr.select{|t| !t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "framing_beer"}}.reject{|s| s.outlier}
    tsr_religious_con = tsr.select{|t| !t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "priming_dilemma"}}.reject{|s| s.outlier}
    tsr_theater_con = tsr.select{|t| !t.treatment}.map{|t| t.studies.detect{|s| s.study_name == "sunk_cost_theater"}}.reject{|s| s.outlier}

    @y_tsr_beer_trt = tsr_beer_trt.map{|s| s.response == s.response.to_i ? s.response.to_i : s.response}
    @y_tsr_religious_trt = tsr_religious_trt.map{|s| s.response.to_i}
    @y_tsr_theater_trt = tsr_theater_trt.map{|s| s.response.to_i}
    @y_tsr_beer_con = tsr_beer_con.map{|s| s.response == s.response.to_i ? s.response.to_i : s.response}
    @y_tsr_religious_con = tsr_religious_con.map{|s| s.response.to_i}
    @y_tsr_theater_con = tsr_theater_con.map{|s| s.response.to_i}
       
    @n_tsr_beer_trt = @y_tsr_beer_trt.length
    @n_tsr_religious_trt = @y_tsr_religious_trt.length
    @n_tsr_theater_trt = @y_tsr_theater_trt.length
    @n_tsr_beer_con = @y_tsr_beer_con.length
    @n_tsr_religious_con = @y_tsr_religious_con.length
    @n_tsr_theater_con = @y_tsr_theater_con.length
    
    @avg_tsr_beer_trt = samp_avg(@y_tsr_beer_trt)
    @avg_tsr_religious_trt = samp_avg(@y_tsr_religious_trt)
    @avg_tsr_theater_trt = samp_avg(@y_tsr_theater_trt)
    @avg_tsr_beer_con = samp_avg(@y_tsr_beer_con)
    @avg_tsr_religious_con = samp_avg(@y_tsr_religious_con)
    @avg_tsr_theater_con = samp_avg(@y_tsr_theater_con)
    
    @ate_tsr_beer = @avg_tsr_beer_trt - @avg_tsr_beer_con
    @ate_tsr_religious = @avg_tsr_religious_trt - @avg_tsr_religious_con
    @ate_tsr_theater = @avg_tsr_theater_trt - @avg_tsr_theater_con
    
    @sd_tsr_beer_trt = samp_sd(@y_tsr_beer_trt)
    @sd_tsr_religious_trt = samp_sd(@y_tsr_religious_trt)
    @sd_tsr_theater_trt = samp_sd(@y_tsr_theater_trt)
    @sd_tsr_beer_con = samp_sd(@y_tsr_beer_con)
    @sd_tsr_religious_con = samp_sd(@y_tsr_religious_con)
    @sd_tsr_theater_con = samp_sd(@y_tsr_theater_con)
    
    @ate_tsr_beer_sd = Math.sqrt(@sd_tsr_beer_trt ** 2 / @n_tsr_beer_trt + @sd_tsr_beer_con ** 2 / @n_tsr_beer_con)
    @ate_tsr_religious_sd = Math.sqrt(@sd_tsr_religious_trt ** 2 / @n_tsr_religious_trt + @sd_tsr_religious_con ** 2 / @avg_tsr_religious_con)
    @ate_tsr_theater_sd = Math.sqrt(@sd_tsr_theater_trt ** 2 / @n_tsr_theater_trt + @sd_tsr_theater_con ** 2 / @n_tsr_theater_con)
    
    @pval_tsr_beer = two_sample_t_test(@y_tsr_beer_trt, @y_tsr_beer_con)
    @pval_tsr_religious = two_sample_t_test(@y_tsr_religious_trt, @y_tsr_religious_con)
    @pval_tsr_theater = two_sample_t_test(@y_tsr_theater_trt, @y_tsr_theater_con)
    
    #now handle the S arm    
    tss = ts.select{|t| t.select_arm?}
    @n_s = tss.length
    
    tss_trt = tss.select{|t| t.treatment}
    tss_con = tss.select{|t| !t.treatment}
    
    tss_trt_studies = tss_trt.map{|t| t.studies.first}.reject{|s| s.outlier}
    tss_con_studies = tss_con.map{|t| t.studies.first}.reject{|s| s.outlier}
    
    tss_trt_beer = tss_trt_studies.select{|s| s.study_name == "framing_beer"}
    tss_trt_religious = tss_trt_studies.select{|s| s.study_name == "priming_dilemma"}
    tss_trt_theater = tss_trt_studies.select{|s| s.study_name == "sunk_cost_theater"}
    
    tss_con_beer = tss_con_studies.select{|s| s.study_name == "framing_beer"}
    tss_con_religious = tss_con_studies.select{|s| s.study_name == "priming_dilemma"}
    tss_con_theater = tss_con_studies.select{|s| s.study_name == "sunk_cost_theater"}  
    
    @y_tss_beer_trt = tss_trt_beer.map{|s| s.response == s.response.to_i ? s.response.to_i : s.response}
    @y_tss_religious_trt = tss_trt_religious.map{|s| s.response.to_i}
    @y_tss_theater_trt = tss_trt_theater.map{|s| s.response.to_i}
    @y_tss_beer_con = tss_con_beer.map{|s| s.response == s.response.to_i ? s.response.to_i : s.response}
    @y_tss_religious_con = tss_con_religious.map{|s| s.response.to_i}
    @y_tss_theater_con = tss_con_theater.map{|s| s.response.to_i} 
    
    @n_tss_beer_trt = @y_tss_beer_trt.length
    @n_tss_religious_trt = @y_tss_religious_trt.length
    @n_tss_theater_trt = @y_tss_theater_trt.length
    @n_tss_beer_con = @y_tss_beer_con.length
    @n_tss_religious_con = @y_tss_religious_con.length
    @n_tss_theater_con = @y_tss_theater_con.length
    
    @avg_tss_beer_trt = samp_avg(@y_tss_beer_trt)
    @avg_tss_religious_trt = samp_avg(@y_tss_religious_trt)
    @avg_tss_theater_trt = samp_avg(@y_tss_theater_trt)
    @avg_tss_beer_con = samp_avg(@y_tss_beer_con)
    @avg_tss_religious_con = samp_avg(@y_tss_religious_con)
    @avg_tss_theater_con = samp_avg(@y_tss_theater_con)
    
    @ate_tss_beer = @avg_tss_beer_trt - @avg_tss_beer_con
    @ate_tss_religious = @avg_tss_religious_trt - @avg_tss_religious_con
    @ate_tss_theater = @avg_tss_theater_trt - @avg_tss_theater_con
    
    @sd_tss_beer_trt = samp_sd(@y_tss_beer_trt)
    @sd_tss_religious_trt = samp_sd(@y_tss_religious_trt)
    @sd_tss_theater_trt = samp_sd(@y_tss_theater_trt)
    @sd_tss_beer_con = samp_sd(@y_tss_beer_con)
    @sd_tss_religious_con = samp_sd(@y_tss_religious_con)
    @sd_tss_theater_con = samp_sd(@y_tss_theater_con) 
    
    @ate_tss_beer_sd = Math.sqrt(@sd_tss_beer_trt ** 2 / @n_tss_beer_trt + @sd_tss_beer_con ** 2 / @n_tss_beer_con)
    @ate_tss_religious_sd = Math.sqrt(@sd_tss_religious_trt ** 2 / @avg_tss_religious_trt + @sd_tss_religious_con ** 2 / @avg_tss_religious_con)
    @ate_tss_theater_sd = Math.sqrt(@sd_tss_theater_trt ** 2 / @n_tss_theater_trt + @sd_tss_theater_con ** 2 / @n_tss_theater_con)
    
    @pval_tss_beer = two_sample_t_test(@y_tss_beer_trt, @y_tss_beer_con)
    @pval_tss_religious = two_sample_t_test(@y_tss_religious_trt, @y_tss_religious_con)
    @pval_tss_theater = two_sample_t_test(@y_tss_theater_trt, @y_tss_theater_con)
    
    #now do heterogeneous effects
    @ate_diff_beer = @ate_tsr_beer - @ate_tss_beer
    @ate_diff_religious = @ate_tsr_religious - @ate_tss_religious
    @ate_diff_theater = @ate_tsr_theater - @ate_tss_theater
    
    @ate_diff_beer_sd = Math.sqrt(@ate_tsr_beer_sd ** 2 + @ate_tss_beer_sd ** 2)
    @ate_diff_religious_sd = Math.sqrt(@ate_tsr_religious_sd ** 2 + @ate_tss_religious_sd ** 2)
    @ate_diff_theater_sd = Math.sqrt(@ate_tsr_theater_sd ** 2 + @ate_tss_theater_sd ** 2)
    
    @pval_ate_diff_beer = two_tailed_normal_probability(@ate_diff_beer / @ate_diff_beer_sd)
    @pval_ate_diff_religious = two_tailed_normal_probability(@ate_diff_religious / @ate_diff_religious_sd)
    @pval_ate_diff_theater = two_tailed_normal_probability(@ate_diff_theater / @ate_diff_theater_sd)
    
    #now handle demographic info
    dems_r = tsr.map{|t| t.demographic}
    dems_s_beer = (tss_trt_beer + tss_con_beer).map{|s| s.task.demographic}
    dems_s_religious = (tss_trt_religious + tss_con_religious).map{|s| s.task.demographic}
    dems_s_theater = (tss_trt_theater + tss_con_theater).map{|s| s.task.demographic}

    @age_r = dems_r.map{|d| d.age}
    @age_s_beer = dems_s_beer.map{|d| d.age}
    @age_s_religious = dems_s_religious.map{|d| d.age}
    @age_s_theater = dems_s_theater.map{|d| d.age}
    
    @male_r = dems_r.map{|d| d.gender == "M" ? 1 : 0}
    @male_s_beer = dems_s_beer.map{|d| d.gender == "M" ? 1 : 0}
    @male_s_religious = dems_s_religious.map{|d| d.gender == "M" ? 1 : 0}
    @male_s_theater = dems_s_theater.map{|d| d.gender == "M" ? 1 : 0}

    @urban_r = dems_r.map{|d| d.urban_rural == "U" ? 1 : 0}
    @urban_s_beer = dems_s_beer.map{|d| d.urban_rural == "U" ? 1 : 0}
    @urban_s_religious = dems_s_religious.map{|d| d.urban_rural == "U" ? 1 : 0}
    @urban_s_theater = dems_s_theater.map{|d| d.urban_rural == "U" ? 1 : 0}

    @num_children_r = dems_r.map{|d| d.num_children}
    @num_children_s_beer = dems_s_beer.map{|d| d.num_children}
    @num_children_s_religious = dems_s_religious.map{|d| d.num_children}
    @num_children_s_theater = dems_s_theater.map{|d| d.num_children}
    
    @income_r = dems_r.map{|d| d.income}.map{|i| i > 1000 ? i / 1000 : i}
    @income_s_beer = dems_s_beer.map{|d| d.income}.map{|i| i > 1000 ? i / 1000 : i}
    @income_s_religious = dems_s_religious.map{|d| d.income}.map{|i| i > 1000 ? i / 1000 : i}
    @income_s_theater = dems_s_theater.map{|d| d.income}.map{|i| i > 1000 ? i / 1000 : i}
    
    @belief_in_divine_r = dems_r.map{|d| d.belief_in_divine == "Y" ? 1 : 0}
    @belief_in_divine_s_beer = dems_s_beer.map{|d| d.belief_in_divine == "Y" ? 1 : 0}
    @belief_in_divine_s_religious = dems_s_religious.map{|d| d.belief_in_divine == "Y" ? 1 : 0}
    @belief_in_divine_s_theater = dems_s_theater.map{|d| d.belief_in_divine == "Y" ? 1 : 0}  
    
    @born_here_r = dems_r.map{|d| d.born_here == "Y" ? 1 : 0}
    @born_here_s_beer = dems_s_beer.map{|d| d.born_here == "Y" ? 1 : 0}
    @born_here_s_religious = dems_s_religious.map{|d| d.born_here == "Y" ? 1 : 0}
    @born_here_s_theater = dems_s_theater.map{|d| d.born_here == "Y" ? 1 : 0}     
    
    @participate_in_study_r = dems_r.map{|d| d.participate_in_study == "Y" ? 1 : 0}
    @participate_in_study_s_beer = dems_s_beer.map{|d| d.participate_in_study == "Y" ? 1 : 0}
    @participate_in_study_s_religious = dems_s_religious.map{|d| d.participate_in_study == "Y" ? 1 : 0}
    @participate_in_study_s_theater = dems_s_theater.map{|d| d.participate_in_study == "Y" ? 1 : 0} 
        
    @english_first_language_r = dems_r.map{|d| d.english_first_language == "Y" ? 1 : 0}
    @english_first_language_s_beer = dems_s_beer.map{|d| d.english_first_language == "Y" ? 1 : 0}
    @english_first_language_s_religious = dems_s_religious.map{|d| d.english_first_language == "Y" ? 1 : 0}
    @english_first_language_s_theater = dems_s_theater.map{|d| d.english_first_language == "Y" ? 1 : 0}   
    
    @nfc_1_r = dems_r.map{|d| d.nfc_1 == "Y" ? 1 : 0}
    @nfc_1_s_beer = dems_s_beer.map{|d| d.nfc_1 == "Y" ? 1 : 0}
    @nfc_1_s_religious = dems_s_religious.map{|d| d.nfc_1 == "Y" ? 1 : 0}
    @nfc_1_s_theater = dems_s_theater.map{|d| d.nfc_1 == "Y" ? 1 : 0}   

    @nfc_2_r = dems_r.map{|d| d.nfc_2 == "Y" ? 1 : 0}
    @nfc_2_s_beer = dems_s_beer.map{|d| d.nfc_2 == "Y" ? 1 : 0}
    @nfc_2_s_religious = dems_s_religious.map{|d| d.nfc_2 == "Y" ? 1 : 0}
    @nfc_2_s_theater = dems_s_theater.map{|d| d.nfc_2 == "Y" ? 1 : 0}  
    
    @big_5_1_r = dems_r.map{|d| d.big_5_1 == "IC" ? 1 : 0}
    @big_5_1_s_beer = dems_s_beer.map{|d| d.big_5_1 == "IC" ? 1 : 0}
    @big_5_1_s_religious = dems_s_religious.map{|d| d.big_5_1 == "IC" ? 1 : 0}
    @big_5_1_s_theater = dems_s_theater.map{|d| d.big_5_1 == "IC" ? 1 : 0}   

    @big_5_2_r = dems_r.map{|d| d.big_5_2 == "EO" ? 1 : 0}
    @big_5_2_s_beer = dems_s_beer.map{|d| d.big_5_2 == "EO" ? 1 : 0}
    @big_5_2_s_religious = dems_s_religious.map{|d| d.big_5_2 == "EO" ? 1 : 0}
    @big_5_2_s_theater = dems_s_theater.map{|d| d.big_5_2 == "EO" ? 1 : 0} 
    
    @big_5_3_r = dems_r.map{|d| d.big_5_3 == "OE" ? 1 : 0}
    @big_5_3_s_beer = dems_s_beer.map{|d| d.big_5_3 == "OE" ? 1 : 0}
    @big_5_3_s_religious = dems_s_religious.map{|d| d.big_5_3 == "OE" ? 1 : 0}
    @big_5_3_s_theater = dems_s_theater.map{|d| d.big_5_3 == "OE" ? 1 : 0} 
    
    @big_5_4_r = dems_r.map{|d| d.big_5_4 == "FC" ? 1 : 0}
    @big_5_4_s_beer = dems_s_beer.map{|d| d.big_5_4 == "FC" ? 1 : 0}
    @big_5_4_s_religious = dems_s_religious.map{|d| d.big_5_4 == "FC" ? 1 : 0}
    @big_5_4_s_theater = dems_s_theater.map{|d| d.big_5_4 == "FC" ? 1 : 0} 
    
    @big_5_5_r = dems_r.map{|d| d.big_5_5 == "SN" ? 1 : 0}
    @big_5_5_s_beer = dems_s_beer.map{|d| d.big_5_5 == "SN" ? 1 : 0}
    @big_5_5_s_religious = dems_s_religious.map{|d| d.big_5_5 == "SN" ? 1 : 0}
    @big_5_5_s_theater = dems_s_theater.map{|d| d.big_5_5 == "SN" ? 1 : 0}             

# highest_education
# marital_status
# employment_status
# race
# religion


  end
  
  def add_as_outlier
    s = Study.find(params[:id])
    s.update_attributes(:outlier => true)
    redirect_to :action => :dashboard
  end
  

end