# NaviSync App Clip & Instant Invitation Architecture

NaviSync supports **Apple App Clips** ("Applets") allowing invited friends who do not have the NaviSync app installed to immediately open an instant, lightweight mini-app on their iPhone upon tapping an invitation URL.

## Key App Clip Features
1. **Instant URL Experience**:
   - Invitation links (e.g. `https://navisync.app/m/<meeting_id>`) invoke the **NaviSync App Clip**.
   - No full App Store download required — opens in under 2 seconds via iOS App Clip Card.

2. **Core Capabilities in App Clip Mode**:
   - Displays the **Target Location** on an interactive Map.
   - Displays Host Name (Person X) and Meeting Note.
   - Accepts Invitee Name, Contact Info, and Origin Location ("Where he is coming from").
   - Lets the user **Accept** or **Decline**.
   - Upon Accept, records the friend's location and RSVP status so Person X instantly sees their distance, pin, and ETA on their Multi-Map and CarPlay screens!
   - Offers a direct banner to install the full NaviSync app for persistent tracking.

## App Store & Xcode Setup
- **Associated Domains Capability**: `appclips:navisync.app` and `webcredentials:navisync.app`
- **App Clip Target Bundle Identifier**: `KeyFight.NaviSync.Clip`
- **Apple Developer Portal**: Configure Advanced App Clip Experiences pointing to default URL pattern `https://navisync.app/m/*`.
