class ComicsController < ApplicationController

  def index

    _comic_reader = ComicReader.call(accepted_params)

    if _comic_reader.success?

      # Todo Refactor
      # reader result info
      @offset = _comic_reader.result['data']['offset']
      @limit = _comic_reader.result['data']['limit']
      @total = _comic_reader.result['data']['total']
      @count = _comic_reader.result['data']['count']

      @comics = _comic_reader.result['data']['results'].map { |c| Comic.new(c) }
    else
      @comics = []
      flash[:error] = t('pages.comics.index.errors.not_found')
    end

  end

  private
  def accepted_params
    params.permit(:limit, :offset, :order_by, :character)
  end

end
