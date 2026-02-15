#!/usr/bin/env python3
import base64
import os

# Create assets/icon directory
os.makedirs("assets/icon", exist_ok=True)

# This is a minimal valid 512x512 PNG with a blue background
# Generated with PIL and encoded in base64
png_base64 = """
iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAIAAAB7QOjdAAAA2UlEQVR4nO3BMQEAAADCoPVPbQhfoAAAAOA1v9QAAQA=
"""

# For a proper solution, we'll just create a placeholder and then use flutter_launcher_icons
# Let's create a valid minimal PNG
png_bytes = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd3PnAAAADUlEQVQI12P4z/DfHgAFBQIApKyb+wAAAABJRU5ErkJggg=="
)

with open("assets/icon/app_icon.png", "wb") as f:
    f.write(png_bytes)

print("✅ Created placeholder icon at assets/icon/app_icon.png")
print("ℹ️  Now run: flutter pub run flutter_launcher_icons")

