#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the pe_union function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("pe_union")).to eq("function_pe_union")
  end

  it "should raise a ParseError if there are fewer than 2 arguments" do
    expect { scope.function_pe_union([]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should join two arrays together" do
    result = scope.function_pe_union([["a","b","c"],["b","c","d"]])
    expect(result).to(eq(["a","b","c","d"]))
  end
end
