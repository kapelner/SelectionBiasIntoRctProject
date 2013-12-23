class SawExperiment < ActiveRecord::Base
  belongs_to :task
  
  attr_accessible :task_id, :mturk_worker_id
  
  def SawExperiment.seen_the_experiment_previously?(mturk_worker_id, task_id)
    #get all the times he's seen the experiment, if there was a time he saw the
    #experiment while doing another task besides this one, he gets nuked
    SawExperiment.where(:mturk_worker_id => mturk_worker_id).each do |se|
      return true if se.task_id != task_id
    end
    false
  end
end
