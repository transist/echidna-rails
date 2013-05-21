class PanelsController < InheritedResources::Base
  def create
    create! { root_url }
  end

  def trends
    length, period = parse_period(params[:period])
    @job_id = TrendsWorker.perform_async(params[:id], current_user.id.to_s, length, period)
    respond_to do |format|
      format.html { show! }
      format.json { render json: {job_id: @job_id} }
    end
  end

  def tweets
    length, period = parse_period(params[:period])
    @job_id = TweetsWorker.perform_async(params[:id], params[:word], length, period)
    respond_to do |format|
      format.json { render json: {job_id: @job_id} }
    end
  end

protected
  def begin_of_association_chain
    current_user
  end

  def parse_period(period)
    case period
    when "month"
      [30, "days"]
    when "week"
      [7, "days"]
    when "day"
      [24, "hours"]
    else
      [7, "hours"]
    end
  end
end
