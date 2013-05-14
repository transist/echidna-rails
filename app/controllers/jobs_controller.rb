class JobsController < ApplicationController
  respond_to :json

  def status
    @job = SidekiqStatus::Container.load(params[:id])
    respond_with @job
  end
end
