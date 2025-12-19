class WelcomeController < ApplicationController
  def index
    render json: { message: "welcome to news app" }
  end
end

