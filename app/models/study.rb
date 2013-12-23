class Study < ActiveRecord::Base
  include StudyLib
  
  belongs_to :task
  
  attr_accessible :task_id,
    :study_name,
    :response, 
    :responded_at,
    :num_page_reloads,
    :num_page_nav_away,
    :outlier
    
  def Study.randomize_study_list_but_first_is(first_study)
    full_list = StudyList.sort_by{rand}
    full_list.delete(first_study)
    [first_study, full_list].flatten
  end
end
