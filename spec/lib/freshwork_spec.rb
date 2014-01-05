require 'spec_helper'

module ActiveScraper
  describe ActiveScraper::Freshwork do

    it 'should respond to :get' do
      expect(ActiveScraper).to respond_to(:get)
    end

    it 'should respond to :post' do
      expect(ActiveScraper).to respond_to(:post)
    end
  end


  describe 'get'
  describe 'post'
end