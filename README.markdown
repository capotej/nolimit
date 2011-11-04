# no limit cache

![logo](http://upload.wikimedia.org/wikipedia/en/2/23/Nolimit.jpg)


###a disk backed k/v cache accessible via http (webmachine/bitcask)

##dependencies
* erlang, at least 13B04

##installation
```
$ git clone git://github.com:capotej/nolimit.git
$ cd nolimit
$ make
$ ./start.sh
```

##usage

* Setting keys
     - ```curl -X POST http://localhost:8000/ -d "foo=bar"```

* Getting keys
     - ```curl http://localhost:8000/?key=foo```

##testing/benchmarks (just needs ruby and curl)

```
$ ./start.sh
$ ruby misc/readwrite.rb
```


##todo

* figure out when to merge
* use otp to monitor the bitcask writer
* delete keys

