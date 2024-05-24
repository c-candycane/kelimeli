# Kelimeli Quiz Application

Kelimeli is a mobile application designed to make your vocabulary learning process fun and effective. The app offers features such as adding words, taking quizzes, and analyzing learning progress.

## Features

- **Add Words:** Users can add words and their meanings they want to learn.
- **Quiz:** Users can take quizzes based on the words they have selected. The quiz is designed to be repeated at specific intervals.
- **Analysis:** A section that analyzes the users' learning process and shows their progress.
- **User Registration:** Users can create an account to save their progress.
- **Google Sign-In:** Users can log in using their Google account.
- **Default Words:** The application provides 5 default words to get users started.
  
## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/username/kelimeli-quiz.git
   
2. **Install the required packages:**
   ```bash
   cd kelimeli-quiz
   flutter pub get

3. **Configure Firebase:**
   
    Create a project in Firebase Console.
    Download the Firebase configuration files for Android and iOS (google-services.json and GoogleService-Info.plist) and place them in the appropriate directories in your project.

4. Run the application:
   ```bash
   flutter run


## USAGE
## ADDING WORDS
**Navigate to Add Word Screen:** Tap on the "Add Word" button on the main screen.  
**Enter Word and Meanings:** Enter the English word, its Turkish meaning and optionally an example sentence, image or pronunciation. You can also have it read using the text to speech tool in the application.  
**Save:** Tap on the "Save" button to add the word.
## QUIZ
**Navigate to Quiz Screen:** Tap on the "Quiz" button on the main screen.  
**Question:** A question will be displayed on the screen. Enter the answer in the provided field.
**Submit Answer:** Tap on the "Submit" button to submit your answer. You will receive feedback on whether your answer is correct or incorrect.  
**Next Question:** After answering, proceed to the next question. Continue until all questions are answered.

**6-Step Word Learning Process**  
The quiz is designed to help users learn words through a 6-step process. The intervals for quiz repetition are based on the stage of the word:

**Stage 1:** Immediate testing.  
**Stage 2:** Test after 1 day.  
**Stage 3:** Test after 7 days.  
**Stage 4:** Test after 30 days.  
**Stage 5:** Test after 90 days.  
**Stage 6:** Test after 180 days.  
**Stage 7:** Test after 365 days.  

## ANALYSIS
**Navigate to Analysis Screen:** Tap on the "Analysis" button on the main screen.  
**Progress:** View your percentage of correct answers by category. When you click on the category, you can view detailed analysis of the words in that category.  
**Print:** Print these analyzes as csv from the analysis page.
## Screenshots

**Main Screen**

![image](https://github.com/c-candycane/kelimeli/assets/108942127/b5f797d7-2e50-40de-bca6-ffc4a2b335e8)



**Add Word Screen**

![image](https://github.com/c-candycane/kelimeli/assets/108942127/89b87226-74ad-4aa1-ba12-5f879e866ac5)



**Quiz Screen**

![image](https://github.com/c-candycane/kelimeli/assets/108942127/c8e87d62-4212-41b6-b336-2eebd18a5606)



**Analysis Screen**

![image](https://github.com/c-candycane/kelimeli/assets/108942127/d85311df-b5bc-4c50-ac39-280162bd70c5)



![image](https://github.com/c-candycane/kelimeli/assets/108942127/ee9ada07-9b30-46f3-9931-78446649eae8)


## Contact  
Email: huseyinozcan5507@hotmail.com
