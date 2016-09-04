class Comic

  attr_accessor :id, :digital_id, :title, :issue_number, :variant_description, :description,
                :modified, :isbn, :upc, :diamond_code, :ean, :issn, :format,
                :page_count, :thumbnail_path,
                :thumbnail_extension,
                :characters

  #autoassign object attributes from hash
  def initialize(params)

      params.each { |k,v| instance_variable_set("@#{k.underscore}",v) }

  end

end
