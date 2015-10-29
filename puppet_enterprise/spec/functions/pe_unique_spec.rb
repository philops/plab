#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the pe_unique function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("pe_unique")).to eq("function_pe_unique")
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    expect { scope.function_pe_unique([]) }.to( raise_error(Puppet::ParseError))
  end

  it "should remove duplicate elements in a string" do
    result = scope.function_pe_unique(["aabbc"])
    expect(result).to(eq('abc'))
  end

  it "should remove duplicate elements in an array" do
    result = scope.function_pe_unique([["a","a","b","b","c"]])
    expect(result).to(eq(['a','b','c']))
  end
end
