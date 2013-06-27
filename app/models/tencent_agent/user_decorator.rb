class TencentAgent
  module UserDecorator
    module_function

    # 北京 天津 上海 重庆
    SPECIAL_CITIES = [11, 12, 31, 50]

    def decorate(user)
      decorate_city(user)
      decorate_gender(user)
      decorate_birth_year(user)
    end

    private
    module_function

    def decorate_city(user)
      case user['province_code'].to_i
      when 0
        user['city'] = 'Unknown'
      when *SPECIAL_CITIES
        user['city'] = get_location_by_key(user['province_code'])
      else
        case user['city_code'].to_i
        when 0
          user['city'] = 'Unknown'
        else
          key = user['province_code'].to_s + ':' + user['city_code']
          user['city'] = get_location_by_key(key)
        end
      end
      user
    end

    def decorate_gender(user)
      case user['sex']
      when 1
        user['gender'] = 'male'
      when 2
        user['gender'] = 'female'
      else
        user['gender'] = 'unknown'
      end
      user
    end

    def decorate_birth_year(user)
      case user['birth_year']
      when 0
        user['birth_year'] = Person::BIRTH_YEAR_UNKNOWN
      end
      user
    end

    def get_location_by_key(key)
      @location ||= MultiJson.load(File.read(Rails.root.join('data/TencentLocation.json')))
      @location[key]
    end
  end
end
