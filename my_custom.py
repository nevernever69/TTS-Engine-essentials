#!/usr/bin/env python3
import sys
import requests
import subprocess

# Get the text from the command-line arguments (or environment variable)
text = sys.argv[1] if len(sys.argv) > 1 else ""
if not text:
    sys.exit("No text provided")
with open("new.txt", "wb") as f:
    f.write(text.encode())

# Define your API endpoint
api_url = "http://localhost:8880/v1/audio/speech"
payload = {
    "model": "kokoro",
    "input": text,
    "voice": "af_bella",  # adjust voice as needed
    "response_format": "wav",
    "speed": 1.0
}

response = requests.post(api_url, json=payload)
if response.status_code == 200:
    # Save the returned audio to a temporary file
    temp_audio = "/tmp/custom_tts_output.wav"
    with open(temp_audio, "wb") as f:
        f.write(response.content)
    # Play the audio (using a command-line player like paplay or aplay)
#    subprocess.run(["paplay", temp_audio])
else:
    sys.exit(f"Error: {response.status_code} - {response.text}")

