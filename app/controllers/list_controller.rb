class ListController < ApplicationController
  
  before_filter :ensure_user_is_logged_in, :except =>  %w{ index }
  before_filter :find_list, :except => %w{ new create choose api_create }
  before_filter :check_can_edit_list, :except => %w{ index new create choose api_create }
  
  def new
    @list = List.new
    @list.ex_directory = true
  end
  
  def api_create
    @list = List.new params[:list]
    logger.debug params[:list]
    logger.debug @list.name
    logger.debug @list.list_type
    logger.debug "Hey"
    if @list.save
      @list.users << User.current
		  headers["Content-Type"] = "text/xml; charset=utf-8"
  		render :layout => false, :action => 'xml'
    else
      render :status => 500
    end
  end

  def create
    @list = List.new params[:list]
    if @list.save
      @list.users << User.current
      flash[:confirm] = "Successfully created  &#145;#{@list.name}&#146;"
      if params[:return_to]
        redirect_to params[:return_to]
      else
        redirect_to list_path(:id => @list.id)
      end    
    else
      render :action => 'new'
    end
  end
  
  # Other views include edit and edit_details
  
  def update
    if @list.update_attributes( params[:list] )
      flash[:confirm] = 'Details updated.'
    end
    redirect_to :action => 'edit', :id => @list
  end
  
  # Delete this list
  def destroy
    @list.sort_of_delete
    @list.save
    flash[:confirm] = "List &#145;#{@list.name}&#146; has been deleted."
    if User.current.personal_list
      redirect_to list_url(:id => User.current.personal_list.id )
    else
      redirect_to home_url
    end
  end
  
  # Still left over. Need to refactor this elsewhere
  
  def choose
    @lists = User.current.lists
  end
    
  private
  
  # Filters
  
  def find_list
    @list = List.find params[:id]
  end
  
  def check_can_edit_list
    return true if @list.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
end
