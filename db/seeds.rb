# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html

if Rails.env.production?
  puts 'ARE YOU SURE you want seed the PRODUCTION database? This will DELETE ALL EXISTING USERS, CITIES, and GROUPS.'
  print '(yes/no) '
  anwser = STDIN.gets
  unless 'yes' == anwser.strip.downcase
    exit
  end
end

City.delete_all
User.delete_all
Group.delete_all

puts 'DEFAULT USERS'
user = User.create! name: ENV['ADMIN_NAME'].dup, email: ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name

["北京", "上海", "广州", "深圳", "天津", "重庆"].each do |city_name|
  City.create! name: city_name, tier: "Tier 1"
end
["南京", "武汉", "沈阳", "西安", "成都", "杭州", "济南", "青岛", "大连", "宁波", "苏州", "无锡", "哈尔滨", "长春", "厦门", "佛山", "东莞", "合肥", "郑州", "长沙", "福州", "石家庄", "乌鲁木齐", "昆明", "兰州", "南昌", "贵阳", "南宁", "太原", "呼和浩特", "常州", "唐山", "准二线", "烟台", "泉州", "包头", "徐州", "南通", "邯郸", "温州"].each do |city_name|
  City.create! name: city_name, tier: "Tier 2"
end
puts 'Cities created'


birth_years_data = [
  {start_birth_year: 1947, end_birth_year: 1953},
  {start_birth_year: 1954, end_birth_year: 1960},
  {start_birth_year: 1961, end_birth_year: 1967},
  {start_birth_year: 1968, end_birth_year: 1974},
  {start_birth_year: 1975, end_birth_year: 1981},
  {start_birth_year: 1982, end_birth_year: 1988},
  {start_birth_year: 1989, end_birth_year: 1995},
  {start_birth_year: 1996, end_birth_year: 2002},
  {start_birth_year: 2003, end_birth_year: 2009},
  {start_birth_year: 2010, end_birth_year: 2013}
]

Person::GENDERS.each do |gender|
  City.all.each do |city|
    birth_years_data.each do |birth_year_data|
      Group.create!(
        gender: gender, city: city,
        start_birth_year: birth_year_data[:start_birth_year],
        end_birth_year: birth_year_data[:end_birth_year]
      )
    end
  end
end

puts 'Groups created'
