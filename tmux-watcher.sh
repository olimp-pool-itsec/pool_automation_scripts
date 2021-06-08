#!/usr/bin/env bash
tmux new-session \; \
  send-keys 'nbp' C-m \; \
  split-window -v -p 70 \; \
  send-keys 'bp' C-m \; \
  split-window -h -p 67 \; \
  send-keys 'node1' C-m \; \
  split-window -h -p 50 \; \
  send-keys 'node2' C-m \; \
