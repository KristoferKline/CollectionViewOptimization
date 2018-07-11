# CollectionViewOptimization
A swift project for optimizing layout and image loading by creating `CGImageContext`. This reduces memory significantly because the underlying logic behind an `UIImageView` relies on scaling its model, a `UIImage`, into the view's bounds.

![](https://media.giphy.com/media/9JyKCcCp3YFuangZXH/giphy.gif)

## Some Objectives
- Remove storyboards to increase build-times and magic numbers.
- Create an infinite scroller of images.
- Keep a small view controller file by isolating the majority of the logic into a custom data source.
- Explore topics covered in [Modernizing Grand Central Dispatch WWDC 2017](https://developer.apple.com/videos/play/wwdc2017/706/)
- Create a preview image view controller that is interactable and interuptable.
- Follow accessibility guidelines with scaling text labels.
- Be compatable from iPhone SE to iPhone X.
