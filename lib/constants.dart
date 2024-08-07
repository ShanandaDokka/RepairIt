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

const String trendingPageSubtitle = '''Explore the latest trending devices and
check out their repairability score and details.''';

String getScoreString(List<String> input) {
  return "Rate the devices in this list [${input[0]}, ${input[1]}, ${input[2]}, ${input[3]}, ${input[4]}] out of five in terms of repairability. Consider how easy it is to manually repair at home, how substitutable its parts are, and the cost of repairability. Give me the five scores separated by commas and just";
}

