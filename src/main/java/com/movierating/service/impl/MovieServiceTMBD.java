package com.movierating.service.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.movierating.model.response.MovieDetail;
import com.movierating.util.WebScrapingTmbd;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MovieServiceTMBD {

	@Autowired
	WebScrapingTmbd webScrapingTmbd;

	public List<MovieDetail> getMovieRating(String movieName) throws Exception {
		Set<MovieDetail> webScrapingresponse = webScrapingTmbd.getMovieRating(movieName);
		List<MovieDetail> response = new ArrayList<>();
		response.addAll(webScrapingresponse);
		return response;
	}

}
