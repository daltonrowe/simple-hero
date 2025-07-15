# Simpleteam

Simple way to collect status updates from small teams.

## Development

```zsh
bin/dev
```

## References

https://greg.molnar.io/blog/tailwindcss-and-rails-8/
https://medium.com/@rob__race/adding-sign-up-to-the-rails-8-authentication-generator-ae24facc624f

## Configuration
- All secrets are stored in rails credentials store via: `bin/rails credentials:edit`
- All secrets need to be mocked in the test env: `config/environments/test.rb`
- All settings are stored in a settings initializer: `config/initializers/settings.rb`
