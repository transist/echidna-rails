class AgentsController < ApplicationController

  def new
    render json: {authorize_url: weibo.auth_code.authorize_url}
  end

  def create
    begin
      TencentAgent.create(weibo.auth_code.get_token(params[:code]).to_hash.symbolize_keys)
      render json: {success: true}
    rescue => e
      render json: {success: false, error: e.message}
    end
  end

  protected
  def weibo
    @weibo ||= begin
      config = YAML::load(File.open(Rails.root.join("config/spider.yml")))
      
      Tencent::Weibo::Client.new(
        config['tencent']['key'], config['tencent']['secret'], config['tencent']['redirect_uri']
      )
    end
  end
end
