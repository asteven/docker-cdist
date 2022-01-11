#!/bin/sh

#set -x

command="$1"

exit_code=0
out_dir="$(mktemp -d)"


case "$command" in
   build)
      # This needs to run as root for chroot and mknod to work.
      shift 1
      cdist-build "$@"
      exit_code=$?
   ;;
   setup-ssh)
      shift 1
      source_dir="$1"
      # Give the ssh client it's favorite permissions.
      mkdir /home/cdist/.ssh
      cp "$source_dir"/* /home/cdist/.ssh/
      chmod 0700 /home/cdist/.ssh
      chmod 0600 /home/cdist/.ssh/*
      exit 0
   ;;
   git-clone-config)
      shift 1
      source_repo="$1"
      exec git clone "$source_repo" /cdist/config
   ;;
   config|install)
      shift 1
      cdist "$command" --out-dir "$out_dir" "$@"
      exit_code=$?
   ;;
   *)
      cdist "$@"
      exit_code=$?
   ;;
esac


# FIXME: This does not really belong here.
#        But cdist makes it real hard for us to do it elsewhere :(
if [ "${CDIST_OUTPUT_LOG_DIR-}" ]; then
   echo "Trying to preserve cdist output to $CDIST_OUTPUT_LOG_DIR"

   mkdir -p "$CDIST_OUTPUT_LOG_DIR"

   if [ $exit_code -eq 0 ]; then
      # cdist succeeded.
      mv ~/.cdist/cache/* "$CDIST_OUTPUT_LOG_DIR/" || true
   else
      # cdist failed.
      entry="$(ls -1 "$out_dir")"
      mv "$out_dir/$entry/data" "$CDIST_OUTPUT_LOG_DIR/$entry" || true
   fi
fi

exit $exit_code

