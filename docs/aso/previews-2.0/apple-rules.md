# What Apple publishes about App Store previews (read 2026-11-22)

## App Review Guideline 2.3.4 (developer.apple.com/app-store/review/guidelines/)

> Previews are a great way for customers to see what your app looks like and what it does. To ensure people
> understand what they'll be getting with your app, previews may only use video screen captures of the app itself.
> Stickers and iMessage extensions may show the user experience in the Messages app. You can add narration and video
> or textual overlays to help explain anything that isn't clear from the video alone.

Cutling iOS 1.6.1 was rejected under 2.3.4 on 2026-11-11 because its iPhone and iPad previews drew a phone bezel
around the screen recording. Its resubmission with the bare screen recording was accepted (docs/aso/open-items.md item 5).

## App previews page (developer.apple.com/app-store/app-previews/)

> App previews demonstrate the features, functionality, and user interface of your app using footage captured on
> device. You can have up to three app previews for each language your app supports, and each preview can be up to 30
> seconds long. App previews display and autoplay on your product page and within search results, and they can be used
> in Apple Ads.

> If you have multiple previews, make sure that each video shows people something new about your app.

> Stay within the app. App previews must show only content within the app itself. Don't film people interacting with
> a device, such as an over-the-shoulder angle or fingers tapping the screen.

> If you need to demonstrate how interaction or navigation works within your app, you may add graphic elements, such
> as touch hotspots. We recommend capturing the native UI resolution rather than zooming in on the view. Ensure that
> any transitions between scenes don't imply functionality that your app doesn't include. Aim to use straightforward
> transitions, like dissolves and fades.

> By default, app previews play with the sound muted, so consider using copy to add additional context to your
> footage. Ensure text is legible, is easy to understand, and remains on the screen long enough for people to read.
> Avoid any seasonal or timely references that will age your video, such as "new for spring" or dates. Don't include
> specific prices, as pricing and currencies vary across regions.

> To establish continuity across scenes, consider using a single musical score or soundtrack throughout your entire
> app preview. To reinforce functionality in your app, you can include sound effects from your UI or gameplay in your
> footage.

> If someone has turned off video autoplay in their App Store settings, a poster frame will display.

## App preview specifications (developer.apple.com/help/app-store-connect/reference/app-preview-specifications)

- 15 to 30 seconds, at most 500 MB, default poster frame at 5 s.
- H.264 (10-12 Mbps VBR, up to High Profile Level 4.0) or ProRes 422 HQ; at most 30 fps; stereo audio (AAC 256 kbps
  or PCM, 44.1 or 48 kHz); .mov, .m4v, .mp4.
- Portrait or landscape on iPhone and iPad; macOS previews are landscape only.
- Accepted sizes: iPhone 886 x 1920 (portrait) or 1920 x 886 (landscape), one size for every Face ID iPhone and
  iPhone Duo. iPad 13" 1200 x 1600 or 1600 x 1200 (smaller iPads scale from it). Mac 1920 x 1080.
