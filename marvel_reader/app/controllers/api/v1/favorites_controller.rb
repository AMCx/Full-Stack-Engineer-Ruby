module Api::V1
  class FavoritesController < Api::V1::BaseController

    def create

      @favorite = Favorite.new(accepted_params)

      if @favorite.save

        build_response( {favorite: @favorite, message: I18n.t('api.favorites.create.success')} )
      else

        build_response({errors: @favorite.errors}, false, Api::RETURN_CODE_MODEL_SAVE, @favorite.errors.full_messages.join(', '), 500)

      end

    end

    def destroy

      @favorite = Favorite.find_by(comic_id: params[:id])

      if @favorite.blank?

        build_response({errors: [], message: I18n.t('api.favorites.delete.failure') }, false, Api::RETURN_CODE_RECORD_NOT_FOUND, I18n.t('errors.record_not_found'), 500)

      elsif @favorite.destroy

        build_response({favorite: @favorite, message: I18n.t('api.favorites.delete.success')})
      else

        build_response({errors: @favorite.errors, message: @favorite.errors.full_messages.join(', ')}, false, Api::RETURN_CODE_MODEL_SAVE, @favorite.errors.full_messages.join(', '), 500)

      end
    end

    private
    def accepted_params
      params.require(:favorite).permit(:comic_id)
    end

  end
end