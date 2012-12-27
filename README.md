# El Scripto Spectacularrr

elscripto is a command line automator. It was initially written to start up a few OSX Terminal tabs that I used for Rails development. At first it was just a ruby script with a few hardcoded commands, but it slowly evolved the nifty little configurable little command line utility you see here.

## Platforms

This gem currently works on Mac OSX, and Linux with Gnome desktop.
It uses Applescript and gnome-terminal shell automation depending on the platform.

## Installation

Add this line to your application's Gemfile:

    gem 'elscripto'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elscripto

## Usage

From within a project directory, run the following command to bootstrap Elscripto.

    $ elscripto init

This will create an `.elscripto` file, containing a few command definitions that you can edit to your liking.
From then on, every time you call `elscripto` from within that folder, the specified commands will be ran in different tabs. [This is an example configuration](https://github.com/Achillefs/elscripto/blob/master/config/elscripto.init.yml) file that also tells you how to add your own definitions in a project.

### Command Definitions

Elscripto comes with a few built-in shell commands; Upon first run, a default configuration file is installed in a platform-dependent directory 
  
  * **OSX**: `/usr/local/etc/elscripto/_default.conf`
  * **Linux**: `<your home dir>/.config/elscripto/_default.conf`

Have a look at the bundled [elscripto.conf.yml](https://github.com/Achillefs/elscripto/blob/master/config/elscripto.conf.yml) for a list of built-in commands.

You can drop in more files in there and as long as the file extension is conf, Elscripto will attempt to load the definitions. Bear in mind the following:

  * Definition files are loaded alphabetically, so you can overwrite a default definition (or one of yours for that matter) by re-defining it in a latter custom configuration file
  * Overwriting `default.conf` is not a good idea, your changes are probably gonna get overwritten by a gem update

## Suggestions, comments, bugs, whatever

Feel free to use Issues to submit bugs, suggestions or feature requests. 
Elscripto should work on all major platforms (yes, even Windows), let not my limited knowledge / experience and time stand in the way!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request