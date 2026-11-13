ZUNIQ mascot animations (your own files)

Put animation files in this folder. The app picks them up automatically (no code changes).
Name each file after the mood it should play for:

  idle        resting / waiting
  greeting    when the app or Assistant opens (also good for Home)
  listening   while the user types
  thinking    while waiting for the AI
  explaining  when the AI explains something
  happy       good news / success
  unsure      "the document does not say" / not sure
  error       something went wrong

Optional: "default" is used for any mood that has no file of its own.

Accepted formats: .json (Lottie), .gif, .webp (animated), .png
Examples: thinking.json  or  thinking.gif  or  default.json
If both .json and an image exist for the same name, the .json is used.
Moods with no file keep showing the static mascot pose.
