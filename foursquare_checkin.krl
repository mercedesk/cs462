ruleset FourSquare_checkin {
  meta {
    name "FourSquare Checkins"
    description <<
      This ruleset waits for a push from Foursquare. When it receives it,
      the user's checkin information is displayed
    >>
    author "Mercedes Kurtz"
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
    accessToken = "KF5GBIACBGZQDRDPCHIUPF3K4XBB0PGET02KYQKMX5EGIU0L";
  }
  rule Foursquare is active {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <h5>Last Checkin:</h5>
        <div id="repl"> lalalala get rid of</div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Foursquare Checkins for Mercedes", {}, my_html);
    }
  }

  rule process_fs_checkin {
    select when foursquare checkin
    pre {
      json_file = event:attr("checkin");
      content = json_file.decode();
      ven = content.pick("$.venue");
      nm = ven.pick("$.name").as('str');
      cty = ven.pick("$.location.city").as('str');
      sh = content.pick("$.shout").as('str');
      created = content.pick("$.createdAt");
    }
    noop()
    always {
      set ent:json_fl json_file;
      set ent:name nm;
      set ent:city cty;
      set ent:shout sh;
      set ent:createdAt created
    }
  }

  rule display_checkin {
    select when cloudAppSelected
    pre {
      out_time = time:now();

      //out_time = time:strftime(ent:createdAt, "%c");
      input_html = << <div id="result">Venue Checkin:</div>
                  <table style="border-spaceing:3px;width=22em;font-size:90%;;">
                    <tbody>
                      <tr>
                        <th scope="row" style="text-align:left;white-space: nowrap;;">Name</th>
                        <td>#{ent:name}</td>
                      </tr>
                      <tr>
                        <th scope="row" style="text-align:left;white-space: nowrap;;">City</th>
                        <td>#{ent:city}</td>
                      </tr>
                      <tr>
                        <th scope="row" style="text-align:left;white-space: nowrap;;">Created At</th>
                        <td>#{out_time}</td>
                      </tr>
                      <tr>
                        <th scope="row" style="text-align:left;white-space: nowrap;;">Shout</th>
                        <td>#{ent:shout}</td>
                      </tr>
                    </tbody>
                  </table> >>;
    }
    replace_inner("#repl", input_html);
  }

}

//https://cs.kobj.net/sky/event/8D87DEF2-A30E-11E3-8588-DF7CD61CF0AC/33/foursquare/checkin?_rids=b505217x4

// Lab details from Ryan - 
// you'll have to manually allow your progam to have access to your person
// notify doesn't work for this, set entity variables
// you'll have to refresh the page after every checkin to see the updated variables
// domain - foursquare
// type - checkin