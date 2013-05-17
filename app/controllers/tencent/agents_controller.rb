class Tencent::AgentsController < ApplicationController

  def new
    redirect_to TencentAgent.weibo_client.auth_code.authorize_url
  end

  def callback
    begin
      TencentAgent.create(TencentAgent.weibo_client.auth_code.get_token(params[:code]).to_hash.symbolize_keys)
      render json: {success: true}
    rescue => e
      render json: {success: false, error: e.message}
    end
  end

end
