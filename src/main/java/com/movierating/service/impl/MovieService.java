package com.movierating.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.movierating.model.response.MovieDetail;
import com.movierating.util.ExtractRating;
import com.movierating.util.WebScraping;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MovieService {

	@Autowired 
	WebScraping webScraping;
	
	public List<MovieDetail> getMovieRating(String movieName) {
		Set<MovieDetail> webScrapingresponse =  webScraping.getMovieRating(movieName);
		List<MovieDetail> response = new ArrayList<>();
		response.addAll(webScrapingresponse);
		return response;
	}

}

