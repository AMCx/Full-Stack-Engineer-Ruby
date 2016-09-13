module Api::V1
  class CharactersController < Api::V1::BaseController

    def index
      logger.debug("Calling service ...")

      _character_finder = Services::CharacterFinder.call(params: params, accepted_params: accepted_params)

      if _character_finder.fail?
        flash[:error] = _character_finder.message
      end

      if _character_finder.success?

        # a very, very simple serialization
        _response_json = _character_finder.characters.map do |character|
          {
              id: character.id,
              name: character.name,
              icon: character.thumbnail_img
          }
        end

        build_response({characters: _response_json})
      else
        build_response({error: _character_finder.message}, false, -1, t('errors.record_not_found'), 404)
      end

    end

    private
    def accepted_params
      params.permit(:limit, :offset, :order_by)
    end

  end
end