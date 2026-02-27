require 'rails_helper'

RSpec.describe CurrencyHelper, type: :helper do
  describe '#valid_amount?' do
    it 'retorna true para montos válidos positivos' do
      expect(helper.valid_amount?(100)).to be true
      expect(helper.valid_amount?(0.01)).to be true
      expect(helper.valid_amount?('100.50')).to be true
    end

    it 'retorna false para montos nulos, cero o negativos' do
      expect(helper.valid_amount?(nil)).to be false
      expect(helper.valid_amount?(0)).to be false
      expect(helper.valid_amount?(-10)).to be false
    end

    it 'retorna false para valores inválidos' do
      expect(helper.valid_amount?('invalid')).to be false
    end
  end

  describe '#to_decimal' do
    it 'convierte strings a BigDecimal' do
      expect(helper.to_decimal('100.50')).to eq(BigDecimal('100.50'))
    end

    it 'convierte floats a BigDecimal' do
      expect(helper.to_decimal(100.5)).to eq(BigDecimal('100.5'))
    end

    it 'retorna 0 para valores nulos o inválidos' do
      expect(helper.to_decimal(nil)).to eq(BigDecimal('0'))
      expect(helper.to_decimal('invalid')).to eq(BigDecimal('0'))
    end

    it 'retorna el mismo BigDecimal si ya lo es' do
      decimal = BigDecimal('100')
      expect(helper.to_decimal(decimal)).to eq(decimal)
    end
  end
end
