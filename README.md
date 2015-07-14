Enumerator::IO::Reader
=========================

Ever had a IO object you wanted to enumerate while not reading the whole stream into memory? no problems just use http://ruby-doc.org/core-2.2.2/IO.html#method-i-each_line and specify separator or any of it's siblings `#each_byte`, `#each_char` etc.

But what if the situation was the opposite, you had your enumerable, in this case a database response that was to big for your wallet to fit in memory and the interface required a IO object to read from.

http://www.rubydoc.info/gems/aws-sdk-euca/1.8.5/AWS/S3/Client:put_object

A simple case first

`gem install enumerator_io_reader`

```
require 'enumerator/io/reader'
range = "abc".."abz"
io = Enumerator::IO::Reader.new(range.to_enum)
io.read(20) # => "abcabdabeabfabgabhab"
io.read # => "iabjabkablabmabnaboabpabqabrabsabtabuabvabwabxabyabz"
io.eof? # => true

```

`#to_s` is called for every entry in the enumerable but pass a block to the constructor and you can serialize the object in a lazy manner after it has been yielded. The lazy mapping can of course be accomplished by something like `Enumerator::Lazy`.

```
require 'enumerator/io/reader'
require 'csv'

io = Enumerator::IO::Reader.new(Post.each.to_enum) do |post|
  post.attributes.values.to_csv
end

s3.put_object(
  bucket_name: 'foo',
  key: 'key',
  data: io)
```

If you use this gem alot through out your project you might consider the following monkey patches

```
module Enumerable
  def to_io(method = :each)
    Enumerator::IO::Reader.new(enum_for(method))
  end
end

range = "abc".."abz"
io = range.to_io
io.read(20) # => "abcabdabeabfabgabhab"
```

```
class Enumerator
  def to_io
    Enumerator::IO::Reader.new(self)
  end
end

enumerator = Enumerator.new do |y|
  y.yield(1)
  sleep 1
  y.yield(2)
end
enumerator.to_io.read # => "12"
```

(The MIT License)

Copyright (c) 2015 Erik Fonselius

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.