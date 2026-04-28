#!/bin/bash
set -euo pipefail

# libpq is installed keg-only by Homebrew (it conflicts with the postgresql formula),
# so its binaries (psql, pg_dump, etc.) are not linked into /opt/homebrew/bin.
# Adding the keg's bin directory explicitly makes those tools available on the PATH.
echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
