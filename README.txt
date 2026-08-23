DrivePro V91.15 – Realtime Assignment Fix

Based directly on the user-supplied V91.14 build.

Changes in this build are isolated to Realtime assignment handling:
- Correctly tracks Supabase Realtime subscription via the SUBSCRIBED callback.
- Does not inspect the internal RealtimeChannel.state for SUBSCRIBED.
- Queues assignment broadcasts until the channel is actually subscribed.
- Uses broadcast acknowledgements and retries failed queued broadcasts.
- Keeps the school-scoped private Realtime channel.
- Keeps existing database/RLS logic unchanged.
- Version marker is V91.15.

Validation performed:
- All inline JavaScript blocks pass node --check.
- Source contains V91.15 and no V91.14 markers.
- No Supabase SQL/DDL is included or required for this frontend fix.

V91.8 remains the rollback/backup baseline.
