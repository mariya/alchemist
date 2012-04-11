var map;
var heatmap; 

window.onload = function(){

  var myLatlng = new google.maps.LatLng(48.3333, 16.35);
  // sorry - this demo is a beta
  // there is lots of work todo
  // but I don't have enough time for eg redrawing on dragrelease right now
  var myOptions = {
    zoom: 2,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: false,
    scrollwheel: true,
    draggable: true,
    navigationControl: true,
    mapTypeControl: false,
    scaleControl: true,
    disableDoubleClickZoom: false
  };
  map = new google.maps.Map(document.getElementById("heatmapArea"), myOptions);
  map.fitBounds(bounds);
  
  heatmap = new HeatmapOverlay(map, {"radius":15, "visible":true, "opacity":60});
  
  document.getElementById("gen").onclick = function(){
    var x = 5;
    while(x--){
    
      var lat = Math.random()*180;
      var lng = Math.random()*180;
      var count = Math.floor(Math.random()*180+1);
      
      heatmap.addDataPoint(lat,lng,count);
    
    }
  
  };
  
  document.getElementById("tog").onclick = function(){
    heatmap.toggle();
  };
  
  // this is important, because if you set the data set too early, the latlng/pixel projection doesn't work
  google.maps.event.addListenerOnce(map, "idle", function(){
    heatmap.setDataSet(coordinates);
  });
};
