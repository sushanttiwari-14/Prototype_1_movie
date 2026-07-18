# Two-minute demo script

**0:00 — Home.** “Long-distance dinner usually means two disconnected delivery apps. Sync Table makes it feel like one shared table.” Tap **Create Sync Table**.

**0:15 — Invite.** Point out Aniket in Mumbai, the invite code, separate order/payment promise, then tap **Demo: Join as Partner**.

**0:30 — Matching.** “We first look for the same restaurant. When that isn’t available, Menu Twin compares only serviceable catalogue candidates.” Show the Sync Score, 100% menu match, compatible prices, and predicted arrival difference. Choose **North Indian Grill Night**.

**0:50 — Menu and carts.** Add the paneer bowl. Show Aisha’s partner event and toggle to Bengaluru. “I can observe her cart, never edit it.” Open both carts, make both ready, and continue.

**1:15 — Checkout.** “Two addresses, two carts, two private payment authorizations. Submission is linked, but ownership stays separate.” Submit.

**1:30 — Tracking.** Show separate restaurant statuses and MapKit routes. Advance once to create divergence. “We celebrate a milestone only when both reach it, and update estimates honestly.” Open the ellipsis menu and complete both deliveries.

**1:48 — First bite.** Tap **I’m Ready to Eat**. Let the haptic 3–2–1 finish. Show reactions and save the memory card.

**Close.** “Two locations. Two carts. One shared meal.”

# Likely judge questions

**Does this require the same restaurant in both cities?**  
No. Same restaurant is preferred. Menu Twin then ranks similar serviceable restaurants using deterministic availability and logistics data plus model-assisted culinary classification.

**Is AI deciding delivery timing?**  
No. The model only structures menu attributes. Application logic computes the Sync Score and predicted arrival difference; logistics remains deterministic and auditable.

**Do you delay cooked food or riders?**  
No. The production concept coordinates planned kitchen preparation starts and courier assignment. The UI always exposes each real individual status and updated estimate.

**What if one order falls behind?**  
Individual states diverge visibly. A shared milestone advances only when both orders reach it, and the shared window updates rather than presenting a false guarantee.

**Can one person change the other cart or payment?**  
Never. Ownership is explicit in the data model, the UI is view-only for partner carts, and no payment data is sent over SharePlay.

**How does it work without two devices during judging?**  
`LocalSyncSession` uses the same typed event model and the demo controls simulate the partner. The entire story works offline on one simulator.

**How would this scale?**  
Move the protocol implementations to serviceable-catalogue APIs and a server-authoritative, event-sourced orchestration service with idempotency, inventory validation, encrypted presence, and observability.
