#!/bin/sh

release_ctl eval --mfa "ChainsparkApi.ReleaseTasks.migrate/1" --argv -- "$@"
