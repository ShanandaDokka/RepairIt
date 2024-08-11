# RepairIt
Introducing RepairIt, designed to revolutionize your approach to electronic repairs. Leveraging the advanced capabilities of Gemini AI, our Flutter app offers a detailed score on the ease of repairing various devices. After creating an account, users can input their device information which will be stored through Google Firebase, allowing personalized repair recommendations. Whether you need advice on at-home fixes, local repair options, or manufacturer services, our app delivers tailored guidance. If your device exhibits symptoms, simply enter them into the app to receive an accurate diagnosis and the most convenient, cost-effective repair solutions. Additionally, potential buyers can explore information on specific or trending devices, empowering them to make well-informed purchase decisions. 
Our app aligns with the Right-to-Repair movement, which advocates for consumers' right to repair their own devices and access necessary parts and information. This cause has gained significant traction, with Google publicly supporting consumers' right to repair. By advancing this cause, our app contributes to environmental sustainability, reducing e-waste and promoting responsible repair practices.

# Run The App
### Requiremenets
* Xcode Installed and Running: Ensure Xcode is installed and up to date. We recommend running the iPhone 15 Pro simulator on your machine.
* Flutter installed locally: Make sure Flutter is installed and properly set up in your environment. Verify by running flutter doctor to ensure all dependencies are met. 
* API key for Gemini: Obtain your Gemini API key, which will be used for fetching data within the app.

## Demo
1. Start by cloning this repo on your local machine:
* Open your terminal and run the following command to clone the repo: `git clone https://github.com/ShanandaDokka/RepairIt.git`
2. At the root level of the repo, create a .env file. 
3. In the .env file, add the line `API_KEY=<YOUR API KEY>` and replace `<YOUR API KEY>` with your API key.
4. Install dependencies: open the terminal and ensure all the Flutter dependencies are installed by running `flutter pub get`
4. Clean any previous builds and create a fresh one by running `flutter clean` followed by `flutter build ios`. 
5. Finally, run `flutter run` and ensure that the app opens on your simulator. 
6. Star by signing up if you don't already have an account and navigate through the different components of the app!

### Optional (Running on a Physical Device)
If you want to run the app on a physical iOS device, make sure your device is connected, and you have the proper developer certificates and provisioning profiles set up. If you encounter issues, consider running flutter doctor to check for any setup problems, and consult the [Flutter documentation](https://docs.flutter.dev/) for detailed guides.

# Setup
Mobile application built using Flutter, a powerful UI toolkit for creating natively compiled applicationsfrom a single codebase. The app leverages several key technologies to deliver a feature-packed experience:

## Tech Stack:
### Flutter:
* Framework: Flutter's reactive framework makes it easier to build highly responsive UIs with less code.
UI Components: The app includes custom widgets, like ListTiles and buttons, to display device information and allow user interaction.

### Firebase Authentication:

* Authentication: Firebase provides secure and scalable authentication services, enabling users to sign in and manage their devices within the app. This ensures that user data is protected and easily accessible across sessions.

### Provider Package:

* State Management: The provider package is used for state management, which helps in managing and updating the UI based on the application state. This ensures that the app's UI reflects the current state of the data seamlessly.

### SharedPreferences:

* Local Storage: SharedPreferences is utilized for storing small amounts of data locally on the device, such as the user's saved devices (e.g., phone, car, laptop). This allows the app to persist user data even when it is closed and reopened.

### Gemini API Integration:
* The app integrates with the Gemini AI API, which is used to fetch data such as device scores. The API interaction enables the app to provide dynamic content and insights, like repairability scores, based on user inputs.

# Outline
- `RepairIt/ios/Runner`
  - `project.pbxproj`: Xcode project file that contains the build configurations, targets, and other settings for the iOS app
  - `/GoogleService-Info.plist`: contains all the Firebase configuration settings specific to the app
- `RepairIt/fonts`: font configurations for app design
- `RepairIt/img`: images, including logos, used in app design
- `lib`
  - `main.dart`: navigates through all pages of the app. 
  - `clickable_box.dart`: custom widget representing a clickable box. A clickable box contains device text with an associated image. 
  - `constants.dart`: contains all necessary constants for the project.
  - `firebase_options.dart`: firebase configuraionts.
  - `fix_it_page.dart`: implementation for the main repair page. 
  - `gemini_api.dart`: configurations for fetching data from Gemini. Includes a function used globally to query Gemini. 
  - `individual_devices.dart`: implementation to display repairability score and additional information for a single device, given the device name, category, and score.
  - `my_devices_page.dart`: implementation to display a user's devices inputted through the user survey. Information stored using Firebase.
  - `trending_page.dart`: implementation to display trending devices and their repairability score. Includes a search functionality to search for devices.
  - `log_in_page.dart`: creates the log in page, also linked to the sign up page if the user does not already have credentials. Uses firebase.
  - `sign_up_page.dart`: called from the log-in page, prompts for a user email/password which is saved using Firebase, and further displays a user survey. 
  - `survey_page.dart`: called from the sign-up page, gets user device information to display in the MyDevices page.



