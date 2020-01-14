# frozen_string_literal: true

require 'representative/base'
require 'active_support/core_ext/array/extract_options'

module Representative
  class AbstractXml < Base
    def initialize(subject = nil, options = {})
      options = options.merge!(naming_strategy: :dasherize) unless options.key?(:naming_strategy)
      super(subject, options)
    end

    # Generate an element.
    #
    # With two arguments, it generates an element with the specified text content.
    #
    #   r.element :size, 42
    #   # => <size>42</size>
    #
    # More commonly, though, the second argument is omitted, in which case the
    # element content is assumed to be the named property of the current #subject.
    #
    #   r.representing my_shoe do
    #     r.element :size
    #   end
    #   # => <size>9</size>
    #
    # If a block is attached, nested elements can be generated.  The element "value"
    # (whether explicitly provided, or derived from the current subject) becomes the
    # subject during evaluation of the block.
    #
    #   r.element :book, book do
    #     r.title
    #     r.author
    #   end
    #   # => <book><title>Whatever</title><author>Whoever</author></book>
    #
    # Providing a final Hash argument specifies element attributes.
    #
    #   r.element :size, :type => "integer"
    #   # => <size type="integer">9</size>
    #
    def element(name, *args, &block)
      metadata = @inspector.get_metadata(current_subject, name)
      attributes = args.extract_options!.merge(metadata)

      subject_of_element = if args.empty?
                             @inspector.get_value(current_subject, name)
                           else
                             args.shift
      end

      raise ArgumentError, 'too many arguments' unless args.empty?

      representing(subject_of_element) do
        resolved_attributes = resolve_attributes(attributes)
        content_string = content_block = nil

        unless current_subject.nil?
          if block
            content_block = proc { block.call(current_subject) } unless block == Representative::EMPTY
          else
            content_string = current_subject.to_s
          end
        end

        generate_element(format_name(name), resolved_attributes, content_string, &content_block)
      end
    end

    # Generate a list of elements from Enumerable data.
    #
    #   r.list_of :books, my_books do
    #     r.element :title
    #   end
    #   # => <books type="array">
    #   #      <book><title>Sailing for old dogs</title></book>
    #   #      <book><title>On the horizon</title></book>
    #   #      <book><title>The Little Blue Book of VHS Programming</title></book>
    #   #    </books>
    #
    # Like #element, the value can be explicit, but is more commonly extracted
    # by name from the current #subject.
    #
    def list_of(name, *args, &block)
      options = args.extract_options!
      list_subject = args.empty? ? name : args.shift
      raise ArgumentError, 'too many arguments' unless args.empty?

      list_attributes = options[:list_attributes] || {}
      item_name = options[:item_name] || name.to_s.singularize
      item_attributes = options[:item_attributes] || {}

      items = resolve_value(list_subject)
      element(name, items, list_attributes.merge(type: proc { 'array' })) do
        items.each do |item|
          element(item_name, item, item_attributes, &block)
        end
      end
    end

    # Return a magic value that, when passed to #element as a block, forces
    # generation of an empty element.
    #
    #   r.element(:link, :rel => "me", :href => "http://dogbiscuit.org", &r.empty)
    #   # => <link rel="parent" href="http://dogbiscuit.org"/>
    #
    def empty
      Representative::EMPTY
    end

    private

    def resolve_attributes(attributes)
      attributes&.each_with_object({}) do |(name, value_generator), resolved|
        resolved_value = resolve_value(value_generator)
        resolved[format_name(name)] = resolved_value unless resolved_value.nil?
      end
    end
  end
end
