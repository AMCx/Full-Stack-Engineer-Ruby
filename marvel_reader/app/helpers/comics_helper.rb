module ComicsHelper

  def get_previous_page_params page=params[:page]

    _r = { page: (page - 1) }
    _r[:character_id] = params[:character_id] if params[:character_id].present?

    _r
  end

  def get_next_page_params page=params[:page]

    _r = { page: (page+1) }
    _r[:character_id] = params[:character_id] if params[:character_id].present?

    _r
  end

end
