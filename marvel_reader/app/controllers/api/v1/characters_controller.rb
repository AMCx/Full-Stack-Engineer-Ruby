module Api::V1
  class CharactersController < Api::V1::BaseController

    def index
      logger.debug("Calling service ...")

      _params = {
          resource: 'characters',
          search: {name: params[:term]}
      }

      _comic_reader = ComicReader.call(_params)

      _page_params = accepted_params

      if _comic_reader.success?
        @characters = _comic_reader.result['data']['results'].map do |data|
          Character.new(data)
        end

        # a very, very simple serialization
        _response_json = @characters.map do |character|
          {
              id: character.id,
              name: character.name,
              icon: character.thumbnail_img
          }
        end

        build_response({characters: _response_json})
      else
        build_response({error: _comic_reader.message}, false, -1, t('errors.record_not_found'), 404)
      end

    end

    private
    def accepted_params
      params.permit(:limit, :offset, :order_by)
    end

  end
end