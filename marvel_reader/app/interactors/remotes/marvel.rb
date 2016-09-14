module Remotes
  class Marvel
    include Interactor
    require 'digest'
    require 'rest-client'

    attr_accessor :max_cache_age, :allow_cache

    def call
      init_service_params

      #init query params

      @timeout = context.timeout || 10
      _search = (context.search || {}).with_indifferent_access

      @search_filters = {}.with_indifferent_access

      @search_filters[:'nameStartsWith'] = _search[:name] if _search[:name].present?

      allow_cache = context.allow_cache || false

      # 86400 24h minutes
      # 600  10 minutes
      max_cache_age = context.max_cache_age || 86400

      build_resource_filter

      @params = ({
          limit: (context.limit || 10),
          offset: (context.offset || 0)

      }.merge(@search_filters)).with_indifferent_access

      @params[:orderBy] = context.order_by if context.order_by.present?

      Rails.logger.debug("Calling remote service with: #{@resource_filter} #{@params}")

      build_cache_key

      @launch_request = true

      if allow_cache
        # check cache
        _cached_data = Rails.cache.read(@key) unless !allow_cache
        if _cached_data.present? 
          @age = (Time.now - _cached_data[:timestamp]) # age in seconds
          Rails.logger.debug("Local cache hit!, cache age is #{@age}")

          if @age <= max_cache_age
            @launch_request = false
            @data = _cached_data[:info]
          end
        end

      end


      if @launch_request
        Rails.logger.debug("No local cache, calling remote")
        launch_api_request
      end

      context.result = @data

    end

    private


    def build_cache_key

      #set cache_key
      @key = "@resource::#{@resource_filter}#{@params.map { |k, v| "#{k}:#{v}".downcase }.sort_by! { |e| e }.join('::')}"

      Rails.logger.debug("cache_key: #{@key}")

    end

    def build_resource_filter

      _resource = context.resource || 'comics'
      _resource_id = context.resource_id || false
      _sub_resource = context.sub_resource || false


      if _resource_id && _sub_resource
        @resource_filter = "#{_resource}/#{_resource_id}/#{_sub_resource}" 
      elsif _resource_id
        @resource_filter = "#{_resource}/#{_resource_id}"
      else
        @resource_filter = _resource
      end

    end

    def launch_api_request

      begin
        _params = @api_params.merge(@params)
        Rails.logger.debug("Calling #{@api_base_url}#{@resource_filter}, with #{@params}")

        _ret = RestClient.get "#{@api_base_url}#{@resource_filter}", {params: (_params), accept: :json, timeout: @timeout, open_timeout: @timeout}

        @data = JSON.parse(_ret)

        if @data['code'].to_i == 200
          # Cache info if request had success
          Rails.cache.write(@key, {info: @data, timestamp: Time.now})
        else
          context.errors = @data
          context.fail!(message: "Error code #{@data['code']}")
        end

      rescue Exception => ex

        @data = {
            code: 500,
            error: 'Timeout'
        }
        context.errors = @data
        context.fail!(message: "'Timeout' #{ex.message}")

      end
    end

    def init_service_params

      @api_base_url = "http://gateway.marvel.com/v1/public/"
      @ts = Time.now.to_i

      get_auth_data

      md5 = Digest::MD5.new

      md5.update "#{@ts}#{@private_key}#{@public_key}"

      @hash = md5.hexdigest

      @api_params = {
          ts: @ts,
          apikey: @public_key,
          hash: @hash
      }

    end

    def get_auth_data

      @private_key = ENV['MARVEL_PRIVATE_KEY']
      @public_key = ENV['MARVEL_PUBLIC_KEY']

    end

  end
end
