Submitter Checklist:

- [ ] Submitted a [ticket](https://github.com/brave-intl/publishers/issues) for my issue if one did not already exist.
- [ ] Used Github [auto-closing keywords](https://help.github.com/articles/closing-issues-via-commit-messages/) in the commit message.
- [ ] Added/updated tests for this change (for new code or code which already has tests).
- [ ] Tagged reviewers.
- [ ] Integrated piwik/matomo (for code that adds new buttons).

Test Plan:


Reviewer Checklist:

Tests
- [ ] Adequate test coverage exists to prevent regressions

Security:
- [ ] No raw SQL -- Always prefer ActiveRecord query helpers ([more info on StackOverflow](https://stackoverflow.com/questions/41410752/rails-5-sql-injection#41452695))
- [ ] XSS is mitigated -- Avoid `html_safe` and `raw`; escape untrusted content from users and 3rd party APIs ([Rails XSS guide](https://brakemanpro.com/2017/09/08/cross-site-scripting-in-rails) and [OWASP XSS Prevention Cheat Sheet](https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet))
