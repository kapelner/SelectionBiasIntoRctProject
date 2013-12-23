class ApplicationController < ActionController::Base

  # Protects from false post requests.
  protect_from_forgery

  before_filter :big_brother_track #track what users are doing

  ControllersNotToTrack = %w()
  def big_brother_track
    #don't log certain controller's activity
    return if ControllersNotToTrack.include?(controller_name)
    #now log it:
    bbt = BigBrotherTrack.create({
      :controller => controller_name,
      :action => params[:action],
      :mturk_worker_id => params[:workerId], #if the user is working on our hits
      :ip => request.remote_ip,
      :method => request.method.to_s,
      :ajax => request.xhr?
    })

    # Log the parameters.
    params.each do |key, val|

      #we've already got these:
      next if %w(action controller entry language).include?(key)

      # Don't retain files
      next unless val.is_a?(String)
      BigBrotherParam.create({
        :param => key.to_s,
        :value => val.to_s,
        :big_brother_track => bbt
      })
    end
    true
  end

end
