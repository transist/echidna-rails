desc 'Fix data for issue 99'
task fix_data_for_issue_99: :environment do
  Person.where(gender: 'both').update_all(gender: 'unknown')
  Group.where(gender: 'both').update_all(gender: 'unknown')
  Panel.where(gender: 'both').update_all(gender: 'unknown')
end
