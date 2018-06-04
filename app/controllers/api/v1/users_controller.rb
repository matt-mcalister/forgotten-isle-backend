class Api::V1::UsersController < ApplicationController

  def create
    @user = User.find_or_create_by(name: user_params[:name])
    render json: @user
  end

  private
    def user_params
      params.require(:user).permit(:id, :name)
    end

end
