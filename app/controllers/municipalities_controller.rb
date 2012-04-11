class MunicipalitiesController < InheritedResources::Base
  before_filter :limit_connections, :init_map_vars

  def limit_connections
    @limit = 10
  end

  def init_map_vars
    # Let's get bounds for our map
    bounds = {}
    bounds[:north] = Municipality.maximum(:latitude)
    bounds[:south] = Municipality.minimum(:latitude)
    bounds[:east] = Municipality.maximum(:longitude)
    bounds[:west] = Municipality.minimum(:longitude)
    @bounds = bounds.to_json
  end

  def top_connections
    @title = "Top #{@limit} municipalities, by number of potential connections"

    # What is the highest count?
    @heatmap_max = Municipality.maximum(:num_connections)

    muns = []
    Municipality.find(:all, :order => "num_connections desc", :limit => @limit).each do |m|
      muns << {:lat => m.latitude, :lng => m.longitude, :count => m.num_connections}
    end
    @json = muns.to_json
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
