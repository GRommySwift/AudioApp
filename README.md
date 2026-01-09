# macOS Audio Analyzer

This is MacOS appliction (tesk task) is created as a part of interview by Roman Holovai at 09.01.2026 <br>

# Criteria of app:
- [x] App built with SwiftUI using MVVM architecture.
- [x] Audio file picker integration.
- [x] Asynchronous audio loading and processing (async/await).
- [x] UI remains responsive during audio analysis.
- [x] Audio metrics calculation (duration, sample rate, RMS, peak, silence ratio, zero-crossing rate, DC offset, dynamic range).
- [x] Waveform extraction and visualization.
- [x] Project managed with Git.
- [x] Short README describling.

## How to run
1. Clone this project from github or download .zip
2. Open the project in Xcode.
3. Select the macOS run destination.
4. Build and run the app (⌘R).
5. Click "Open Audio File" and select a supported audio format (WAV, AIFF, CAF, MP3, M4A).

## How audio processing is implemented

When you open an audio file, the app reads it into memory using `AVAudioFile` and `AVAudioPCMBuffer`.  
The app then analyzes the raw samples to calculate basic metrics such as duration, RMS, peak, silence ratio, zero-crossing rate, DC offset, and dynamic range.

All processing happens in the background so the UI stays responsive. Once done, results are displayed immediately.

## The following metrics are computed:

- **Average Loudness (RMS)**  
  Calculated as the root mean square of all samples, representing perceived loudness.

- **Peak Level**  
  The maximum absolute sample value, representing the highest signal amplitude.

- **Silence Ratio**  
  The ratio of samples whose absolute amplitude is below a small threshold.

- **Zero-Crossing Rate**  
  The number of sign changes between consecutive samples, normalized by the number of samples.

- **DC Offset**  
  The average of all samples, indicating any constant signal bias.

- **Dynamic Range**  
  Approximated as the difference between peak level and RMS.

# Tradeoffs and limitations

- Only one channel is analyzed (mono) for simplicity.  
- The entire file is loaded into memory, which could be an issue for very large files.  
- Metrics and waveform are calculated in one go, no streaming yet.   

## Performance and Concurrency

Audio loading and analysis are executed off the main thread using Swift concurrency.

Heavy computations such as waveform extraction and metric calculations are performed in background tasks to ensure the UI remains responsive during processing.

Only UI state updates are dispatched back to the main actor.

## Possible Improvements

If more time were available, the following improvements could be made:

- More advanced loudness metrics (e.g. LUFS).
- Better visualization synchronization with playback position.
- Exporting analysis results to a file.
- Unit tests for audio metric calculations and waveform extraction.

## Screenshot:
<p align="leading">
  <img src="1.png" width="800"/>
</p>

