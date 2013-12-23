#a fairly simple wrapper around the ruby aws interface
module RTurkWrapper
  
  #are we in dev mode?
  SERVER_DEV = Rails.env.development?  #should we use our local computer? or our real server?
  MTURK_DEV = Rails.env.development?   #should we use the sandbox or production with real money?
  
  #Where is the server?
  SERVER = SERVER_DEV ? PersonalInformation::DevServer : PersonalInformation::ProdServer

  #create the connection immediately
  RTurk.setup(PersonalInformation::AwsAccessKeyID, PersonalInformation::AwsSecretKey, :sandbox => MTURK_DEV)
  RTurk::logger.level = Logger::DEBUG

  #other constants that are useful
  PreviewAssignmentId = 'ASSIGNMENT_ID_NOT_AVAILABLE'

  def mturk_create_hit(options = {})
    #error handling
    raise "no title given for HIT" unless options[:title]
    raise "no description given for HIT" unless options[:description]
    raise "no keywords given for HIT" unless options[:keywords]
    raise "no duration given for HIT" unless options[:assignment_duration]
    raise "no auto-approval time given for HIT" unless options[:assignment_auto_approval]
    raise "no wage given for HIT" unless options[:wage]
    raise "no frame height given for HIT" unless options[:frame_height]
    raise "no render URL given for HIT" unless options[:render_url]
    
    # Creating the HIT and loading it into Mechanical Turk, returns it as an object as well
    RTurk::Hit.create(:title => options[:title]) do |hit|
      hit.description = options[:description]
      hit.assignments = 1
      hit.question("http://#{SERVER}#{options[:render_url]}", :frame_height => options[:frame_height])
      hit.reward = options[:wage].round(2)
      hit.lifetime = options[:lifetime]
      hit.keywords = options[:keywords]
      hit.duration = options[:assignment_duration]
      hit.qualifications.add :country, {:eql => options[:country]}
      hit.auto_approval = options[:assignment_auto_approval]
    end
  end

  #other things to set
  DefaultAcceptanceMessage = 'Thanks for a job well done!'
  DefaultBonusMessage = 'Thanks for a superb job! You really went above and beyond and we would like to recognize this.'
  DefaultRejectionFeedback = "Sorry, you did not take our task seriously."
  
  def mturk_approve_assignment(assignment_id, feedback = DefaultAcceptanceMessage)
    RTurk::ApproveAssignment(:assignment_id => assignment_id, :feedback => feedback)
  end

  def mturk_reject_assignment(assignment_id, feedback = DefaultRejectionFeedback)
    RTurk::RejectAssignment(:assignment_id => assignment_id, :feedback => feedback)
  end

  NonBonusBonus = 0.01
  def mturk_bonus_assignment(assignment_id, worker_id, bonus = NonBonusBonus, feedback = DefaultBonusMessage)
    feedback = bonus == NonBonusBonus ? DefaultAcceptanceMessage : feedback
    RTurk::GrantBonus(:assignment_id => assignment_id, :worker_id => worker_id, :amount => bonus, :feedback => feedback)
  end

  def delete_hit_on_mturk(hit_id)
    RTurk::DisableHIT(:hit_id => hit_id)
  end

  def dispose_hit_on_mturk(hit_id)
    RTurk::DisposeHIT(:hit_id => hit_id)
  end

  def mturk_send_emails(subject, body, worker_ids)
    RTurk::NotifyWorkers.create({
      :subject => subject,
      :message_text => body,
      :worker_ids => worker_ids
    })
  end
 
end