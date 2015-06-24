require 'spec_helper'

describe Ginatra::Logger do
  describe '#logger' do
    it 'returns logger instance' do
      expect(Ginatra::Logger.logger).to be_a(Logger)
    end
  end
end
