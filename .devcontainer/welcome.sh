#!/usr/bin/env bash
cat <<'BANNER'

  RFM segmentation — this Codespace already has PostgreSQL 16 running
  with the synthetic sample loaded.

      make test     run the assertion: segments match expected output
      make run      load the sample again and print the result
      psql          poke at the tables yourself

  Nothing here is real data. Nothing leaves this container.

BANNER
