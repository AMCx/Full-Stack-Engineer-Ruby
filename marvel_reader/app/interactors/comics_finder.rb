class ComicReader
  include Interactor


  def call
    _search = context.search || {}


    _params = {
        resource: 'comics',
        limit: context.limit,
        offset: context.offset,
        order_by: context.order_by,
        search: context.search
    }

  end

end