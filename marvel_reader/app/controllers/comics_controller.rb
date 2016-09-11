class ComicsController < ApplicationController

  def index
    logger.debug("Calling service ...")

    @comic_reader = ComicReader.call(accepted_params)

    if @comic_reader.success?

      #get favorites
      @favorite_comics = Favorite.where('comic_id IN(?)', @comic_reader.result['data']['results'].map{|c| c['id'] }).pluck(:comic_id)

      # Todo Refactor
      # reader result info
      @offset = @comic_reader.result['data']['offset']
      @limit  = @comic_reader.result['data']['limit']
      @total  = @comic_reader.result['data']['total']
      @count  = @comic_reader.result['data']['count']
      @comics = @comic_reader.result['data']['results'].map { |c| Comic.new(c.merge({favorite: @favorite_comics.include?(c['id'].to_i) })) }


    else
      @comics = []
      flash[:error] = t('pages.comics.index.errors.not_found')
    end

  end

  private
  def accepted_params
    params.permit(:limit, :offset, :order_by, :character_id) #, {search: [:name]})
  end


  #TODO just testing, refactor
  def find_comics

    if params[:search].present? &&  params[:search][:name].present?

      _params = {
          resource: 'characters',
          search: params[:search]
      }

      _character_reader = ComicReader.call(_params)
      if _character_reader.success?

        _params = {
            resource: 'characters',
            resource_id: _character_reader.result['data']['results'].first['id'],
            sub_resource: 'comics'
        }

        @comic_reader = ComicReader.call(_params)

      end
    else

      @comic_reader = ComicReader.call(accepted_params)

    end

  end

end
