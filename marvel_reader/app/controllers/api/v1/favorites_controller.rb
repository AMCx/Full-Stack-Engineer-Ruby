module Api::V1
  class FavoritesController < Api::V1::BaseController

    def create
      @favorite = Favorite.new(accepted_params)

      if @favorite.save

        build_response({favorite: @favorite})
      else

        build_response({errors: @favorite.errors}, false, Api::RETURN_CODE_MODEL_SAVE, @favorite.errors.full_messages.join(', '), 500) and return

      end

    end

    def destroy
      @favorite = Favorite.find_by(comic_id: params[:comic_id])

      if @favorite.destroy

        build_response({favorite: @favorite})
      else

        build_response({errors: @favorite.errors}, false, Api::RETURN_CODE_MODEL_SAVE, @favorite.errors.full_messages.join(', '), 500) and return

      end
    end

    private
    def accepted_params
      params.require(:favorite).permit(:comic_id)
    end

  end
end