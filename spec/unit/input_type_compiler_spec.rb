require 'dry/validation/input_type_compiler'

RSpec.describe Dry::Validation::InputTypeCompiler, '#call' do
  subject(:compiler) { Dry::Validation::InputTypeCompiler.new }

  let(:rule_ast) do
    [
      [
        :and, [
          [:key, [:email, [:predicate, [:key?, [:email]]]]],
          [
            :and, [
              [:val, [:email, [:predicate, [:str?, []]]]],
              [:val, [:email, [:predicate, [:filled?, []]]]]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:age, [:predicate, [:key?, [:age]]]]],
          [
            :or, [
              [:val, [:age, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:val, [:age, [:predicate, [:int?, []]]]],
                  [:val, [:age, [:predicate, [:filled?, []]]]]
                ]
              ]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:address, [:predicate, [:key?, [:address]]]]],
          [:val, [:address, [:predicate, [:str?, []]]]]
        ]
      ]
    ].map(&:to_ary)
  end

  let(:params) do
    { 'email' => 'jane@doe.org', 'age' => '20', 'address' => 'City, Street 1/2' }
  end

  it 'builds an input dry-data type' do
    input_type = compiler.(rule_ast)

    result = input_type[params]

    expect(result).to include('email' => 'jane@doe.org', 'address' => 'City, Street 1/2')
    expect(result['age'].value).to be(20)
  end
end