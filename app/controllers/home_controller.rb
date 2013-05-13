class HomeController < ApplicationController
  def dashboard
    @panels = current_user.panels
  end
end
