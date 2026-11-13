# Turn on AI explanations + chat with Vercel (phone browser only)

1. Get a NEW AI key (do not reuse a key that was pasted anywhere public).
2. vercel.com > sign up with GitHub > Add New > Project > import `ZUNIQ-PROJECT`.
3. On the import screen:
   - Root Directory: `vercel-api`
   - Framework Preset: Other
   - Environment Variables:
       LLM_API_KEY   = your AI key
       LLM_BASE_URL  = https://api.aiunlimited.cc/v1
       LLM_MODEL     = uncensored
       APP_TOKEN     = a long random string you invent (e.g. 30+ letters/numbers)
   - Deploy.
4. Copy the project URL (like https://zuniq-project-xxxx.vercel.app).
   Test: open  <URL>/api/analyze  in the browser. You should see {"error":"method_not_allowed"}.
   If you see a Vercel login page instead, turn off Deployment Protection in Project > Settings.
5. GitHub repo > Settings > Secrets and variables > Actions > New repository secret:
   ZUNIQ_API_URL = the URL from step 4 (no trailing slash needed)
   ZUNIQ_API_KEY = the same value as APP_TOKEN
6. Actions > Build ZUNIQ APK > Re-run all jobs. Install the new APK.

Notes
- The key and token never go in the repo. The app only holds ZUNIQ_API_KEY, which can be extracted from
  the APK, so it only stops casual abuse. Set a spend limit on the AI key. Real per-user protection
  comes with the login milestone.
- Long documents can take 20-40 s. If Vercel times out, the app shows a retry message.
- The old Supabase function in supabase/functions/ is kept only for later and is not used now.
