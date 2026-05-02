#!/bin/bash

echo "🔄 Stopping all Gradle daemons..."
./gradlew --stop

echo ""
echo "⏳ Waiting 3 seconds for daemons to stop..."
sleep 3

echo ""
echo "✅ Gradle daemons stopped. You can now run your build commands."
echo ""
echo "Example:"
echo "  ./gradlew :api-gateway:bootRun"

