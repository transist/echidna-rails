class SpiderScheduler
  def initialize
    @scheduler = Rufus::Scheduler.start_new
  end

  def run
    schedule_refresh_access_token
    # schedule_sample_users
    schedule_track_users
    # schedule_sample_famous_users
    schedule_sample_hot_users
    schedule_gather_tweets
    schedule_reset_api_calls_count
  end

  def join
    @scheduler.join
  end

  private

  def schedule_gather_tweets
    TencentAgent.all.each do |agent|
      @scheduler.every '30s', first_in: '0s', mutex: :gather_tweets do
        agent.gather_tweets
      end
    end
  end

  def schedule_sample_famous_users
    @scheduler.every '4w', first_in: '0s', mutex: :sample_famous_users do
      TencentAgent.first.sample_famous_users
    end
  end

  def schedule_sample_hot_users
    @scheduler.every '10m', first_in: '0s', mutex: :sample_hot_users do
      TencentAgent.first.sample_hot_users
    end
  end

  def schedule_sample_users
    @scheduler.every '10m', first_in: '0s', mutex: :sample_users do
      TencentAgent.first.sample_users
    end
  end

  def schedule_track_users
    @scheduler.every '5m', first_in: '0s', mutex: :track_users do
      TencentAgent.with_available_lists.each do |agent|
        agent.track_users
      end
    end
  end

  def schedule_refresh_access_token
    @scheduler.every '1d', first_in: '0s', mutex:
      [:sample_users, :sample_famous_users, :sample_hot_users, :track_users, :gather_tweets] do
      TencentAgent.all.each do |agent|
        agent.refresh_access_token
      end
    end
  end

  def schedule_reset_api_calls_count
    @scheduler.cron '0 * * * *' do
      TencentAgent.reset_api_calls_count
    end
  end
end
