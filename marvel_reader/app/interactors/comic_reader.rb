class ComicReader
  include Interactor
  require 'digest'
  require 'rest-client'

  def call
    # TODO refactor
    init_service_params

    #init query params
    @resource = context.resource || 'comics'
    @resource_id = context.resource_id || false
    @sub_resource = context.sub_resource || false

    @timeout = context.timeout || 10
    _search = (context.search || {}).with_indifferent_access

    @search_filters = {}.with_indifferent_access

    @search_filters[:'nameStartsWith'] = _search[:name] if _search[:name].present?

    @allow_cache = context.allow_cache || false

    build_resource_filter

    @params = ({
        limit: (context.limit || 10),
        offset: (context.offset || 0)

    }.merge(@search_filters)).with_indifferent_access

    @params[:orderBy] = context.order_by if context.order_by.present?

    Rails.logger.debug("Calling remote service with: #{@resource_filter} #{@params}")

    #set cache_key
    @key = "@resource::#{@resource_filter}#{@params.map{|k,v| "#{k}:#{v}".downcase }.sort_by!{ |e| e }.join('::')}"

    Rails.logger.debug("cache_key: #{@key}")

    # check cache
    _cached_data = Rails.cache.read(@key) unless !@allow_cache

    if !@allow_cache || @cached_data.blank?
      @launch_request = true
    else

      @data = _cached_data[:info]
      @age = (Time.now - _cached_data[:timestamp]) # age in seconds

      # 86400 24h minutes
      # 600  10 minutes
      if @age > 86400
        @launch_request = true
      end
    end

    if @launch_request
      Rails.logger.debug("No local cache, calling remote")
      launch_api_request
    else
      Rails.logger.debug("Local cache hit!, cache age is #{@age}")
    end

    context.result = @data

  end

  def build_resource_filter

    @resource_filter = @resource
    @resource_filter = "#{@resource}/#{@resource_id}" if @resource_id
    @resource_filter = "#{@resource}/#{@resource_id}/#{@sub_resource}" if @resource_id && @sub_resource

  end

  private

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

    @launch_request = false
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
