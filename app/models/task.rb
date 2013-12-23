class Task < ActiveRecord::Base
  include ExperimentalRunMixin
  include StatTurkMTurk
  extend StatTurkMTurk
  include StudyLib
  
  has_many :studies, :dependent => :destroy 
  has_many :saw_experiments, :dependent => :destroy
  
  serialize :study_list #this is the array of studies (in order)
  
  attr_accessible :task_id,
    :mturk_hit_id,
    :mturk_group_id,
    :version,
    :wage,     
    :to_be_expired_at,
    :country,
    :mturk_assignment_id,
    :mturk_worker_id,
    :ip_address,
    :started_at,
    :turker_comments,
    :finished_at,
    :browser_info,
    :rejected_at,
    :paid_at,
    :bonus,
    :notes,
    :current_study_num,
    :study_list,
    :exp_arm,
    :treatment
  
  def Task.create_a_hit_and_post!
    t = self.new
    #standard stuff
    t.version = PersonalInformation::CURRENT_EXPERIMENTAL_VERSION_NO
    t.wage = EXPERIMENTAL_WAGE
    t.country = EXPERIMENTAL_COUNTRY
    t.to_be_expired_at = DEFAULT_HIT_LIFETIME.seconds.from_now
    t.initialize_experiment
    t.save!
    mturk_hit = mturk_create_statturk_study_hit(t.id)
    t.mturk_hit_id = mturk_hit.hit_id
    t.mturk_group_id = mturk_hit.type_id
    t.save!
    t
  end
  
  def initialize_experiment
    #first randomly assign the subject to the R or S wing
    self.exp_arm = rand < 0.5 ? "R" : "S"
    #now randomly assign whether they'll get all treatments or all controls
    self.treatment = rand < 0.5
    #then randomly assign an order of the studies
    self.study_list = StudyList.sort_by{rand} if self.random_study_arm?
    #the current study num is autoset to be zero
  end
  
  def current_study_name
    self.study_list[self.current_study_num]
  end
  
  def current_study
    self.studies.detect{|s| s.study_name == self.current_study_name}
  end
    
  def random_study_arm?
    self.exp_arm == "R"
  end

  def select_arm?
    self.exp_arm == "S"
  end
  
  def select_arm_and_study_unselected?
    self.select_arm? and self.study_list.nil?
  end
  
  def first_response
    self.studies.any? ? self.studies.first.response : nil
  end
  
  def Task.worker_completed_hit_already?(mturk_worker_id)
    Task.where(:mturk_worker_id => mturk_worker_id).detect{|t| t.completed?}
  end
  
  def finished_all_studies?
    self.studies.length == self.study_list.length
  end
  
  def num_splash_views_before_starting
    SplashView.where(:ip_address => self.ip_address).select{|sv| sv.created_at < self.started_at}.length
  end
  
  def demographic
    Demographic.find_by_mturk_worker_id(self.mturk_worker_id)
  end
  
end
