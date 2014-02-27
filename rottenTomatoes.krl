ruleset rotten_tomatoes {
  meta {
    name "Rotten Tomatoes Exercise"
    description <<
      Using the Rotten Tomatoes API, query for movies on their database
      printing out their thumbnail, title, release year, synopsis, critic rating
      and 'other data you find interesting'. :)
    >>
    author "Mercedes Kurtz"
    key rotTomKey "mepkty2uuzzqzzqc5ny5rj2x"
    logging off
    use module a169x701 alias CloudRain
    use module a41x186  alias SquareTag
  }
  dispatch {
  }
  global {
    get_movie_info = function(name) {
      r = http:get("http://api.rottentomatoes.com/api/public/v1.0/movies.json",
        {"apikey" : "mepkty2uuzzqzzqc5ny5rj2x",
        "q" : name});    
      content = r.pick("$.content").decode();
      total = content.pick("$.total");
      movies = content.pick("$.movies");
      movie = movies[0];
      title = movie.pick("$.title").as('str');
      synopsis = movie.pick("$.synopsis").as('str');
      rel_year = movie.pick("$.year").as('str');
      rating = movie.pick("$.mpaa_rating").as('str');
      critic_rat = movie.pick("$.ratings.critics_rating").as('str');
      aud_rat = movie.pick("$.ratings.audience_rating").as('str');
      img_src = movie.pick("$.posters.thumbnail");
      ret = <<  <div id = "result">Search Results:</div>
                <h1> #{title} </h1>
                <img src = #{img_src} alt = #{title}>
                <div id="synop">Synopsis: #{synopsis}</div>
                <div id="yr">Year: #{rel_year}</div>
                <div id="rating">Rating: #{rating}</div>
                <div id="crit_Rate">Critics Rating: #{critic_rat}</div> 
                <div id="aud_rat">Audience Rating: #{aud_rat}</div> >>;

      ret_none = << <div id="result">No such movie</div> >>;

      (total > 0) => ret | ret_none
    }
  }
  rule HelloWorld {
    select when web cloudAppSelected
    pre {
      my_html = <<
        <div id = "info">
          Type in the movie that you're looking for
        </div>
        <div id="main">
          This code will all be replaced.
        </div> >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createLoadPanel("Rotten Tomatoes movie deets right at your fingertips!", {}, my_html);
    }
  }
  

  rule send_form {
     select when web cloudAppSelected
        // Display notification that will not fade.
        pre {
            a_form = <<
                <form id="my_form" onsubmit="return false">
                    <input type="text" name="movie"/>
                    <input type="submit" value="Submit" />
                </form> >>;
        }
        {
            replace_inner("#main", a_form);
            watch("#my_form", "submit");
        }
    }

    rule respond_submit {
        select when web submit "#my_form"
        pre {
            moviename = event:attr("movie");
            data = get_movie_info(moviename);
            //output = "the output: " + "key: " + key:rotTomKey() + "---" + data{"content"} + "---" + Kdata{"status_line"};

        }
        replace_inner("#info", data);
    }


  
}