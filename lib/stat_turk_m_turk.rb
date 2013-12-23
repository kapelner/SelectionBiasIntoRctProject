module StatTurkMTurk
  include RTurkWrapper

  #hit defaults
  EXPERIMENTAL_WAGE = 0.05 #in USD
  DefaultBonus = 0.0 #in USD
  EXPERIMENTAL_COUNTRY = 'US'
  DEFAULT_HIT_TITLE = "Give your opinion on a survey for a major marketing company"
  DEFAULT_HIT_DESCRIPTION = %Q|Give your opinion on a survey for a major marketing company|
  DEFAULT_HIT_KEYWORDS = "survey, opinion, marketing"
  #time related HIT defualts
  DEFAULT_ASSIGNMENT_DURATION = 12 * 60 # you only get 12 minutes to do this... hurry up!!!
  DEFAULT_HIT_LIFETIME = 60 * 57 # 57 min since cron jobs (not specified here) run every one hour
  DEFAULT_ASSIGNMENT_AUTO_APPROVAL = 60 * 60 * 24 * 2 # 2 days
  DEFAULT_FRAME_HEIGHT = 800

  def mturk_create_statturk_study_hit(run_id, options = {})
    options[:title] ||= DEFAULT_HIT_TITLE
    options[:description] ||= DEFAULT_HIT_DESCRIPTION
    options[:keywords] ||= DEFAULT_HIT_KEYWORDS
    options[:assignment_duration] ||= DEFAULT_ASSIGNMENT_DURATION
    options[:lifetime] ||= DEFAULT_HIT_LIFETIME
    options[:assignment_auto_approval] ||= DEFAULT_ASSIGNMENT_AUTO_APPROVAL
    options[:frame_height] ||= DEFAULT_FRAME_HEIGHT
    #stuff that's more likely to change
    options[:country] = EXPERIMENTAL_COUNTRY
    options[:wage] = EXPERIMENTAL_WAGE
    #for the actual url that hits our server (do not touch)
    options[:render_url] = "/#{PersonalInformation::ExperimentalController}/index?id=#{run_id}"
    #create the hit and return its data
    mturk_create_hit(options)
  end
end