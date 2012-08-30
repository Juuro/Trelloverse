class Webpage
  def initialize( title )
    @title = title

    @cards = [ ]
  end

  def add_card( card )
    @cards << card
  end

  # Support templating of member data.
  def get_binding
    binding
  end
end