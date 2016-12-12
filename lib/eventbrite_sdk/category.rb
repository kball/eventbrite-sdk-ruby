module EventbriteSDK
  class Category < Resource
    extend Operations::List

    resource_path 'categories/:id'

    schema_definition do
      string 'name', read_only: true
      string 'name_localized', read_only: true
      string 'short_name', read_only: true
      string 'subcategories', read_only: true
    end
  end
end
