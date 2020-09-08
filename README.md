# What is this?

This tools is clean up duplicated files from dropbox.
If duplicated files exist in same directory, remove Keep the oldest file and remove others.

# How to use?

## Setup token

Please copy .env.example to .env.
And add token as below.

```conf
TOKEN=AAAABBBBCCCC
```

## How to run

Run this batch with dropbox directory

```bash
ruby clean_drop_dup.rb /target_path
```
