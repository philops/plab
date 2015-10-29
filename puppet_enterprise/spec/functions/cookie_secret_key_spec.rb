#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the cookie_secret_key function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("cookie_secret_key")).to eq("function_cookie_secret_key")
  end

  it "should return a 16 character string with no arguments specified" do
    result = scope.function_cookie_secret_key([])
    expect(result).to be_kind_of String
    expect(result.length).to eq 16
  end

  it "should return a string with the length specified" do
    result = scope.function_cookie_secret_key([32])
    expect(result.length).to eq 32
  end
end
