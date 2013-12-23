module ExperimentalRunMixin

  attr_accessor :batch

  # Sendind someone back to the ExperimentalController index method.
  def redirect_address
    {:action => :index, :id => self.id, :workerId => self.mturk_worker_id, :assignmentId => self.mturk_assignment_id}
  end

  def has_duplicate_questions?
    false
  end

  # Tests to see if the rejected space has a time or not.
  def rejected?
    !self.rejected_at.nil?
  end

  # Pay the MTurker a bonus
  def send_bonus!(amt)
    mturk_bonus_assignment(self.mturk_assignment_id, self.mturk_worker_id, amt)
    self.update_attributes(:bonus => amt)
  end

  #even regular old acceptances get a tiny bonus... that's a trick to keep the workers happy
  def send_payment_and_dispose!
    mturk_bonus_assignment(self.mturk_assignment_id, self.mturk_worker_id)
    mturk_approve_assignment(self.mturk_assignment_id)
    self.update_attributes(:paid_at => Time.now)
    dispose_hit_on_mturk(self.mturk_hit_id) #we can also delete it on mturk, tidy up
  end

  # Tests to see if the paid space has a time or not.
  def paid?
    !self.paid_at.nil?
  end

  # Tests to see if the completed space has a time or not.
  def completed?
    !self.finished_at.nil?
  end

  # Measured the difference between start times and end times.
  def time_spent
    return nil if self.finished_at.nil?
#    if self.completed?
      self.finished_at - self.started_at
#    else
#      Time.now - self.started_at
#    end
  end

  # Generates an html snippet on the status of the payment.
  def pay_status_to_s
    if self.paid?
      %Q|<span style="color:green;">#{self.bonus.nil? ? "paid" : "bonus (#{self.bonus})"}</span>|
    elsif self.rejected?
      %Q|<span style="color:red;">rej</span>|
    end
  end

  # Checks to see if a transcription has expired.
  def expired?
    Time.now > self.to_be_expired_at
  end

  # Checks to see if a transcription has expired and not been completed.
  def expired_and_uncompleted?
    self.expired? and !self.completed?
  end

  # Checks to see if a transcription has been started.
  def started?
    !self.started_at.nil?
  end

  # Counts the number of works (in the form of tokens) of the MTurker's comments
  def comments_word_count
    self.turker_comments.present? ? self.turker_comments.split(/\s/).length : 0
  end

  #if we ever want to do experiments with different treatments...
  RandomizedTreatments = []
  TreatmentNames = {}

  # TODO: Create description for this method.
  def treatment_to_s
    TreatmentNames[self.treatment]
  end

  #CLASS METHODS
  module ClassMethods

    # Pays off the unpaid jobs. Does this by running through all of the transcription entries
    # and pulling out all entries that have been completed but not paid.
    # For each one of these, it calls up up the send_payment_and_dispose! method.
    # If that method fails, it prints out an entry.
    def pay_those_unpaid!
      self.all.select{|run| run.completed? and !run.paid?}.each do |run|
        begin
          run.send_payment_and_dispose!
        rescue
          p "couldn't pay disambiguation #{run.id}"
        end
      end
    end

    def all_current_experimental_version
      self.where(["created_at > ?", ExperimentalAdminController::BeginPilotTestingTime])
    end

    
    #cd /data/clistify2/current && bundle exec rails runner -e production "Task.create_hitsets_and_post(100)" 2>&1 | cat >> /tmp/cron_jobs
    def create_hitsets_and_post(n)
      (n/5).times{self.create_a_hit_and_post!}
    end

    def all_current_experimental_version_completed
      all = self.all_current_experimental_version.select{|run| run.completed?}
      self.assign_batches(all)
    end

    def all_current_experimental_version_with_abandons
      all = self.all_current_experimental_version.reject{|run| run.has_duplicate_questions?}
      self.assign_batches(all)
    end

    TimeBetweenBatches = 10.minutes #the cron job does not take more than 10 min to create any number of HITs
    def assign_batches(runs = self.all)
      current_batch = 1
      #sort by when it was created
      runs = runs.sort{|a, b| a.created_at <=> b.created_at}
      runs.each_with_index do |s, i|
        if i > 0 and s.created_at - runs[i - 1].created_at > TimeBetweenBatches
          current_batch += 1
        end
        s.batch = current_batch
      end
    end

    def cleanup_mturk!
      self.all.reverse.inject(0) do |num_cleaned, run|
        if run.expired? and !run.paid? and !run.rejected?
          begin
            p dispose_hit_on_mturk(run.mturk_hit_id)
            num_cleaned += 1
          rescue => e
            p e
          end
        end
        num_cleaned
      end
    end

    def delete_all_hits_from_mturk!
      self.all.each do |run|
        begin
          p dispose_hit_on_mturk(run.mturk_hit_id)
          p delete_hit_on_mturk(run.mturk_hit_id)
        rescue #don't do anything, who cares
        end
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
