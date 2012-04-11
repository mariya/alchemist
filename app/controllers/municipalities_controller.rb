class MunicipalitiesController < InheritedResources::Base
  before_filter :init_map_vars

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
    @title = "Top municipalities, by number of potential connections"

    # What is the highest count? TODO: Consider using maximum instead of average
    @heatmap_max = Municipality.average(:num_connections)

    muns = []
    Municipality.find(:all, :order => "num_connections desc").each do |m|
      muns << {:lat => m.latitude, :lng => m.longitude, :count => m.num_connections}
    end
    @json = muns.to_json
    render :layout => "heatmap"
  end

  def top_factor
    @title = "Top municipalities, by mean size of potential connections"

    # What is the highest factor? TODO: Consider using maximum instead of average
    @heatmap_max = Municipality.average(:mean_connections_factor)

    muns = []
    Municipality.find(:all, :order => "mean_connections_factor desc").each do |m|
      muns << {:lat => m.latitude, :lng => m.longitude, :count => m.mean_connections_factor}
    end
    @json = muns.to_json
    render :layout => "heatmap"
  end

  def heatmap
    muns = Municipality.find(:all, :order => "mean_connections_factor desc", :limit => @limit)
  end
end
