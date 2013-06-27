module Support
  module Groups
    def seed_groups
      @city_shanghai = create(:city_shanghai)
      @city_beijing = create(:city_beijing)
      @city_guangzhou = create(:city_guangzhou)
      @city_chengdu = create(:city_chengdu)
      @city_hangzhou = create(:city_hangzhou)
      @city_qingdao = create(:city_qingdao)
      @city_unknown = create(:city_unknown)

      Group.create_groups!
    end
  end
end

RSpec.configure do |config|
  config.include Support::Groups
end
