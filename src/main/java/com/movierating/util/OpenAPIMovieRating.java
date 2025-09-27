//package com.movierating.util;
//
//import com.theokanning.openai.service.OpenAiService;
//import com.theokanning.openai.OpenAiHttpException;
//import com.theokanning.openai.completion.chat.*;
//import java.util.HashMap;
//import java.util.Map;
//
//public class OpenAPIMovieRating {
//
//    // Simple in-memory cache
//    private final Map<String, MovieRating> cache = new HashMap<>();
//
//    // OpenAI API key from environment variable
//    private final OpenAiService openAiService;
//
//    public OpenAPIMovieRating() {
//        String apiKey = System.getenv("OPENAI_API_KEY");
//        openAiService = new OpenAiService("");
//    }
//
//    public MovieRating getMovieRating(String movieName, String year) {
//        String key = movieName + (year != null ? " (" + year + ")" : "");
//        if (cache.containsKey(key)) {
//            return cache.get(key); // return cached result
//        }
//
//        String prompt = "You are a movie rating assistant. " +
//                "Given a movie title " + key + ", provide:\n" +
//                "1. The certificate rating (G, PG, PG-13, R, NC-17) based on your understanding.\n" +
//                "2. A concise 2-sentence review summarizing its content and age-appropriateness.\n" +
//                "Output ONLY JSON: {\"rating\": \"\", \"review\": \"\"}";
//
//        ChatMessage message = new ChatMessage("user", prompt);
//        ChatCompletionRequest request = ChatCompletionRequest.builder()
//                .model("gpt-5-mini")
//                .messages(java.util.List.of(message))
//                .build();
//        ChatCompletionResult result = null;
//        try {
//        	 result = openAiService.createChatCompletion(request);
//        } catch (OpenAiHttpException e) {
//            if (e.statusCode == 429) {
//                System.err.println("Quota exceeded. Check your OpenAI billing/plan.");
//                
//            } else {
//                throw e;
//            }
//        }
//
//        
//        String content = result.getChoices().get(0).getMessage().getContent();
//
//        // Optional: parse JSON content returned by the model
//        MovieRating movieRating = MovieRating.fromJson(content);
//
//        cache.put(key, movieRating); // store in cache
//        return movieRating;
//    }
//
//    // MovieRating class
//    public static class MovieRating {
//        public String rating;
//        public String review;
//
//        public static MovieRating fromJson(String json) {
//            // Simple parsing (you can replace with Gson or Jackson for robustness)
//            MovieRating m = new MovieRating();
//            json = json.replaceAll("[{}\"]", ""); // remove braces and quotes
//            for (String part : json.split(",")) {
//                String[] kv = part.split(":");
//                if (kv.length == 2) {
//                    if (kv[0].trim().equalsIgnoreCase("rating")) {
//                        m.rating = kv[1].trim();
//                    } else if (kv[0].trim().equalsIgnoreCase("review")) {
//                        m.review = kv[1].trim();
//                    }
//                }
//            }
//            return m;
//        }
//
//        @Override
//        public String toString() {
//            return "Rating: " + rating + "\nReview: " + review;
//        }
//    }
//
//    // Test main
////    public static void main(String[] args) {
////    	OpenAPIMovieRating service = new OpenAPIMovieRating();
////        MovieRating sonic3 = service.getMovieRating("Sonic the Hedgehog 3", "2000");
////        System.out.println(sonic3);
////    }
//}
