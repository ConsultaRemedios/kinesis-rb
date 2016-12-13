[![Build Status](https://semaphoreci.com/api/v1/projects/6449b778-9dd2-49c8-a12a-18e14b3d91a1/1094949/shields_badge.svg)](https://semaphoreci.com/consultaremedios/kinesis-rb)
[![Code Climate](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/badges/c1b9c8f8ea3358daebf0/gpa.svg)](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/feed)
[![Test Coverage](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/badges/c1b9c8f8ea3358daebf0/coverage.svg)](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/coverage)
[![Issue Count](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/badges/c1b9c8f8ea3358daebf0/issue_count.svg)](https://codeclimate.com/repos/584ff2ceb0a5853f8a004266/feed)

# Kinesis

Kinesis is a wrapper for [the official AWS SDK client](https://github.com/aws/aws-sdk-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kinesis'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kinesis

## Usage

### Producer

The producer streaming a single event by api call.

```ruby
producer = Kinesis.build_producer('my_stream')

event = 'event to be streamed'

producer.produce(event)
```

It's possible to send a collection of events using a single api call, using the `multi_produce`.

```ruby
producer = Kinesis.build_producer('my_stream')

events = [
  'some event',
  'another event'
]

producer.multi_produce(events)
```

### Consumer

The consumer fetches all shards from the stream and loops over each shard fetching events
calling the block for every iteration.

After each shard loop a checkpoint is saved using the last sequence number read from Kinesis record.
The checkpoint storage by default is in memory, using the `Kinesis::Storage::Memory` instance, but
it can be stored on Redis, using the `Kinesis::Storage::Redis` instance, for a persistent checkpoint when the process is restarted.


```ruby
consumer = Kinesis.build_consumer('my_stream')

while true do
  consumer.consume do |shard, events|
    do_something(events)
  end
end
```

By default the consumer fetches `1000` events each time, but you can set a different limit size.

```ruby
redis = Redis.new
storage = Kinesis::Storage::Redis.new(redis)
consumer = Kinesis.build_consumer('my_stream', storage: storage)

while true do
  consumer.consume(100) do |shard, records|
    do_something(records)
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ConsultaRemedios/kinesis.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

