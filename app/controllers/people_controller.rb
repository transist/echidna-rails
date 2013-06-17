class PeopleController < ApplicationController
  def stats
    @stats = Person.stats
  end
end
