require 'spec_helper'

module ActiveScraper
  describe Response do

    describe 'building' do
      context 'given a regular HTTParty-like object' do
        it 'should save content_type'
        it 'should save body'
        it 'should save headers as a serialized Hash'
      end
    end

    context 'attributes' do 
      describe ':checksum' do
        it 'should set checksum after save'
      end

      describe ':headers' do
        it 'should be a serialized hash'
      end
    end
  end
end
