---
title: Taming Rails logs
published: true
---

Duderino duderone.


## Rails logs

### Short term solution

```
rake log:clear
# Truncates all/specified *.log files in log/ to zero bytes
# (specify which logs with LOGS=test,development)
```

### Short term alternatives

duderino

### Long term solution

`ActiveSupport::Logger` subclasses `Logger`
see https://github.com/rails/rails/blob/94b5cd3a20edadd6f6b8cf0bdf1a4d4919df86cb/activesupport/lib/active_support/logger.rb#L8

so we can refer to
https://ruby-doc.org/stdlib-2.6/libdoc/logger/rdoc/Logger.html#method-c-new

```
# config/environments/test.rb

config.logger = ActiveSupport::Logger.new(
  config.paths['log'].first, # log name
  1,                         # log shift_age
  64.megabytes               # log shift_size
)

config.logger = ActiveSupport::Logger.new(
  config.paths['log'].first, # log name
  'daily',                   # log shift_age
)

```

### Long term alternatives

wot wot

## Webpack builds








## Log rotation (MacOS)

# logfilename                           [owner:group]           mode count size when   flags [/pid_file] [sig_num]
/var/log/ftp.log                                                640  5     1000 *      J
/var/log/hwmond.log                                             640  5     1000 *      J
/var/log/ipfw.log                                               640  5     1000 *      J
/var/log/lpr.log                                                640  5     1000 *      J
/var/log/ppp.log                                                640  5     1000 *      J
/var/log/wtmp                                                   644  3     *    @01T05 B
/Users/paolobrasolin/lb/m40/log/*.log   paolobrasolin:staff     644  3     64   *      G     /Users/paolobrasolin/lb/m40/tmp/pids/server.pid

~


```
# logfilename                                               [owner:group]       mode count size when  flags [/pid_file] [sig_num]
/Users/your-username/path-your-rails-project/log/*.log      your-username:staff 644  4     *    $D0   GJ

# NOTES
#
#   Place file in /etc/newsyslog.d
#   '$D0' under 'when' tells newsyslog to rotate logs daily at midnight.
#   Alternatively you could use '24' for 'when', which would specify "every 24 hours"
#   '*' under 'size' specifies that logs should be rotated regardless of their size.
#   'G' under 'flags' tells newsyslog that the 'logfilename' is a pattern and it should rotate all log files matching the pattern.
#   'J' under 'flags' specifies that rotated logs should be compressed using bzip2.

```

Gotta use `newsyslog`. 
NOTE: requires root privileges.

1. configure it through `/etc/newsyslog.conf`
2. run it w/ `cron`

ABORT: Rails needs to be restarted to update the logfile handle.
An alternative is `copytruncate` but `newsyslog` doesn't have.
`logrotate` does, though.

UNLESS: `brew install logrotate`

```
==> Caveats
==> logrotate
To have launchd start logrotate now and restart at login:
  brew services start logrotate
Or, if you don't want/need a background service you can just run:
  logrotate
```


Seems to work: `logrotate logrotate.cfg`

```
/Users/paolobrasolin/lb/*/log/*.log {
    rotate 7
    daily
    dateext
    copytruncate
}
```


#
























# Taming Rails log


`rm ~/${COMPANY}/${PROJECT}/log/*.log`







