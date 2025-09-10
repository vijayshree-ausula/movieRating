package com.movierating.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.movierating.model.response.MovieDetail;

@Service
public class WebScraping {
	@Autowired
	static
	ExtractRating extractRating;
//    private static final String API_KEY = "AIzaSyCKT8ebqaYWLw18xdI2iODnnx_s-3SW1rc"; //Library
	private static final String API_KEY = "AIzaSyB_fMuESqkEY2NMN4aGsgWzybC_tdtHCYs";
//    private static final String CX = "f684bbed866db499c"; Library
	private static final String CX = "b6aceb750955c4b44";

    public Set<MovieDetail> getMovieRating(String query) {
//        String query = "Inception"; // Your search query
    	System.out.println("Title of the movie: "+ query);
    	String encodedTitle = URLEncoder.encode(query, StandardCharsets.UTF_8);
        String apiUrl = "https://www.googleapis.com/customsearch/v1?q=" + encodedTitle.replace(" ", "+") +
                "&key=" + API_KEY + "&cx=" + CX;

        try {
            // Connect to the API
            HttpURLConnection connection = (HttpURLConnection) new URL(apiUrl).openConnection();
            connection.setRequestMethod("GET");

            File file = new File("google_results_api.txt");

            // Delete if file already exists
            if (file.exists()) {
                if (file.delete()) {
                    System.out.println("Existing file deleted: " + "google_results_api.txt");
//                } else {
//                    System.out.println("Failed to delete file.");
                }
            }
            
            // Read the response
            BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String line;
            StringBuilder response = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                response.append(line).append("\n");
            }
            reader.close();

            // Write response to a file
            FileWriter writer = new FileWriter("google_results_api.txt");
            writer.write(response.toString());
            writer.close();
            System.out.println("Results saved to google_results_api.txt");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return extractRating.getExtractedRating();
    }
}

