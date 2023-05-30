## 3.0.5
  - Prevent `password` leakage in the debug logs [#10](https://github.com/logstash-plugins/logstash-output-jira/pull/10)

## 3.0.4
  - Docs: Set the default_codec doc attribute.

## 3.0.3
  - Fix some documentation issues

## 3.0.1
  - Docs: Fix doc generation issue by adding example formatting
  
## 3.0.0
  - update plugin to the new api
  - update travis.yml
  - remove the bogus test

## 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

