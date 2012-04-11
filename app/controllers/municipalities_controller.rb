class MunicipalitiesController < InheritedResources::Base
  before_filter :limit_connections

  def limit_connections
    @limit = 10
  end

  def top_connections
    @title = "Top #{@limit} municipalities, by number of potential connections"
    # Let's get bounds for our map
    bounds = {}
    bounds[:north] = Municipality.maximum(:latitude)
    bounds[:south] = Municipality.minimum(:latitude)
    bounds[:east] = Municipality.maximum(:longitude)
    bounds[:west] = Municipality.minimum(:longitude)
    @bounds = bounds.to_json

    muns = []
    Municipality.find(:all, :order => "num_connections desc", :limit => @limit).each do |m|
      muns << {:lat => m.latitude, :lng => m.longitude}
    end
    @json = muns.to_json
    #@json = Municipality.find(:all, :order => "num_connections desc", :limit => @limit).to_gmaps4rails
    render :layout => "heatmap"
  end

  def top_factor
    @title = "Top #{@limit} municipalities, by mean size of potential connections"
    @json = Municipality.find(:all, :order => "mean_connections_factor desc", :limit => @limit).to_gmaps4rails
  end

  def heatmap
    muns = Municipality.find(:all, :order => "mean_connections_factor desc", :limit => @limit)
  end
end
