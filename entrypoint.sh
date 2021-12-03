#!/bin/sh

set -x

command="$1"

case "$command" in
   build)
      # This needs to run as root for chroot and mknod to work.
      shift 1
      exec cdist-build "$@"
   ;;
   setup-ssh)
      shift 1
      source_dir="$1"
      # Give the ssh client it's favorite permissions.
      mkdir /home/cdist/.ssh
      cp "$source_dir"/* /home/cdist/.ssh/
      chmod 0700 /home/cdist/.ssh
      chmod 0600 /home/cdist/.ssh/*
   ;;
   git-clone-config)
      shift 1
      source_repo="$1"
      exec git clone "$source_repo" /cdist/config
   ;;
   *)
      exec cdist "$@"
   ;;
esac

