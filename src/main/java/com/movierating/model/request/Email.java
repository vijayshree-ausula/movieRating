package com.movierating.model.request;

import com.movierating.config.annotation.ValidEmail;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class Email {

	@ValidEmail
	private String to;
	
	private String subject;
	
	@NotBlank
	private String text;
}
