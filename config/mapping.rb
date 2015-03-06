class Mapping

  attr_reader :priority, :assignee, :status

  def initialize
  end

  def priority
    {
      1 => "Low",
      2 => "Normal",
      3 => "High",
      4 => "Urgent",
      5 => "Inmediate"
    }
  end

  def assignee
    {
      2 => "littlemove"
    }
  end

  def status
    {
      1 => "open",
      5 => "closed"
    }
  end

  def default_label
    "Bug"
  end
end
