class Services::CharacterFinder
  include Interactor

  def call

    _params = {
        resource: 'characters',
        search: {name: context.params[:term]}
    }

    _comic_reader = Remotes::Marvel.call(_params)

    _page_params = context.accepted_params

    @characters = []

    if _comic_reader.success?
      @characters = _comic_reader.result['data']['results'].map do |data|
        Character.new(data)
      end
      context.characters = @characters
    else
      context.characters = []
      context.fail(message: t('errors.record_not_found'))
    end

  end
end
