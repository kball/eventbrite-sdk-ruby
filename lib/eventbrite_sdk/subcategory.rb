module EventbriteSDK
  class Subcategory < Resource
    extend Operations::List

    resource_path 'subcategories/:id'

    schema_definition do
      string 'name', read_only: true
      string 'parent_category', read_only: true
    end
  end
end
