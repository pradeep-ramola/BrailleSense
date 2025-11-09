🌟 Inspiration

We were inspired to create this project after noticing a real-world accessibility gap. Many visually and hearing-impaired users struggle with real-time communication, and we wanted to change that.

Our idea was to bridge speech and touch — transforming spoken words into tactile Braille feedback using haptics.
The concept of “feeling” language instead of hearing or seeing it motivated us to combine speech recognition and Braille technology into one meaningful, inclusive solution.

🧠 What We Learned

Throughout development, we explored the intersection of accessibility and technology in depth.
We learned about:

🎙️ Speech-to-text processing with Apple’s iOS Speech framework

⠿ Braille encoding systems and real-time character mapping

📱 Haptic feedback integration for tactile communication

🧭 Accessible UI/UX design, focusing on non-visual user interaction

On the technical side, we strengthened our skills in Swift, AVFoundation, and real-time data processing — all while learning how to design with empathy and inclusivity in mind.

🏗️ Building the Project

Our build process followed an iterative and user-centered approach:

Braille Mapping: Programmatically represented each Braille character.

Speech Recognition: Implemented real-time voice-to-text conversion using the iOS Speech framework.

Haptic Integration: Each Braille dot triggers a distinct vibration pattern, allowing users to feel each character through the phone’s vibration motor.

Minimal UI: Designed a clean, intuitive interface that works without relying on sight or sound.

User Testing: Gathered feedback from sample users to refine feedback timing, sensitivity, and accessibility flow.

This combination allows users to literally touch language — experiencing speech as vibration-based Braille in real time.

⚙️ Challenges We Overcame

Creating this system wasn’t simple. Some major challenges included:

⏱️ Maintaining real-time performance — even slight delays disrupt comprehension.

🤲 Designing distinct haptic patterns that feel natural, accurate, and comfortable over long sessions.

🧩 Balancing accessibility with simplicity, ensuring every interaction is intuitive for users with varying sensory abilities.

🔄 User testing required patience, empathy, and constant iteration to meet real accessibility needs.

Through these challenges, we learned that true accessibility design means building with users, not just for them.

👥 Target Users

Our app is designed for individuals across a range of accessibility needs:

🦯 Visually Impaired Users: Who cannot rely on sight to read or view content.

🔇 Hearing Impaired Users: Who need access to spoken information in another modality.

🤝 Deaf-Blind Users: Who benefit most from tactile, real-time feedback through vibration-based Braille.

💡 Vision

Our goal is to make communication more inclusive, instant, and human — turning every smartphone into a bridge between spoken words and tactile understanding.

🔮 Future Scope

As BrailleSense continues to evolve, we see a powerful opportunity to integrate spatial intelligence and gesture-based interaction — making the experience more natural, adaptive, and context-aware.

1. 🖐️ Path & Gesture Detection

Integrate gesture tracking to detect finger movement patterns across the screen, allowing users to draw or trace Braille characters directly.

Detect finger path direction, speed, and pattern recognition.

Provide immediate haptic feedback to confirm accurate Braille tracing.

Enable freeform Braille input (instead of only tapping dots).

This will help users learn and practice Braille writing interactively, not just read it.

2. 🌍 Spatial Orientation & Object Detection

Use CoreML and ARKit (on iOS) to add path and object detection in real-world environments.

Vibrate when obstacles or text signs are detected in front of the user.

Provide directional haptic feedback (e.g., left-right vibrations to guide navigation).

Combine camera input and speech output for “talking navigation” with Braille cues.

This would transform BrailleSense into a mobility and awareness assistant, not just a language tool.

3. 🔊 Context-Aware Haptic Feedback

Develop adaptive vibration patterns that change based on context —

Short pulses for letters

Longer or directional vibrations for navigation or alerts

Dynamic feedback when users move across detected objects or paths

This bridges the gap between tactile sensing and environmental awareness.

4. 🧭 Indoor Path Guidance

Integrate Bluetooth beacons or AR-based positioning for indoor navigation — helping users feel their way through buildings via subtle vibration cues.

Example: guiding a user from the entrance to a classroom or a Braille station using distinct vibration patterns for “turn left,” “straight ahead,” or “destination reached.”

5. 🤖 AI-Powered Touch Recognition

Use on device ML to classify touch patterns and gestures as Braille inputs or commands.
The system can learn how each user interacts, improving accuracy and reducing the need for visual feedback.

6. 🌐 Smart Integration

Connect with IoT and smart devices for example:

Vibrate when a notification or message arrives.

Read aloud or convert to Braille any text on nearby smart displays.

Support hands-free voice commands combined with tactile responses.
