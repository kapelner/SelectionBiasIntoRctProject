class ExperimentalAdminController < ApplicationController
  include RTurkWrapper

  before_filter :authenticate_admin!
  
  skip_filter :verify_authenticity_token, :only => [:pay, :reject]

  ##### investigate all runs

  MAX_RUNS_TO_DISPLAY = 1000
  BeginPilotTestingTime = Chronic.parse("October 12, 2012")
  def index
    @title = 'Administrator Portal'
    @runs = PersonalInformation::ExperimentalModel.all_current_experimental_version.select{|t| t.id > 805}
    @runs = @runs.reject{|s| s.expired? && !s.completed?} unless params[:rejected]
    @runs = @runs.select{|s| s.completed?} if params[:completed]
    params[:num_runs] ||= MAX_RUNS_TO_DISPLAY
    @runs = @runs.slice(0...params[:num_runs].to_i)
  end

  def completed_hits
    @title = 'Completed HITs'
    @runs_completed = PersonalInformation::ExperimentalModel.all_current_experimental_version_completed
  end

  def comments_page
    @title = 'All Comments'
    @runs = PersonalInformation::ExperimentalModel.all_current_experimental_version_completed
    @runs = @runs.reject{|r| r.comments.blank?} if params[:only_comments]
  end

  def investigate_attrition
    @title = 'Deserted HITs'
    @runs = PersonalInformation::ExperimentalModel.all.select{|r| r.expired_and_uncompleted?}
    @runs = @runs.select{|br| br.treatment == params[:treatment].to_i} if params[:treatment]
  end

  def dashboard
    @title = 'Dashboard'
    @runs_completed = PersonalInformation::ExperimentalModel.all_current_experimental_version_completed
    #kill those that are completed and then kill those that were never started
    @runs_completed = PersonalInformation::ExperimentalModel.all_current_experimental_version_with_abandons.reject{|r| @runs_completed.include?(r)}
  end

  def delete_run
    PersonalInformation::ExperimentalModel.find(params[:id]).delete
    redirect_to :action => :index
  end

  #### investigate one run

  def investigate_run
    @br = PersonalInformation::ExperimentalModel.find(params[:id], :include => PersonalInformation::ExperimentalModel::ModelsToLoadWithEachRun)
    @bbts = BigBrotherTrack.find_all_by_mturk_worker_id(@br.mturk_worker_id, :include => :big_brother_params)
  end

  #### mturk functions create hits, pay, bonus, reject, email workers, cleanup

  def create_hits
    PersonalInformation::ExperimentalModel.create_hitsets_and_post(params[:n].to_i)
    redirect_to :action => :index
  end

  def pay
    run = PersonalInformation::ExperimentalModel.find(params[:id])
    #all checks for valid bonus from javascript
    if params[:bonus] and !params[:bonus].strip.blank? and params[:bonus].strip != 'NaN' and params[:bonus].to_f > 0
      run.send_bonus!(params[:bonus])
      #add them as a star worker if applicable
      if params[:bonus].to_f > NonBonusBonus and StarWorker.find_by_mturk_worker_id(run.mturk_worker_id).nil?
        sw = StarWorker.create(:mturk_worker_id => run.mturk_worker_id)
        sw.introduce!
      end
    end
    run.send_payment_and_dispose!
    render :text => run.pay_status_to_s
  end

  def reject
    run = PersonalInformation::ExperimentalModel.find(params[:id])
    mturk_reject_assignment(run.mturk_assignment_id)
    run.update_attributes(:rejected_at => Time.now)
    dispose_hit_on_mturk(run.mturk_hit_id) #we can also delete it on mturk, tidy up
    render :text => run.pay_status_to_s
  end

  def send_emails_to_workers
    workers = params[:worker_ids].split(',')
    bad_ids = []
    workers.each do |w|
      begin
        mturk_send_emails(params[:subject], params[:body] + "\r\n\r\nWorker: " + w, [w])
      rescue
        bad_ids << w
      end
    end
    render :text => "#{workers.length - bad_ids.length} email(s) sent! #{bad_ids.empty? ? '' : 'Errors: ' + bad_ids.join(', ')}"
  end

  def cleanup_mturk
    flash[:notice] = "Cleaned up #{PersonalInformation::ExperimentalModel.cleanup_mturk!} HIT(s) from MTurk"
    redirect_to :action => :index
  end


  #### dev stuff

  def nuke
    if Rails.env.development?
      PersonalInformation::ExperimentalModel.destroy_all
      SplashView.destroy_all
      BigBrotherTrack.destroy_all
      BigBrotherParam.destroy_all
      SawExperiment.destroy_all
      Demographic.destroy_all
      Task.delete_all_hits_from_mturk!
    else
      flash[:error] = 'You cannot nuke the db on production'
    end
    redirect_to :action => :index
  end

  def rebuild_db
    if Rails.env.development?
      #to be done if needed
      flash[:notice] = %Q|Data rebuilt|
    else
      flash[:error] = 'You cannot rebuild the db on production'
    end
    redirect_to :action => :index
  end


  #add your test worker IDs here
  DEV_WORKERS = %w(A2SJTN3TTSP056)
  def nuke_dev_workers
    trans = PersonalInformation::ExperimentalModel.find_all_by_mturk_worker_id(DEV_WORKERS).each{|s| s.destroy}
    flash[:notice] = "nuked #{trans.length} transcriptions(s), nuked #{colors.length} color blindness test(s), #{quals.length} qualification(s)"
    redirect_to :action => :index
  end

  def create_hit_set
    PersonalInformation::ExperimentalModel.create_hitset_and_post!
    redirect_to :action => :index
  end

  ################ Investigate an individual run

  def update_run_notes
    PersonalInformation::ExperimentalModel.find(params[:id]).update_attributes(:notes => params[:notes])
    render :nothing => true #ajax
  end

end