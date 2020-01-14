# frozen_string_literal: true

require 'rspec'

def undent(raw)
  if raw =~ /\A( +)/
    indent = Regexp.last_match(1)
    raw.gsub(/^#{indent}/, '').gsub(/ +$/, '')
  else
    raw
  end
end
