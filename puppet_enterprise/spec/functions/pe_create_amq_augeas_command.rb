#! /usr/bin/env ruby -S rspec
require 'spec_helper'

describe "the pe_create_amq_augeas_command function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("pe_create_amq_augeas_command")).to eq("function_pe_create_amq_augeas_command")
  end

  it "should raise a ParseError if there are fewer than 4 arguments" do
    expect { scope.function_pe_create_amq_augeas_command(['1','2','3']) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError if the first argument is not a string" do
    expect { scope.function_pe_create_amq_augeas_command([1,'2','3','4']) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError if the second argument is not an array" do
    expect { scope.function_pe_create_amq_augeas_command(['1','2','3',['4']]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError if the third argument is not a string" do
    expect { scope.function_pe_create_amq_augeas_command(['1',['2'],3,['4']]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError if the fourth argument is not an array" do
    expect { scope.function_pe_create_amq_augeas_command(['1',['2'],'3','4']) }.to( raise_error(Puppet::ParseError) )
  end

  it "should raise a ParseError if the second and fourth argument are not the same size array" do
    expect { scope.function_pe_create_amq_augeas_command(['1',['2'],'3',['4', '5']]) }.to( raise_error(Puppet::ParseError) )
  end

  it "should create an array of augeas commands without selectors" do
    context = 'fakeContext/element'
    attribute = 'name'
    values = ['foo', 'bar']
    result = scope.function_pe_create_amq_augeas_command([context, nil, attribute, values])
    expect(result).to(eq([
      'set fakeContext/element/#attribute/name foo',
      'set fakeContext/element/#attribute/name bar'
    ]))
  end

  it "should create an array of augeas commands with selectors" do
    context = 'fakeContext/element'
    selectors = ['#attribute/name=foo', '#attribute/name=bar']
    attribute = 'name'
    values = ['foo', 'bar']
    result = scope.function_pe_create_amq_augeas_command([context, selectors, attribute, values])
    expect(result).to(eq([
      'set fakeContext/element[#attribute/name=foo]/#attribute/name foo',
      'set fakeContext/element[#attribute/name=bar]/#attribute/name bar'
    ]))
  end
end
