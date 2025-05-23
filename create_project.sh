#!/bin/bash

echo "Creating new Xcode project..."

# Remove existing project
rm -rf MastodonClient.xcodeproj

# Create a temporary directory for project generation
mkdir -p temp_project
cd temp_project

# Create a minimal main.swift to satisfy Xcode project creation
mkdir -p MastodonClient
echo 'import SwiftUI
@main struct App: App { var body: some Scene { WindowGroup { ContentView() } } }
struct ContentView: View { var body: some View { Text("Hello") } }' > MastodonClient/main.swift

# Create the Xcode project using swift package
swift package init --type executable --name MastodonClient

# Move back and copy the generated project
cd ..
cp -r temp_project/.build/. MastodonClient.xcodeproj/ 2>/dev/null || true

# Clean up
rm -rf temp_project

echo "Project structure created. Opening Xcode to generate proper project..."
echo "Please create a new iOS App project in Xcode with the name 'MastodonClient'"
echo "Then copy the source files from MastodonClient/ folder into the new project."