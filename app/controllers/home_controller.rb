class HomeController < ApplicationController
  def dashboard
    @groups = current_user.groups
  end
end
