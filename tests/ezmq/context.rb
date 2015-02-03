context 'Contexts' do
  setup do
    @context = EZMQ::Context.new
  end

  should 'instantiate properly' do
    assert_kind_of EZMQ::Context, @context
  end
end
