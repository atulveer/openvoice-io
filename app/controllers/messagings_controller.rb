class MessagingsController < ApplicationController

  # before_filter :require_user, :only => [:index, :show, :new, :edit, :update, :destroy]

  def index
    # @messagings = current_user.messagings.reverse
    @messagings = Messaging.all(:user_id => session[:current_user_id]) #TODO - reverse order

    respond_to do |format|
      format.html
      format.json { render :json => @messagings }
      format.xml  { render :xml => @messagings }
    end
  end

  def show
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @messaging }
    end
  end

  def new
    @messaging = Messaging.new
    @messaging.to = params[:to] unless params[:to].nil?
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @messaging }
    end
  end

  def create
    current_user = params[:user_id]
    
    from = to = ""
    # if session = params[:session]
    if params[:session] # TODO - Validate
      
      # then this is a request from tropo, create an incoming message
      from = session[:from][:id]
      text = session[:initialText]
      @user = User.find(1)
      to = @user.login
      # @messaging = Messaging.new(:from => from, :text => text, :to => to, :user_id => @user.id, :outgoing => false)
      
      messaging = Messaging.new
      messaging.attributes = {
        :from => from,
        :to => to,
        :text => text,
        :user_id => @user.id,
        :outgoing => false,
        :created_at => Time.now()
      }
      
      outgoing = false
      
    else
      # then this is a request to tropo, create an outgoing message
      # @user = current_user
      
      # @messaging = Messaging.new(params[:messaging].merge({ :from => current_user.login,
                                                            # :user_id => current_user.id,
                                                            # :outgoing => true }))

      user = User.first(:id => current_user)
      messaging = Messaging.new
      messaging.attributes = {
        :from => user.email,
        :to => params[:messaging][:to],
        :text => params[:messaging][:text],
        :user_id => current_user,
        :outgoing => true,
        :created_at => Time.now()
      }

      from = user.email
      to = params[:messaging][:to]
      text = params[:messaging][:text]
      outgoing = true

    end
    

    respond_to do |format|
      if messaging.save
        
        if outgoing
          # msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_MESSAGING_TEMP + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)
          # open(msg_url) do |r|
          #   p r
          # end

          args = {
            'action'  => 'create',
            'token'   => OUTBOUND_MESSAGING_TEMP, 
            'from'    => from, 
            'to'      => to,
            'text'    => CGI::escape(text)
          }

          result = AppEngine::URLFetch.fetch('http://api.tropo.com/1.0/sessions',
            :payload => Rack::Utils.build_query(args),
            :method => :get,
            :headers => {'Content-Type' => 'application/x-www-form-urlencoded'})


        end
        
        
        flash[:notice] = 'Messaging was successfully created.'
        format.html { redirect_to('/users/' + current_user.to_s + '/messagings') }
        format.xml  { render :xml => messaging, :status => :created, :location => messaging }
        format.json { render :json => messaging }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => messaging.errors, :status => :unprocessable_entity }
        format.json { render head => 404 }
      end
    end
  end
  
  def edit
    current_user = params[:user_id]
    @user = current_user
    @messaging = Messaging.find(params[:id])
  end

  def update
    current_user = params[:user_id]
    @messaging = Messaging.find(params[:id])

    respond_to do |format|
      if @messaging.update_attributes(params[:messaging])
        flash[:notice] = 'Messaging was successfully updated.'
        format.html { redirect_to('/users/' + current_user.to_s + '/messagings') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @messaging.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user = params[:user_id]
    @messaging = Messaging.find(params[:id])
    @messaging.destroy

    respond_to do |format|
      format.html { redirect_to('/users/' + current_user.to_s + '/messagings') }
      format.xml  { head :ok }
    end
  end
  
  
end
