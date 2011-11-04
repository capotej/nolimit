# no limit cache

![logo](http://upload.wikimedia.org/wikipedia/en/2/23/Nolimit.jpg)


###a disk backed k/v cache accessible via http (webmachine/bitcask)

##dependencies
* erlang, at least 13B04

##installation

1. ```git clone git://github.com:capotej/nolimit.git```

1. ```cd nolimit```

1. ```make```

1. ```./start.sh```

##usage

* Setting keys
     - ```curl -X POST http://localhost:8000/ -d "foo=bar"```

* Getting keys
     - ```curl http://localhost:8000/?key=foo```

##testing/benchmarks

1. ```./start.sh```

1. ```ruby misc/readwrite.rb```


##todo

* figure out when to merge
* use otp to monitor the bitcask writer
* delete keys

