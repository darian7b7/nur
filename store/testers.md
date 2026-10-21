# Nūr: closed test with 12 testers

New personal Google Play accounts must run a **closed test with at least 12 testers who stay opted in for 14 days in a row** before the app can be published to everyone. Start this first: it is the slowest step.

## 1. Gather 12+ people (aim for 15, in case some drop out)

Each tester needs an Android phone and a Google account (Gmail). Collect their Gmail addresses.

## 2. Set it up in the Play Console

1. Testing → **Closed testing** → Create track (name it "Friends").
2. Testers → Create email list → paste the Gmail addresses.
3. Create a release → upload `build/app/outputs/bundle/release/app-release.aab` → release notes: "First test version."
4. Send the release for review (a few hours to a few days).
5. Copy the **opt-in link** from the Testers tab and send it with the message below.

## 3. Message to send (copy and paste)

> Assalamu alaikum! I made an app called **Nūr**: a calm walking app where your day starts at night and the sun rises as you walk, with a verse of the Quran or a hadith along the way.
>
> Could you help me test it for 14 days? Google requires 12 testers before it can go public.
>
> 1. Open this link on your Android phone and tap **"Become a tester"**: [OPT-IN LINK]
> 2. Then install Nūr from the Play Store link on that page.
> 3. Keep it installed for 14 days. Open it now and then and go for a walk 🌅
>
> If anything feels wrong or confusing, just tell me. JazakAllahu khayran!

## 4. During the 14 days

- Nobody should leave the test. Uninstalling is fine as long as they stay opted in, but keeping the app installed is safest.
- Note what testers tell you; Google asks about the test when you apply for production.
- If you fix something, raise the version (`1.0.1+2`), build and upload to the same closed track. The 14 days keep counting.

## 5. After 14 days

Play Console → Dashboard → **Apply for production access**. Google asks a few questions about the test (who tested, what feedback, what changed). Answer honestly; approval usually takes a few days.
