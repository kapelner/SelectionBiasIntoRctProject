class TaskController < ApplicationController

  layout 'task'

  #index never renders... it's just a big switchboard redirecting requests left or right
  def index
    #if it's a preview, then we want to show them a special splash page
    if params[:assignmentId] == RTurkWrapper::PreviewAssignmentId
      SplashView.create(:ip_address => request.ip)
      redirect_to :action => 'splash_page'
      return
    end
    
    #pull out the task from the db
    @t = Task.find(params[:id])    
    
    #kick them out if they've seen it before
    if SawExperiment.seen_the_experiment_previously?(params[:workerId], @t.id)
      redirect_to :action => :only_once
      return
    end        

    #if this task was previously completed, we need to move them away
    if @t.completed?
      redirect_to :action => :run_completed, :id => @t.id
      return
    end
    

    #increment the number of page reloads
    @t.increment!(:num_page_reloads)
    
    #start the timer if this is the first time in this HIT
    @t.update_attributes(:started_at => Time.now) if params[:workerId] != @t.mturk_worker_id

    #assign this task to this particular worker
    @t.update_attributes(:mturk_worker_id => params[:workerId], :ip_address => request.ip)

    #assign the assignment ID
    @t.update_attributes(:mturk_assignment_id => params[:assignmentId])    

    #did they do the demographic pretest? If they didn't send them to it
    if Demographic.find_by_mturk_worker_id(params[:workerId]).nil?
      redirect_to :action => :demographics,
        :workerId => params[:workerId],
        :id => @t.id,
        :assignmentId => params[:assignmentId]
      return
    end
    
    #send subjects in the S arm to the selection page
    if @t.select_arm_and_study_unselected?
      redirect_to :action => :select_study, :id => @t.id
    #if they're in the R arm, they're off to the study itself
    else
      redirect_to :action => :study, :id => @t.id
    end     
  end
  
  # Special splash page for the preview.
  ####
  # Script for video
  # Hello. We are a major marketing company located in the United States
  # focused on elicing opinions from people like you. By participating,
  # you are helping answer questions about social, cultural, and
  # economic issues which have national importance. Thanks again.
  def splash_page
  end
  
  #message saying they can only do the HIT once
  def only_once
  end


  # The demographic covariate collection
  def demographics
    @t = Task.find(params[:id])
    #need to make sure to indicate a certain worker has seen the experiment before
    if SawExperiment.find_by_task_id_and_mturk_worker_id(@t.id, params[:workerId]).nil?
      SawExperiment.create(:task_id => @t.id, :mturk_worker_id => params[:workerId])
    end
    if request.post?    
      Demographic.create(params[:demographic].merge(:mturk_worker_id => params[:workerId]))
      redirect_to :action => :index, :id => @t.id, :assignmentId => params[:assignmentId], :workerId => params[:workerId]
    end
  end  
  
  def select_study
    @t = Task.find(params[:id])
    if request.post?
      @t.update_attributes(:study_list => Study.randomize_study_list_but_first_is(params[:study_name]))
      #now we're off to the study itself!
      redirect_to :action => :study, :id => @t.id      
    end        
  end
  
  def study
    @t = Task.find(params[:id])

    #make sure that a study object exists with randomized treatment or control
    if @t.studies.empty?
      @t.studies << Study.create(:task_id => @t.id, :study_name => @t.current_study_name)
    end     

    if request.post?
      #save response to study
      @t.current_study.update_attributes(:response => params[:study][:response], :responded_at => Time.now)
      #if they finished all the studies, it's time to move on to the next one
      if @t.finished_all_studies?
        redirect_to :action => :leave_comments, :id => @t.id
      #they didn't finish all the studies, so let's give them another one
      else
        #bump up their study number
        @t.increment!(:current_study_num)
        #create a new study
        Study.create(:task_id => @t.id, :study_name => @t.current_study_name)
        #now send them back to the study action so the next study renders
        redirect_to :action => :study, :id => @t.id
      end
    end
  end

  def leave_comments
    @t = Task.find(params[:id])
    if request.post?
      @t.update_attributes(params[:task])
      redirect_to :action => :mturk_submit, :id => @t.id
    end
  end

  def mturk_submit
    @t = Task.find(params[:id])
    #mark it finally completed... now it's out of our hands
    @t.update_attributes(:finished_at => Time.now)
  end
  
  #record if the user goes away from the main window during the study
  def record_nav_away
    Study.find(params[:study_id]).increment!(:num_page_nav_away)
    render :nothing => true
  end

  # What to to show if they try to access a task that's already been completed
  def run_completed
  end

  # What to show to snooping people.
  def unauthorized
  end
end