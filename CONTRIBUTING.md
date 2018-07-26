# CONTRIBUTING GUIDE

Contributions are welcome! :smile:

## Report bugs or suggest changes

To report bugs, suggest changes or provide ideas please open GitHub issues.

To discuss anything please [contact Cornelius](mailto:cschum@suse.de).

## Contribute code

To contribute code fork the repository and open pull requests with your changes.

Ensure that rspec and rubocop pass locally before sending your PR and always that you add new changes.

If your changes include important new features or bug fixes please add them to the [Master (unreleased) section fo the CHANGELOG.md](https://github.com/openSUSE/trollolo/blob/master/CHANGELOG.md#master-unreleased)

### To run rspec test

To run all the unit tests:

`bundle exec rspec spec/unit`

To run all the test in one spec file, for example `spec/unit/burndown_chart_spec.rb`:

`bundle exec rspec spec/unit/burndown_chart_spec.rb`

To only run the test in the line 415 of the file:

`bundle exec rspec spec/unit/burndown_chart_spec.rb:415`

### To try your changes

Build the gem: 

`bundle exec rake gem:build`

Install the gem: 

`gem install trollolo-<version>.gem`

### To run rubocop

To run Rubocop displaying cop names in offense messages:

`bundle exec rubocop -D`

## Code of Conduct

Trollolo is part of the openSUSE project. We follow all the [openSUSE Guiding Principles](https://en.opensuse.org/openSUSE:Guiding_principles)!