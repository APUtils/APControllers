- Assure `Carthage Project/APControllers.xcodeproj` and `Pods Project/APControllers.xcworkspace` have all dependencies added.
- Run `checkBuild.command`
- Change version in podspec
- Run `podUpdate.command`
- Update CHANGELOG.md
- Update README.md with new version if needed
- Push changes in git
- Add git tag
- Run `podPush.command`
