class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def edit
    @locales = [['English', :en], ['Traditional Chinese', :'zh-TW']]
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to edit_user_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
   
    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:locale, :currency)
    end
end
