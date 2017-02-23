#!/bin/sh
set -ex
# show available schemes
xcodebuild -list -project ./ResearchUXFactory.xcodeproj
# run on pull request
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  fastlane test scheme:"ResearchUXFactory"
  exit $?
fi
