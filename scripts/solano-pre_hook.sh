#!/bin/bash
# Solano CI pre_hook setup hook - Ensure dependencies are installed
# See http://docs.solanolabs.com/Setup/setup-hooks/

set -e  # Exit on error

export PATH=/usr/lib/erlang/bin:/usr/lib/elixir/bin:$PATH

# Ensure specific version of erlang is installed
ERLANG_VER=`erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell | sed 's/[^0-9]*//g'`
if [ "$ERLANG_VER" != "19" ]; then
  curl -o $TMPDIR/erlang-solutions_1.0_all.deb https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i $TMPDIR/erlang-solutions_1.0_all.deb
  sudo apt-get update
  sudo apt-get -f -y install  # Clean-up any pending installs
  sudo apt-get -y install erlang=1:19.0-1
fi
ln -f -s /usr/lib/erlang/bin/erl $HOME/bin/

# Ensure specific version of elixir is installed
if [ `which elixir` ]; then
  ELIXIR_VER=`elixir --version | grep ^Elixir` | awk '{print $2}'
else
  ELIXIR_VER=0
fi
if [ "$ELIXIR_VER" != "1.3.2" ]; then
  sudo apt-get -y install elixir=1.3.2-1
fi
ln -f -s /usr/lib/elixir/bin/mix $HOME/bin/

# Install/update other dependencies
mix local.hex --force
mix local.rebar --force
mix deps.update phoenix
mix deps.get
npm install npm  # Install newer version of npm
npm install

# Compile
mix compile
