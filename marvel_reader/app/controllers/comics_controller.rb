class ComicsController < ApplicationController

  def index
    logger.debug("Calling service ...")

    _comic_finder = Services::ComicFinder.call(params: params, accepted_params: accepted_params)

    if _comic_finder.fail?
      flash[:error] = _comic_finder.message
    end

    @page      = _comic_finder.page
    @comics    = _comic_finder.comics
    @last_page = _comic_finder.last_page

    respond_to do |format|
      format.html { }
      format.js {}
    end

  end

private

  def accepted_params
    params.permit(:page, :order_by, :character_id)
  end

end
