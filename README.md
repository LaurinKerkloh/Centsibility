# Tallune

Personal finance app: import bank CSV exports, categorise transactions by rules, and analyse income and spending. Single user, self-hosted.

## The user

There is no sign-up. Create the user, or change its password, from the Rails console (`kamal console` in production, `bin/rails console` locally):

```ruby
User.create!(email_address: "me@example.com", password: "...")
User.find_by!(email_address: "me@example.com").update!(password: "...")
```

In development, the seeds create `user@example.com` with the password `password`.
