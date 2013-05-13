module PanelsHelper
  def panels_links
    current_user.panels.each { |panel|
      concat content_tag('p', link_to("Panel: #{panel.to_s}", trends_panel_path(panel)))
    }
    nil
  end

  def current_period
    "1 " + (params[:period] || "day")
  end

  def cities_options_for_select
    City.all.map {|city| [city.name, city.id] }
  end

  def age_ranges_options_for_select
    Person::BIRTH_YEARS.map { |birth_year| ["#{birth_year[:start]} - #{birth_year[:end]}", "#{birth_year[:start]} - #{birth_year[:end]}"]}
  end

  def gender_options_for_select
    Person::GENDERS.map { |gender| [gender, gender] }
  end
end
