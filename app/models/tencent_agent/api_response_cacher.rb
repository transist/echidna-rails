class TencentAgent
  module ApiResponseCacher
    extend ActiveSupport::Concern

    def cached_get(path, params = {}, &block)
      cache_key = "GET #{path} #{params}"
      cache_path = cache_path(cache_key)

      if cache_exists?(cache_path)

        if cache_expired?(cache_path)
          info("Cache expired: #{cache_key}")
          store_cache(cache_path, get(path, params, &block))
        else
          info("Cache hit: #{cache_key}")
          load_cache(cache_path)
        end

      else
        info("Cache miss: #{cache_key}")
        store_cache(cache_path, get(path, params, &block))
      end
    end

    private

    def cache_path(cache_key)
      sha1_hash = Digest::SHA1.hexdigest(cache_key)
      Rails.root.join('cache', 'tencent_api', sha1_hash[0..3], sha1_hash)
    end

    def cache_exists?(cache_path)
      cache_path.file?
    end

    def cache_expired?(cache_path)
      cache_path.mtime < 1.day.ago
    end

    def load_cache(cache_path)
      MultiJson.load(cache_path.read)
    end

    def store_cache(cache_path, cache_data)
      cache_path.dirname.tap do |dir|
        dir.mkpath unless dir.directory?
      end

      File.open(cache_path, 'w') do |file|
        file.puts(MultiJson.dump(cache_data, pretty: true))
      end

      cache_data
    end
  end
end
