class TencentAgent
  module FamousUsersSampling
    extend ActiveSupport::Concern

    FAMOUS_CLASSES = [
      {classid: 101, name: '娱乐明星'},
      {classid: 102, name: '体育明星'},
      {classid: 103, name: '生活时尚'},
      {classid: 104, name: '财经'},
      {classid: 105, name: '科技网络'},
      {classid: 106, name: '文化出版'},
      {classid: 108, name: '汽车'},
      {classid: 109, name: '动漫'},
      {classid: 110, name: '游戏'},
      {classid: 111, name: '星座命理'},
      {classid: 112, name: '教育'},
      {classid: 114, name: '企业品牌'},
      {classid: 115, name: '酷站汇'},
      {classid: 116, name: '腾讯产品'},
      {classid: 228, name: '有趣用户'},
      {classid: 267, name: '营销广告'},
      {classid: 268, name: '媒体机构'},
      {classid: 268, subclassid: 'subclass_959', name: '广播'},
      {classid: 268, subclassid: 'subclass_960', name: '电视'},
      {classid: 268, subclassid: 'subclass_961', name: '报纸'},
      {classid: 268, subclassid: 'subclass_962', name: '杂志'},
      {classid: 268, subclassid: 'subclass_963', name: '网络媒体'},
      {classid: 268, subclassid: 'subclass_964', name: '通讯社'},
      {classid: 294, name: '传媒人士'},
      {classid: 294, subclassid: 'subclass_953', name: '传媒领袖'},
      {classid: 294, subclassid: 'subclass_955', name: '名编名记'},
      {classid: 294, subclassid: 'subclass_956', name: '主持人'},
      {classid: 294, subclassid: 'subclass_957', name: '传媒学者'},
      {classid: 294, subclassid: 'subclass_958', name: '专栏评论'},
      {classid: 304, name: '政府机构'},
      {classid: 363, name: '公益慈善'},
      {classid: 945, name: '公务人员'},
      {classid: 949, name: '快乐女声'},
      {classid: 950, name: '公共名人'},
      {classid: 951, name: '花儿朵朵'}
    ]

    SAMPLE_WAIT = 0.2

    def sample_famous_users
      info 'Sampling Famous Users...'

      FAMOUS_CLASSES.each do |famous_class|
        info %{Sampling famous users from famous class "#{famous_class[:name]}"...}
        result = cached_get('api/trends/famouslist', classid: famous_class[:classid], subclassid: famous_class[:subclassid])
        if result['ret'].to_i.zero?

          unless result['data']
            info "No results for famous class #{famous_class}"
            next
          end

          result['data']['info'].each do |user|
            sample_famous_user(user['account'])
          end

        else
          error "Failed to sample users from famous class: #{famous_class}"
        end

        sleep SAMPLE_WAIT
      end

      info 'Finished famous users gathering'

    rescue TencentError => e
      error "Aborted famous users gathering: #{e.message}"
    rescue => e
      log_unexpected_error(e)
    end

    private

    def sample_famous_user(user_name)
      result = cached_get('api/user/other_info', name: user_name)

      if result['ret'].to_i.zero? && result['data']
        user = UserDecorator.decorate(result['data'])
        publish_user(user, famous: true, seed_level: 0)
      else
        error %{Failed to gather profile of famous user "#{user_name}"}
      end
    end
  end
end
