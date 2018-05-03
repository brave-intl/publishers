Allow other Publisher to verify already verified channel.
    if channel is verified it must go into a pending state.
        this needs eyeshade changes to conditionally verify channel
        we then need a way to tell eyeshade the the verification should be rejected (if contested) or finalized
        then remove the channel that isn't staying


Channel Model
* new fields
  * verification_pending (for subsequent channels)
  * contested_by_channel_id (for initial channels)
  * contest_token (for initial channels)
  * contest_time_out
* relax uniqueness constraint

helper
  * send emails when verified
    * owner of originally verified channel must get email with contest token
    * owner of new channel must get status email

* Dashboard View
  * Channel must show status
    * new channel should show it's pending
    * original channel must show it's pending and allow approval
      * should we show contact info for new owner
      * how to handle multiple contesting channels
        * A channel can only be contested by one other channel
        * If a third channel verifies it will replace the second channel, which will revert to unverified 