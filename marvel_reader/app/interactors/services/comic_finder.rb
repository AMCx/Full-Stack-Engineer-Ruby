class Services::ComicFinder
  include Interactor

  def call
    _params = context.accepted_params

    _character_id = context.params[:character_id]

    _default_limit = 10

    #Search comics by character
    if _character_id.present?
      _params[:resource]

      _params[:resource] = 'characters'
      _params[:resource_id] = _character_id
      _params[:sub_resource] = 'comics'
    end

    _params[:limit] = _default_limit
    _params[:offset] = calc_offset (_params[:page] || 1).to_i, _default_limit
    _params[:order_by] = '-focDate'

    @marvel_remote = Remotes::Marvel.call(_params)

    context.last_page = true
    context.page = 1

    if @marvel_remote.success?

      #get favorites
      @favorite_comics = Favorite.where('comic_id IN(?)', @marvel_remote.result['data']['results'].map { |c| c['id'] }).pluck(:comic_id)

      @offset = @marvel_remote.result['data']['offset'].to_i
      @limit = @marvel_remote.result['data']['limit'].to_i
      @total = @marvel_remote.result['data']['total'].to_i
      @count = @marvel_remote.result['data']['count'].to_i

      context.page = calc_page(@offset, @limit)
      context.comics = @marvel_remote.result['data']['results'].map { |c| Comic.new(c.merge({favorite: @favorite_comics.include?(c['id'].to_i)})) }
      context.last_page = !((@offset+@limit) < @total)

    else
      context.comics = []

      context.fail!(message: I18n.t('errors.record_not_found'))
    end
  end

  def calc_page offset, limit
    _page = 1
    if offset > 0
      _page = (offset/limit) + 1
    end

    _page
  end

  def calc_offset page, limit
    _offset = 0
    if page > 1
      _offset = (page - 1)*limit
    end

    _offset
  end

end
