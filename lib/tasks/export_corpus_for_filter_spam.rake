desc 'Export corpus for filter spam'
task export_corpus_for_filter_spam: :environment do

  names = %w(yuLu365 vip520 xingzuoxuexing xingzuo360 gaoxiaophoto V5-Amm qinggans harry_lzx Quanqiuyinyue vipmood Q98704 vip520 xiaosile123 tanglang vip5200 vipmood Jaychina Mddongyuan Ndxxoo aliishuo Weisuomm zaoangod)
  export_to = File.join(Rails.root, 'data', 'spam_corpus')
  fetch_corpus(names, export_to)

  names = %w(NBA han_qiaosheng liujianhong bashusong maoyushi yu_hua lianyue lvqiuluwei luoyonghao dogsun1970 mozhixuhu duqin8964 jsliming nandushendu reuters hu-shuli)
  export_to = File.join(Rails.root, 'data', 'normal_corpus')
  fetch_corpus(names, export_to)
end

def fetch_corpus(names, export_to)

  t = TencentAgent.last

  File.open(export_to, 'w') do |file|
    
    result = t.get('api/statuses/users_timeline', pageflag: 1, reqnum: 70, type: 3, names: names.join(','))

    100.times do

      if result['data']
        result['data']['info'].each do |status|
          text = status['text']
          text = text + status['source']['text'] if status['source']
          file.puts text
        end

        last_timestamp = result['data']['info'].last['timestamp']
      else
        puts "Fail to fetch from timestamp #{last_timestamp} #{result[:msg]}"
        puts "Retrying..."
      end

      puts "Fetching from timestamp #{last_timestamp}...."

      result = t.get('api/statuses/users_timeline', pageflag: 1, pagetime: last_timestamp, reqnum: 70, type: 3, names: names.join(','))

      file.flush
    end
  end

end