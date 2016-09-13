class Character

  ATTRS = [:id,
           :name,
           :description,
           :thumbnail
  ]

  attr_accessor(*ATTRS)

  #autoassign object attributes from hash
  def initialize(params= {})
    params.each { |k, v| instance_variable_set("@#{k.underscore}", v) if ATTRS.include?(k.to_sym) }

  end

  def thumbnail_img
    thumbnail.present? ? "#{thumbnail['path']}.#{thumbnail['extension']}" : ''
  end

end
