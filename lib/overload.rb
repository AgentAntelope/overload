require "overload/version"
require "overload/monkeypatching/hash.rb"

module Overload

  attr_accessor :kept_methods

  def overload(*methods)
    @kept_methods ||= {}
    methods.each do |method|
      kept_methods[method] = {}
    end
  end

  def method_added(new_method)
    if @evil_things
      # Maybe next time.
      @evil_things = false
      return
    end

    # To allow inheriting of overloaded methods
    if kept_methods.nil?
      self.ancestors.each_with_index do |ancestor, index|
        if ancestor.respond_to?(:kept_methods) && ancestor.kept_methods
          # To prevent changing overloaded methods on the parent, we must dup
          self.kept_methods = self.ancestors[index].kept_methods.deep_dup
        end
      end
    end

    return unless kept_methods[new_method]

    new_method_object = new.method(new_method)

    if method_defined?(new_method)
      kept_methods[new_method][new_method_object.arity] = new_method_object
      instance_variable_set(:@kept_methods, kept_methods)

      overload_method = Proc.new do |*args|
        kept_methods = self.class.instance_variable_get(:@kept_methods)
        if kept_methods[__method__][args.count]
          kept_methods[__method__][args.count].call(*args)
        else
          kept_methods[__method__].keys.sort.each do |arity|
            next unless arity < 0 && arity.abs - 1 <= args.count
            return kept_methods[__method__][arity].call(*args)
          end
        end
      end

      # This was fun, but once was quite enough.
      @evil_things = true

      define_method new_method, overload_method

    end
  end
end
