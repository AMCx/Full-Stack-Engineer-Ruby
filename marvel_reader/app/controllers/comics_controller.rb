class ComicsController < ApplicationController

  def index
    logger.debug("Calling service ...")

    _params = accepted_params
    #Search comics by character
    if params[:character_id].present?
      _params[:resource]

      _params[:resource] = 'characters'
      _params[:resource_id] = params[:character_id]
      _params[:sub_resource] = 'comics'
    end

    _params[:limit] = 10
    _params[:offset] = calc_offset (_params[:page] || 1).to_i, 10
    _params[:order_by] = '-focDate'

    @comic_reader = ComicReader.call(_params)

    @last_page = true
    @page = 1

    if @comic_reader.success?

      #get favorites
      @favorite_comics = Favorite.where('comic_id IN(?)', @comic_reader.result['data']['results'].map{|c| c['id'] }).pluck(:comic_id)

      # Todo Refactor
      # reader result info
      @offset = @comic_reader.result['data']['offset'].to_i
      @limit  = @comic_reader.result['data']['limit'].to_i
      @total  = @comic_reader.result['data']['total'].to_i
      @count  = @comic_reader.result['data']['count'].to_i

      @page = calc_page(@offset, @limit)

      @comics = @comic_reader.result['data']['results'].map { |c| Comic.new(c.merge({favorite: @favorite_comics.include?(c['id'].to_i) })) }

      @last_page = !((@offset+@limit) < @total)

    else
      @comics = []
      flash[:error] = t('pages.comics.index.errors.not_found')
    end

    respond_to do |format|
      format.html { }
      format.js {}
    end

  end

private

  def accepted_params
    params.permit(:page, :order_by, :character_id) #, {search: [:name]})
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
