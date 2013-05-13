class PanelsController < InheritedResources::Base
  def create
    create! { root_url }
  end

  def trends
    params[:time] ||= Time.now
    @z_scores = resource.z_scores(params[:time])
    show!
  end

protected
  def begin_of_association_chain
    current_user
  end
end
