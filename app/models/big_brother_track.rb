class BigBrotherTrack < ActiveRecord::Base
  has_many :big_brother_params, :dependent => :destroy

  attr_accessor :delta_t
  attr_accessor :total_time_for_session
  
  attr_accessible :controller, :action, :mturk_worker_id, :ip, :method, :ajax

  def <=>(other)
    case
      when self.id > other.id then 1
      when self.id < other.id then -1
    end
  end
end
