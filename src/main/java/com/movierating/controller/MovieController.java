package com.movierating.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.movierating.model.response.MovieDetail;
import com.movierating.service.impl.MovieService;
import com.movierating.service.impl.MovieServiceTMBD;

@RestController
@RequestMapping("/api")
public class MovieController {
	
	@Autowired
	MovieService movieService;
	
	@Autowired
	MovieServiceTMBD movieServiceTmbd;
	
	@Cacheable("movies")
	@GetMapping("/movieNameImdb")
	public List<MovieDetail> getMovieRating(@RequestParam(name = "name", required = true) String movieName) {
		
		return movieService.getMovieRating(movieName);
		
	}
	
	@Cacheable("movies")
	@GetMapping("/movieName")
	public List<MovieDetail> getMovieRatingImdb(@RequestParam(name = "name", required = true) String movieName) throws Exception {
		
		return movieServiceTmbd.getMovieRating(movieName);
		
	}

}
