// constants used throughout codebase

const String geminiTrendingPhones = '''Give me a list of phone models that are trending this year. 
By trending, I mean phone models with the most purchases this year. 
Only give me the titles of the models and separate them by commas with 
nothing else in your response. Give me the top 5 trending phone models.''';

const String geminiTrendingCar = '''Give me a list of car models that are trending this year. 
By trending, I mean car models with the most purchases this year. 
Only give me the titles of the models and separate them by commas with 
nothing else in your response. Give me the top 5 trending car models.''';

const String geminiTrendingLaptops = '''Give me a list of laptop models that are trending this year. 
By trending, I mean laptop models with the most purchases this year. 
Only give me the titles of the models and separate them by commas with 
nothing else in your response. Give me the top 5 trending laptop models.''';

const String trendingPageSubtitle = '''Looking to purchase something?
Explore repairability of the latest trending devices!''';

const String resourceOverloadError = '''Our apologies, 
there are currently too many 
outgoing requests to Gemini.
Please log out and try again 
in a few minutes. ''';

String getQuestion1Prompt(String category, String product) {
  String catg = "";
    switch (category) {
      case "Cars":
        catg = "Summarize online reviews on the repairability of $product from automotive review websites in three sentences maximum.";
      case "Phones":
        catg = "Summarize online reviews on the repairability of $product from major tech publications in three sentences maximum.";
      case "Laptops":
        catg = "Summarize online reviews on the repairability of $product from major tech publications in three sentences maximum";
    }
    return catg;
}

String getQuestion2Prompt(String category, String product) {
  String catg = "";
    switch (category) {
      case "Cars":
        catg = "Are repair services for $product generally available or do they take time? Summarize in max 3 sentences all in one paragraph.";
      case "Phones":
        catg = "Can the display of $product be replaced indepedently? Summarize in max 3 sentences all in one paragraph.";
      case "Laptops":
        catg = "Can the display of $product be replaced indepedently? Summarize in max 3 sentences all in one paragraph.";
    }
    return catg;
}

String getQuestion3Prompt(String product) {
  return "What user forums can I visit to learn more about the repairability of $product? If there are none, just say \"No substantial user forums available.\" If there are, just list the forums and suggest the best one. Answer as a summary in maximum 300 characters.";
}

String getQuestion4Prompt(String product) {
  return "How much do users spend on average on repair costs for the $product? Answer as a summary in maximum 300 characters.";
}

String getQuestion1(String product) {
  return "Online review summary on repairability of $product?";
}

String getQuestion2(String category, String product) {
  String question = "";
  switch (category) {
    case "Cars":
      question = "Are repair services for $product generally available?";
    case "Phones":
      question = "Can the display of $product be replaced indepedently?";
    case "Laptops":
      question = "Can the display of $product be replaced indepedently?";
  }
  return question;
}

String getQuestion3(String product) {
  return "User forums for repairability of $product?";
}

String getQuestion4(String product) {
  return "Average repair costs of $product?";
}

String getScoreString(List<String> input) {
  return "Rate the devices in this list [${input[0]}, ${input[1]}, ${input[2]}, ${input[3]}, ${input[4]}] out of five in terms of repairability. Consider how easy it is to manually repair at home, how substitutable its parts are, and the cost of repairability. Just give me the five scores separated by commas and nothing else in your answer.";
}

String getSingleScoreString(String input) {
  return "Rate the $input out of five in terms of repairability. Consider how easy it is to manually repair at home, how substitutable its parts are, and the cost of repairability. Why do you give it this score (don't include the score in your answer)? Answer as a summary in maximum 300 characters.";
}

String getSingleScoreSingleInputString(String input) {
  return "Rate the $input out of five in terms of repairability. Consider how easy it is to manually repair at home, how substitutable its parts are, and the cost of repairability. Just give me the score nothing else in your answer.";
}

String getCategoryPrompt(String device) {
  return "Is this a phone, laptop, or car: $device. Say \"Cars\" for car, \"Laptops\" for laptop, and \"Phones\" for phone. Include nothing else but that one word.";
}

String getFixItPrompt(String zipCode, String device, String issue) {
  return "My $device device has this issue: $issue. I live in this zip-code $zipCode, and have three options for repair: at-home, independent repair shops, or manufacturer repair. First, list the one you think is best only writing the phrase \"at-home repair\", \"independent business\", or \"manufacturer repair\". Then, in a new paragraph for each, write a small paragraph about the cost/convenience of each option respectively. Make the answers specific to the device and issue and zip code.";
}