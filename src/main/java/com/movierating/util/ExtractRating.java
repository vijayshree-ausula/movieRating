package com.movierating.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.movierating.model.response.MovieDetail;

@Service
public class ExtractRating {
    protected static Set<MovieDetail> getExtractedRating() {
        String filePath = "google_results_api.txt"; // your file
        Map<Integer, MovieDetail> movieDetails = new TreeMap<>(Collections.reverseOrder());
        Set<MovieDetail> res = new LinkedHashSet<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            String line;
            int lineNum = 1;
            boolean foundRating = false; boolean foundYear = false;
            String title =""; String rating=""; String year = "";
            
            while ((line = br.readLine()) != null) {
            	line = line.trim();
                if (line.contains("og:description")) {
                    // Split the line by "|"
                    String[] parts = line.split("\\|");

                    // Check if there's something after the pipe
                    if (parts.length > 1) {
                        String afterPipe = parts[1].substring(1, parts[1].length()-2);
                        rating = afterPipe;
                    }
                    foundRating = true;
                }
                if (line.contains("\"title\"")) {
                	if(line.contains("(")){
                		title = line.substring(13, line.indexOf('('));
                	}
                	
                	// Regex: matches a 4-digit year from 1900 to 2099
                    Pattern yearPattern = Pattern.compile("\\b(19|20)\\d{2}\\b");
                    
                    Matcher matcher = yearPattern.matcher(line);
                    while (matcher.find()) {
                        year = matcher.group();
                    }
                    
                    foundYear = true;
                }
                if(foundRating && foundYear) {
                	MovieDetail movieDetail = new MovieDetail();
                	movieDetail.setName(title);
                	movieDetail.setRating(rating);
                	movieDetail.setYear(year);
                	movieDetails.put(Integer.parseInt(year), movieDetail);
                }
                lineNum++;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        res.addAll(movieDetails.values());
		return res;
    }
}
