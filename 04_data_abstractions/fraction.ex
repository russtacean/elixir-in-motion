defmodule Fraction do
  defstruct numerator: nil, denominator: nil

  def new(numerator, denominator) do
    %Fraction{numerator: numerator, denominator: denominator}
  end

  def value(fraction) do
    fraction.numerator / fraction.denominator
  end

  def add(
        %Fraction{numerator: num1, denominator: denom1},
        %Fraction{numerator: num2, denominator: denom2}
      ) do
    new(num1 * denom2 + num2 * denom1, denom1 * denom2)
  end
end
