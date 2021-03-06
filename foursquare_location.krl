ruleset foursquare_location {
  meta {
    name "foursquare_location"
    description <<
      Is activiated when a new checkin with latitude and longitude is called
    >>
    author "Mercedes Kurtz"
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
    use module b505217x6 alias location_data
  }
  dispatch {
  }
  global {
  }
  rule HelloWorld is active {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id="repl">Seeing if this is being called!</div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare Location!", {}, my_html);
    }
  }

  rule nearby {
    select when location new_current
    pre {
      la = event:attr('lat');
      lo = event:attr('long');
      deets = location_data:get_location_data('fs_checkin');
      valueType = deets.typeof();
      lab = deets.pick("$.lat");
      lob = deets.pick("$.lng");


      r90   = math:pi()/2;      
      rEk   = 6378;         // radius of the Earth in km       
      // point a
      lata  = la; //change this to la
      lnga  = lo; //change this to lo       
      // point b
      latb  = lab; // change this to current location latitude
      lngb  = lob; //change this to current location longitude       
      // convert co-ordinates to radians
      rlata = math:deg2rad(lata);
      rlnga = math:deg2rad(lnga);
      rlatb = math:deg2rad(latb);
      rlngb = math:deg2rad(lngb);       
      // distance between two co-ordinates in radians
      dR = math:great_circle_distance(rlnga,r90 - rlata, rlngb,r90 - rlatb);       
      // distance between two co-ordinates in kilometers
      dE = math:great_circle_distance(rlnga,r90 - rlata, rlngb,r90 - rlatb, rEk);
      //8 kilometers is about 5 miles (a little less)
      threshold = 8
    }
    if (threshold > dE) then noop();
    fired {
      set ent:inhere dE;
      set ent:laaa lata;
      set ent:laab latb;
      set ent:looa lnga;
      set ent:loob lngb;
      raise explicit event 'location_nearby' with distance = dE
    } else {
      set ent:inhere dE;
      set ent:laaa lata;
      set ent:laab latb;
      set ent:looa lnga;
      set ent:loob lngb;
      raise explicit event 'location_far' with distance = dE
    }
  }

  rule display_working {
    select when cloudAppSelected
    pre {
      input_html  = <<
       holla! #{ent:inhere}
       lata #{ent:laaa}
       latb #{ent:laab}
       lnga #{ent:looa}
       lngb #{ent:loob}
      >>;
    }    
    replace_inner("#repl", input_html);
  }
}