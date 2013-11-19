class TestClass
  require "overload"
  extend Overload

  overload :foo, :bar

  def foo
    "overwritten"
  end

  def foo
    0
  end

  def foo(arg)
    1
  end

  def foo(arg1, arg2)
    2
  end

  def foo(*args)
    "some"
  end

  def foo(arg1, arg2, *args)
    "more"
  end

  def bar
    "bar"
  end

  def bar(arg1)
    "bar 1"
  end

  def baz(arg1)
    "bax"
  end

  def baz
    "baz"
  end
end

class TestClassChild < TestClass
  def foo(arg1, arg2, arg3, *args)
    "TestClassChild foo"
  end

  overload :bam

  def bam(*args)
    "bam"
  end

  def bam(arg1, arg2, arg3, *args)
    "bam with required args"
  end
end

describe TestClass do
  it "returns 0 when called with 0 arguments" do
    expect(subject.foo).to eq(0)
  end

  it "returns 1 when called with 1 argument" do
    expect(subject.foo(1)).to eq(1)
  end

  it "returns 2 when called with 2 arguments" do
    expect(subject.foo(1, 2)).to eq(2)
  end

  it "calls the method with the greatest negative arity when ambiguous" do
    # this also confirms that child methods don't overwrite parent methods.
    expect(subject.foo(1, 2, 3, 4, 5)).to eq("more")
  end

  it "can overload multiple methods" do
    expect(subject.bar).to eq("bar")
    expect(subject.bar(1)).to eq("bar 1")
  end

  it "won't overload non-declared methods" do
    expect(subject.baz).to eq("baz")
    expect { subject.baz(1) }.to raise_error(ArgumentError)
  end
end

describe TestClassChild do
  it "functions in child classes" do
    expect(subject.foo(1, 2)).to eq(2)
    expect(subject.foo(1, 2, 3)).to eq("TestClassChild foo")
  end

  it "will not select methods with too large negative arity" do
    expect(subject.bam(1,2)).to eq("bam")
  end
end
