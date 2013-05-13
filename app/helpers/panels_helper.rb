module PanelsHelper
  def cities_options_for_select
    City.all.map {|city| [city.name, city.id] }
  end

  def age_ranges_options_for_select
    Person::BIRTH_YEARS.map { |birth_year| ["#{birth_year.first} - #{birth_year.last}", "#{birth_year.first} - #{birth_year.last}"]}
  end

  def gender_options_for_select
    Person::GENDERS.map { |gender| [gender, gender] }
  end
end
