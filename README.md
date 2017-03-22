# fluent-plugin-remote_syslog-5424

[Fluentd](http://fluentd.org) plugin for output to remote syslog serivce (e.g. [Papertrail](http://papertrailapp.com/))

## Installation

```bash
 fluent-gem install fluent-plugin-remote_syslog-5424
```

## Usage

```
<match foo>
  type remote_syslog-5424
  host example.com
  port 514
  severity debug
  tag ${tag}
  parse_tag true
</match>
```

If `parse_tag` is `true` then tag is expected to be in form `severity.facility.program` where severity and facility values can be found in `common.rb`. In this case severity and facility values set in match section are ignored and replaced with values from parsed tag.

This plugin is based on [fluent-plugin-remote_syslog](https://github.com/dlackty/fluent-plugin-remote_syslog) by Richard Lee. It has components taken from [remote_syslog_logger] (https://github.com/papertrail/remote_syslog_logger) and [syslog_protocol](https://github.com/eric/syslog_protocol) gems.

This plugin makes use of [Fluent::Mixin::PlainTextFormatter](https://github.com/tagomoris/fluent-mixin-plaintextformatter) and [Fluent::Mixin::RewriteTagName](https://github.com/y-ken/fluent-mixin-rewrite-tag-name), please check out their documentations for more configuration options.

## License

Copyright (c) 2014-2015 Richard Lee. See LICENSE for details.
Copyright (c) 2017 Sergei Utinski. See LICENSE for details.
