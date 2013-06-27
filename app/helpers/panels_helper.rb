module PanelsHelper
  def current_period
    "1 " + (params[:period] || "day")
  end

  def cities_options_for_select
    City.all.map {|city| [city.name, city.id] }
  end

  def age_ranges_options_for_select
    Person::BIRTH_YEARS.map do |birth_year|
      if birth_year.first == Person::BIRTH_YEAR_UNKNOWN
        ['Unknown', "#{birth_year.first} - #{birth_year.last}"]
      else
        ["#{birth_year.first} - #{birth_year.last}", "#{birth_year.first} - #{birth_year.last}"]
      end
    end
  end

  def gender_options_for_select
    Person::GENDERS.map { |gender| [gender, gender] }
  end
end
