package com.movierating.util;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.movierating.model.response.MovieDetail;

@Service
public class WebScrapingTmbd {

    private static final String API_KEY = "fb8cee4550fe57796faa5e205831bab4";
    private static final String COUNTRY = "US"; // Change to your country if needed

    public Set<MovieDetail> getMovieRating(String movieName) throws Exception {
    	Set<MovieDetail> res = new LinkedHashSet<>();
    	Map<Integer, MovieDetail> movieDetails = new TreeMap<>(Collections.reverseOrder());

        // Step 1: Search for the movie
    	String encodedTitle = URLEncoder.encode(movieName, StandardCharsets.UTF_8);
        String searchUrl = "https://api.themoviedb.org/3/search/movie?api_key=" + API_KEY + "&query=" + encodedTitle;
        JSONObject searchResult = sendGetRequest(searchUrl);

        JSONArray results = searchResult.getJSONArray("results");
        if (results.length() == 0) {
            System.out.println("No movie found for: " + encodedTitle);
            return res;
        }

        // Step 2: Loop through each movie
        for (int i = 0; i < results.length(); i++) {
            JSONObject movie = results.getJSONObject(i);
            int movieId = movie.getInt("id");
            String title = movie.optString("title", "N/A");
            String releaseDate = movie.optString("release_date", "Unknown");
            double voteAverage = movie.optDouble("vote_average", 0.0);

            // Step 3: Fetch certification for each movie
            String certUrl = "https://api.themoviedb.org/3/movie/" + movieId + "/release_dates?api_key=" + API_KEY;
            JSONObject certResult = sendGetRequest(certUrl);

            String certification = "Not Rated";
            JSONArray countries = certResult.getJSONArray("results");
            for (int j = 0; j < countries.length(); j++) {
                JSONObject countryData = countries.getJSONObject(j);
                if (countryData.getString("iso_3166_1").equals(COUNTRY)) {
                    JSONArray releaseDates = countryData.getJSONArray("release_dates");
                    if (!releaseDates.isEmpty()) {
                        certification = releaseDates.getJSONObject(0).optString("certification", "Not Rated");
                    }
                    break;
                }
            }

            // Step 4: Print details
            System.out.println("--------------------------------------------------");
            System.out.println("Title: " + title);
            System.out.println("Release Date: " + releaseDate);
            System.out.println("Average Rating: " + voteAverage + "/10");
            System.out.println("Certification (" + COUNTRY + "): " + certification);
            
            MovieDetail movieDetail = new MovieDetail();
        	movieDetail.setName(title);
        	if(StringUtils.isEmpty(certification)) {
        		certification = "Not Rated";
        	}
        	movieDetail.setRating(certification);
        	if(!StringUtils.isEmpty(releaseDate)) {
        		String year = releaseDate.substring(0,4);
            	movieDetail.setYear(year);
            	movieDetails.put(Integer.parseInt(year), movieDetail);
        	}
        }
        res.addAll(movieDetails.values());
        return res;
    }

    // Helper method to send GET requests
    private JSONObject sendGetRequest(String url) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(url))
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return new JSONObject(response.body());
    }
}

