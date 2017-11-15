#
# The Contract module implements a expect! method, which allows to
# validate data against a set of expectations.
#
# Note that the Contract module should be included whenever you need
# to call <tt>expect!</tt> (or you just call Contract.expect! instead.)
#
# Example:
#
# class MyClass
#   include Contract
#
#   def foo(number)
#     expect! number => Fixnum
#     expect! number, &:odd?
#   end
#
#   def bar(user_attributes)
#     expect! user_attributes => {
#               first_name: /^[A-Z]./,
#               last_name: /^[A-Z]./,
#               age: 10..99,
#               gender: [ "male", "female" ],
#               email: /[^@]+@[^@]+/
#             }
#   end
# end

# rubocop:disable Style/StringLiterals
# rubocop:disable Style/SpaceAfterComma

module Contract
  def self.included(base)
    base.extend(self)
  end

  module_function

  def expect!(expectations, &block)
    if !expectations.is_a?(Hash) && !block
      raise ArgumentError, "expect! must be called with a Hash, or with a block"
    end

    if block
      result = block.call(expectations)
      I.fail! "#{expectations.inspect} did not meet dynamic expectation #{block}" unless result
    else
      expectations.each do |value, expectation|
        I.match! value, expectation
      end
    end
  end

  module I
    module_function

    def match?(value, expectation)
      # rubocop:disable  Style/CaseEquality
      return true if expectation === value

      case expectation
      when Array
        return expectation.any? { |e| match?(value, e) }
      when Hash
        return false unless value.is_a?(Hash)
        return expectation.all? { |k,v| match?(value[k], v) }
      when Regexp
        return false unless value.is_a?(String)
        return true if expectation.match(value)
      end

      false
    end

    def match!(value, expectation)
      return if match?(value, expectation)

      fail! "#{value.inspect} should match #{expectation.inspect}"
    end

    def fail!(message)
      raise ArgumentError, message
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  # rubocop:disable Style/ClassAndModuleChildren

  require 'test-unit'

  class Contract::TestCase < Test::Unit::TestCase
    def catching(&_)
      yield
      nil
    rescue => e
      e
    end

    include Contract

    def assert_expectation(expectation, &block)
      # test against Contract#expect!
      e = catching { expect!(expectation, &block) }
      assert_nil e, e && e.message

      # test against Contract.expect!
      e = catching { Contract.expect!(expectation, &block) }
      assert_nil e, e && e.message
    end

    def assert_expectation_fails(expectation, &block)
      # test against Contract#expect!
      e = catching { expect!(expectation, &block) }
      assert e, "expectation should have failed but didn't: #{expectation.inspect}"
      assert_kind_of(ArgumentError, e)

      # test against Contract.expect!
      e = catching { Contract.expect!(expectation, &block) }
      assert e, "expectation should have failed but didn't: #{expectation.inspect}"
      assert_kind_of(ArgumentError, e)
    end

    def test_types
      assert_expectation "Bar" => [ String, Fixnum ]
    end

    def test_block
      assert_expectation 1, &:odd?
      assert_expectation_fails 2, &:odd?

      assert_expectation 1 do |i| i < 3 end
      assert_expectation_fails 1 do |i| i > 3 end
    end

    def test_hash
      data = { foo: "Bar" }

      assert_expectation data => { foo: String }
      assert_expectation_fails data => { foo: Fixnum }
      assert_expectation data => { foo: [ String, Fixnum ] }
    end

    def test_boolean
      assert_expectation true => true
      assert_expectation_fails false => true
      assert_expectation_fails true => false
      assert_expectation_fails true => 1
    end

    def test_integer
      assert_expectation 1 => Fixnum
      assert_expectation_fails "1" => Fixnum
      assert_expectation_fails 1 => String
      assert_expectation 1 => 0..2
      assert_expectation_fails 3 => 0..2
      assert_expectation 1 => [0,1,2]
      assert_expectation_fails 3 => [0,1,2]

      assert_expectation_fails 1 => /1/
      assert_expectation_fails 1 => /2/
    end

    def test_string
      assert_expectation "1" => String
      assert_expectation_fails 1 => String
      assert_expectation_fails "1" => Fixnum
      assert_expectation_fails "1" => 0..2
      assert_expectation_fails "3" => 0..2
      assert_expectation "1" => ["0","1","2"]
      assert_expectation_fails "-1" => ["0","1","2"]

      assert_expectation "1" => /1/
      assert_expectation_fails "1" => /2/
    end
  end
end
