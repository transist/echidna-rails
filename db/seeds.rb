# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
City.delete_all
User.delete_all

puts 'DEFAULT USERS'
user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name

["北京", "上海", "广州", "深圳", "天津", "重庆"].each do |city_name|
  City.create name: city_name, tier: "Tier 1"
end
["南京", "武汉", "沈阳", "西安", "成都", "杭州", "济南", "青岛", "大连", "宁波", "苏州", "无锡", "哈尔滨", "长春", "厦门", "佛山", "东莞", "合肥", "郑州", "长沙", "福州", "石家庄", "乌鲁木齐", "昆明", "兰州", "南昌", "贵阳", "南宁", "太原", "呼和浩特", "常州", "唐山", "准二线", "烟台", "泉州", "包头", "徐州", "南通", "邯郸", "温州"].each do |city_name|
  City.create name: city_name, tier: "Tier 2"
end
puts 'cities created'
