class TweetsController < InheritedResources::Base
  def spam
    resource.spam!
    render json: {}
  end

  def spam_user
    resource.person.spam!
    render json: {}
  end
end
