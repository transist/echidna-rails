class PanelsController < InheritedResources::Base
  def create
    create! { root_url }
  end

  def trends
    length, period = parse_period(params[:period])
    @job_id = PanelTrendsWorker.perform_async(resource.id, length, period)
    show!
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
