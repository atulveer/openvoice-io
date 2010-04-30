class CallLogsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]
  
  def index
    # @call_logs = CallLog.all
    @call_logs = CallLog.all(:user_id => session[:current_user_id], :order => [ :created_at.desc ])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @call_logs }
    end
  end

  def show
    @call_log = CallLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @call_log }
    end
  end

  def new
    @call_log = CallLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @call_log }
    end
  end

  def create
    current_user = session[:current_user_id]
    @call_log = CallLog.new
    @call_log.attributes = {
      :to => params[:call_log][:to],
      :from => params[:call_log][:from],
      :nature => params[:call_log][:nature],
      :user_id => current_user,
      :created_at => Time.now()
    }
    
    # @call_log = CallLog.new(params[:call_log])

    respond_to do |format|
      if @call_log.save
        flash[:notice] = 'CallLog was successfully created.'
        format.html { redirect_to(@call_log) }
        format.xml  { render :xml => @call_log, :status => :created, :location => @call_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    current_user = session[:current_user_id]
    @call_log = CallLog.find(params[:id])

    respond_to do |format|
      if @call_log.update_attributes(params[:call_log])
        flash[:notice] = 'CallLog was successfully updated.'
        format.html { redirect_to(@call_log) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @call_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = session[:current_user_id]
    @call_log = CallLog.find(params[:id])
    @call_log.destroy

    respond_to do |format|
      format.html { redirect_to('/users/' + current_user.to_s + '/call_logs') }
      format.xml  { head :ok }
    end
  end
end
