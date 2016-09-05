class Comic

  ATTRS = [:id,
           :title,
           :issue_number,
           :dates,
           :thumbnail
  ]

  attr_accessor(*ATTRS)

  #autoassign object attributes from hash
  def initialize(params= {})
    params.each { |k, v| instance_variable_set("@#{k.underscore}", v) if ATTRS.include?(k.to_sym) }

    @onsale_year = '1980'

  end

  def thumbnail_img
    thumbnail.present? ? "#{thumbnail['path']}.#{thumbnail['extension']}" : ''
  end

  def onsale_date_year
    @onsale_date_year
  end


  private

  def set_dates
    @dates.each do |date|

      _date = Date._parse[date['date']]
      instance_variable_set("@#{date['type'].underscore}_year",_date[:year]) if _date.present?

    end
  end

end
