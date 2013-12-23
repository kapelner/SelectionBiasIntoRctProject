
module DataDump
  SeparationChar = ','
  StrftimeForDates = '%m/%d/%y'
  StrftimeForTimes = '%H:%M:%S'

  #include DataDump; DataDump.dump_exp_data
  def DataDump.dump_exp_data
    filename = "#{Rails.root}/data_dump/statturk_dump_#{Time.now.strftime('%m_%d_%y__%H_%M')}.csv"
    write_out = File.new(filename, "w")
    #header
    row = %w(
      task_id
      mturk_worker_id
      subject_started_at
      subject_finished_at
      ip_address
      experimental_arm
      treatment
      num_page_reloads
      splash_views_before_starting
      splash_views_after_starting      
      age
      gender
      urban_rural
      highest_education
      marital_status
      employment_status
      num_children
      income
      religion
      belief_in_divine
      race
      participate_in_study
      born_here
      english_first_language
      nfc_1
      nfc_2
      big_5_1
      big_5_2
      big_5_3
      big_5_4
      big_5_5
      demographic_started_at
      demographic_completed_at
      study_num
      study_started
      study_name
      response
      study_finished
      num_page_nav_away
      outlier_data_point
      turker_comments     
    )
    write_out.puts(row.join(SeparationChar))

    #run this as a find_each to get around the memory issues...
    Task.find_each(:batch_size => 20, :include => :studies) do |t|
      #only those completed
      next unless t.completed?
      
      #get some useful data
      svs = SplashView.where(:ip_address => t.ip_address)
      d = t.demographic
      ss = t.studies
      
      ss.each_with_index do |s, i|
        row = []
        #task related
        row << t.id
        row << t.mturk_worker_id
        row << t.started_at.to_i
        row << t.finished_at.to_i
        row << t.ip_address
        row << t.exp_arm
        row << t.treatment
        row << t.num_page_reloads
        row << svs.select{|sv| sv.created_at < t.started_at}.length
        row << svs.select{|sv| sv.created_at > t.finished_at}.length
        #demographic related
        row << d.age
        row << d.gender
        row << d.urban_rural
        row << d.highest_education
        row << d.marital_status
        row << d.employment_status
        row << d.num_children
        row << d.income
        row << d.religion
        row << d.belief_in_divine
        row << d.race
        row << d.participate_in_study
        row << d.born_here
        row << d.english_first_language
        row << d.nfc_1
        row << d.nfc_2
        row << d.big_5_1
        row << d.big_5_2
        row << d.big_5_3
        row << d.big_5_4
        row << d.big_5_5
        row << d.created_at.to_i
        row << d.completed_at.to_i   
        #study related
        row << i
        row << s.created_at.to_i
        row << s.study_name
        row << s.response
        row << s.responded_at.to_i
        row << s.num_page_nav_away
        row << s.outlier
        #show the turker's comments
        row << safe_string(t.turker_comments) 
        #write it to file
        write_out.puts(row.join(SeparationChar))
      end     
      
    end
    
    #final stuff
    write_out.close
    filename
  end
  
  private
  LinebreakToken = "<line>"
  DelimeterToken = "<com>"
  QuoteToken = "<qu>"
  def DataDump.safe_string(str)
    str = str.to_s.gsub("\r\n", LinebreakToken)
    str = str.to_s.gsub("\n", LinebreakToken)
    str = str.to_s.gsub("\r", LinebreakToken)
    str = str.to_s.gsub("\"", QuoteToken)
    str = str.to_s.gsub("'", QuoteToken)
    str = str.to_s.gsub(SeparationChar, DelimeterToken)
  end
end