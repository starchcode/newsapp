class WelcomeController < ApplicationController
  def index
    render json: { message: "welcome to backend" }
  end
end

