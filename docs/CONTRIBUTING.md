# Contributing

Pull requests are welcome from anyone, please feel free to contribute by following the below guidelines.

Fork, then clone the repo:

    git clone git@github.com:your-username/publishers.git

Write your code and tests, then make sure the tests pass:

    bin/rake test

Push to your fork and [submit a pull request][pr].

[pr]: https://github.com/brave-intl/publishers/compare/

We like to make sure that all contributions follow a few guidelines, which will increase the likelihood of a merge:

- Follow the [code review guildelines][codereview]
- Write tests to cover critical functionality
- Write a [good commit message][commit]
- Leave code better than you found it, whenever possible:
  - eliminate [callbacks][callbacks], use a service object instead
  - use [dependency injection][di] to encourage modularity, [an example][di-ex]
  - follow Sandi Metz' [rules][sm]
  - prefer [composition over inheritance][composition]

## Security Reviews

If your code touches any of the aspects mentioned [here][security], or more specific to creators:

- Any changes to data being sent in the pCDN
- Any changes in data being sent from Eyeshade
- Any information collection changes for registration
- Email auth flow changes
- oAuth flow changes

Please open a security review

[composition]: https://betterprogramming.pub/prefer-composition-over-inheritance-1602d5149ea1
[di]: https://solnic.codes/2013/12/17/the-world-needs-another-post-about-dependency-injection-in-ruby/
[di-ex]: https://github.com/brave-intl/publishers/blob/staging/app/services/bitflyer/refresher.rb
[callbacks]: https://engineering.gusto.com/the-rails-callbacks-best-practices-used-at-gusto/
[sm]: https://thoughtbot.com/blog/sandi-metz-rules-for-developers
[codereview]: https://github.com/thoughtbot/guides/tree/main/code-review
[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[security]: https://github.com/brave/brave-browser/wiki/Security-reviews
