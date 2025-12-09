Lingo Breeze - Flutter Animation DemoA gamified language learning onboarding experience featuring complex animations and responsive UI.
Quick Start1.
Setup AssetsCreate an assets folder in your project root and add these images:hoppie.png, moksh.png, merlin.png, hat.png, boat.png
Update pubspec.yaml:
flutter:
  uses-material-design: true
  assets:
    - assets/hoppie.png
    - assets/moksh.png
    - assets/merlin.png
    - assets/hat.png
    - assets/boat.png

2. Runflutter pub get
flutter run
Key Features
Rotating World: The bottom "valley" rotates in sync with user swipes.Morphing Button: Transforms from an arrow icon to a text button on the final screen.Animated Boat: Slides in, bobs, and wiggles on the water.Visual Effects: Continuous waves and staggered grid reveals.
Tech Highlights
Clean Architecture: Separated models, constants, and assets.Modular Widgets: UI broken into RotatingPlanetBackground, CharacterDisplay, etc.Performance: optimized with const constructors and scoped AnimatedBuilder rebuilds.Responsive: Layout adapts to screen width using MediaQuery.
