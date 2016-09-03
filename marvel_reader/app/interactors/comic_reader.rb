class ComicReader
  include Interactor
  require 'digest'
  require 'rest-client'

  def call
    # TODO refactor
    #example call url
    #http://gateway.marvel.com/v1/comics?ts=1&apikey=31bf848511af9ccb8d3b3d6423075af4&hash=95bf33261c85d320a38b0146df636d87

    init_params
    @resource = context.resource || 'comics'
    @resource_id = context.resource_id || false
    @timeout = context.timeout || 10

    @allow_cache = context.allow_cache || true

    @resource_filter = @resource
    @resource_filter = "#{@resource}/#{@resource_id}" if @resource_id

    @api_params = {
        ts: @ts,
        apikey: @public_key,
        hash: @hash
    }

    @params = {
        limit: (context.limit || 10),
        offset: (context.offset || 0)

    }

    #set cache_key
    @key = "@resource::#{@params.map{|k,v| "#{k}:{v}".downcase }.sort_by!{ |e| e }.join('::')}"

    # check cache
    @cached_data = Rails.cache.read(@key) unless !@allow_cache

    if !@allow_cache || @cached_data.blank?
      @launch_request = true
    else

      @data = @cached_data[:info]
      @age = (Time.now - @cached_data[:timestamp]) # age in seconds

      # 86400 24h minutes
      # 600  10 minutes
      if @age > 600 # 10 minutes
        @launch_request = true
      end
    end

    if @launch_request
      # Cache info if request had success
      begin
        _params = @api_params.merge( @params )
        _ret = RestClient.get "#{@api_base_url}#{@resource}", { params: (_params), accept: :json, timeout: @timeout, open_timeout: @timeout }

        @data = JSON.parse(_ret)

        if @data['code'].to_i == 200
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

    context.result = @data

  end

  def init_params

    @api_base_url = "http://gateway.marvel.com/v1/public/"
    @ts = Time.now.to_i

    @launch_request = false
    get_auth_data

    md5 = Digest::MD5.new

    md5.update "#{@ts}#{@private_key}#{@public_key}"

    @hash = md5.hexdigest

  end

  def get_auth_data


    @private_key='d387cc78658d4fc2aa5f1326277b63797a7e7b5f'
    @public_key='31bf848511af9ccb8d3b3d6423075af4'

  end

end
