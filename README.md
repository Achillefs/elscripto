# El Scripto Spectacularrr

elscripto is a command line automator. It was initially written to start up a few OSX Terminal tabs that I used for Rails development. At first it was just a ruby script with a few hardcoded commands, but it slowly evolved the nifty little configurable little command line utility you see here.

## Platforms

This gem currently works on Mac OSX, using a few Applescript tricks.

## Installation

Add this line to your application's Gemfile:

    gem 'elscripto'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elscripto

## Usage

From within a project directory, run the following command to bootstrap elscripto.

    $ elscripto init

This will create an .elscripto file, containing a few command definitions that you can edit to your liking.
From then on, every time you call elscripto from within that folder, the specified commands will be ran in different tabs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request