class TweetsController < InheritedResources::Base
  def spam_user
    resource.person.spam!
    render json: {}
  end
end
