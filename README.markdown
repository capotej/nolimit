# no limit cache

![logo](http://upload.wikimedia.org/wikipedia/en/2/23/Nolimit.jpg)

###a disk backed, k/v cache accessible via http (webmachine/bitcask)

##rationale
The two main k/v caches (memcache and redis) require that you keep the
entire working set in memory. Bitcask only requires the keys be in
memory, making it perfect for a persistent cache of large datasets.


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

* Setting a key
     - ```→ curl -X POST http://localhost:8000/ -d "foo=bar"```

     - ```← [200] ok```

* Getting a key
     - ```→ curl http://localhost:8000/?key=foo```

     - ```← [200] bar```

* Delete a key
     - ```→ curl -X DELETE http://localhost:8000/?key=foo```

     - ```← [204]```


* Multi Get (executed concurrently on the server)
     - ```→ curl http://localhost:8000/?keys=foo1,foo2```

     - ```← [200] { "foo1": "bar1", "foo2": "bar2" }```

* TTL Support (expires on next read after expire time)
     - ```→ curl -X POST http://localhost:8000/ -d "foo=bar" -d "ttl=300"```

     - ```← [200] ok```

* Missing keys

     - ```→ curl http://localhost:8000/?key=missing_or_expired_key```

     - ```← [404] not found```

##testing (only uses system ruby and curl command)
```
$ ./start.sh
$ ruby misc/test.rb
```

##todo

* figure out when to merge
* give the bitcask writer its own supervisor

##license
Copyright (C) 2011 by Julio Capote

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

