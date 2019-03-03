#!/bin/sh

release_ctl eval --mfa "ChainsparkApi.ReleaseTasks.seed/1" --argv -- "$@"
