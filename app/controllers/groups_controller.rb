class GroupsController < InheritedResources::Base
  def create
    create! { root_url }
  end

  protected

  def begin_of_association_chain
    current_user
  end
end
