ruleset location_data {
  meta {
    name "Location Data"
    description <<
      Stores keys and values for the locations of foursquare checkins
    >>
    author "Mercedes Kurtz"
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag

    provides get_location_data
  }
  dispatch {
  }
  global {
    get_location_data = function(k) {
      the_map = ent:my_map;
      key = "$." + k.as('str');
      val = the_map.pick(key);
      val
    }
  }
  rule HelloWorld is active {
    select when web cloudAppSelected
    pre {
      k = ent:curr_key;
      v = ent:curr_val;
      m = ent:my_map.encode();
      my_html = <<
        <h5>For Checkin</h5>
        <div id="check"> key: #{k} value: #{v}  map: #{m}</div> 
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Hello World!", {}, my_html);
    }
  }

  rule add_location_item {
    select when pds new_location_data
    pre {
      the_map = ent:my_map;
      k = event:attr("key");
      v = event:attr("value");
      ret_map = the_map.put([k],v);
    }
    send_directive(k) with key = "location" and value = v;
    always {
      set ent:my_map ret_map;
      set ent:curr_key k;
      set ent:curr_val v;
      set ent:in_here "in here!!"
    }
  }
}