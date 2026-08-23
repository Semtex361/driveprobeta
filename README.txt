DrivePro V91.15 – Realtime Assignment Broadcast Fix

Root cause fixed:
The V91.14 code checked `channel.state === 'SUBSCRIBED'` before sending
the STUDENT_ASSIGNMENT_CHANGED broadcast. Supabase JS reports SUBSCRIBED
through the subscribe callback, while the channel state is `joined`.
Therefore the broadcast was never sent.

Fix:
- Track the actual SUBSCRIBED callback state.
- Queue assignment broadcasts if the channel is still joining.
- Flush queued assignment broadcasts immediately after SUBSCRIBED.
- Reset the realtime subscribed flag on errors/close/logout.
- Avoid the incorrect lifecycle check against channel.state='SUBSCRIBED'.

No Supabase schema/data changes are required for this fix.

Validation:
- 6 JavaScript blocks syntax-checked successfully.
