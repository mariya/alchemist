class MunicipalitiesController < InheritedResources::Base
  def index
    @json = Municipality.all.to_gmaps4rails
  end
end
