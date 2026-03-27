# Launch Image Assets

This asset set contains the iOS launch image resources used by the native Runner project.

## Updating Launch Assets

You can update these assets in either of the following ways:

1. Replace the image files directly in this directory.
2. Open the iOS workspace in Xcode and edit the asset catalog visually.

## Open in Xcode

```bash
open ios/Runner.xcworkspace
```

Then navigate to:

- `Runner`
- `Assets.xcassets`
- `LaunchImage.imageset`

## Notes

- Keep file names and asset slots consistent with the catalog configuration.
- After changing launch assets, rebuild the iOS app to verify the launch screen renders correctly on both simulator and physical devices.
