class OwnerController < ApplicationController
  def index
    @owners = Owner.all
  end

  def new
    @owner = Owner.new
  end

  def create
    @owner = Owner.new(owner_params)

    if @owner.save
      redirect_to :controller => "owner", :action => "index"
    else
      render 'new'
    end

  end

  def edit
    @owner = Owner.find(params[:id])
  end

  def update
    @owner = Owner.find(params[:id])
   
    if @owner.update(owner_params)
      redirect_to :controller => "owner", :action => "index"
    else
      redirect_to :controller => "owner", :action => "edit"
    end 
  end

  def destroy
    @owner = Owner.find(params[:id])
    @owner.destroy
    redirect_to :controller => "owner", :action => "index"
  end

  private

    def owner_params
      params.require(:owner).permit(:name, :country, :position)
    end

end
