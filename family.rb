require_relative "memory"

class Person

  attr_reader   :name, :spawn, :parent
  attr_accessor :parent

  def initialize(name)
    @spawn = []
    @name = name
    @parent = nil
  end

  def breed(name)
    child = Person.new(name)
    child.parent = self
    @spawn.push(child)
  end

  def remove(person)
    @spawn -= [person]
  end
end

class Family

  attr_reader :head, :size

  def initialize(head)
    @head = Person.new(head)
    @size = 1
  end

  def add_at_parent(parent, child)
    lookup(parent).breed(child)
    @size += 1
  end

  def lookup(name)
    result = self.find do |element|
      element.name == name
    end
    return result
  end

  def find(&block)
    stack = [@head]
    while stack.length > 0
      current = stack.pop

      if block.call(current)
        return current
      end

      current.spawn.each do |s|
        stack.push(s)
      end
    end
  end

  def find_all(&block)
    results = []
    stack = [@head]
    while stack.length > 0
      current = stack.pop

      if block.call(current)
        results << current
      end

      current.spawn.each do |s|
        stack.push(s)
      end
    end
    return results
  end

  def ancestor(name, depth)
    ancestor = lookup(name)

    for i in 1..depth
      ancestor = ancestor.parent
    end

    return ancestor.name
  end

  def descendants(name, depth)
    descendants = lookup(name).spawn

    while depth > 1
      deeper = []
      descendants.each do |d|
        d.spawn.each do |s|
          deeper.push(s)
        end
      end

      descendants = deeper
      depth -= 1
    end

    return descendants.map{|t| t.name}
  end

  def number_of_descendants(name, depth)
    return descendants(name, depth).length
  end

  def only_children
    results = self.find_all do |t|
      t == @head or t.parent.spawn.length == 1
    end

    return results.map{|t| t.name}
  end

  def no_children
    results = self.find_all do |t|
      t.spawn.length == 0
    end

    return results.map{|t| t.name}
  end

  def most_successful(depth)

    max = 0
    best = nil

    self.find_all do |t|
      num = number_of_descendants(t.name, depth)
      if num > max
        max = num
        best = t.name
      end
    end

    return best
  end
end


tree = Family.new("Nancy")

tree.add_at_parent("Nancy", "Adam")
tree.add_at_parent("Nancy", "Jill")
tree.add_at_parent("Nancy", "Carl")
tree.add_at_parent("Jill", "Kevin")
tree.add_at_parent("Carl", "Catherine")
tree.add_at_parent("Carl", "Joseph")
tree.add_at_parent("Kevin", "Samuel")
tree.add_at_parent("Kevin", "George")
tree.add_at_parent("Kevin", "James")
tree.add_at_parent("Kevin", "Aaron")
tree.add_at_parent("George", "Patrick")
tree.add_at_parent("George", "Robert")
tree.add_at_parent("James", "Mary")

# Kevin's grandparent
puts tree.ancestor("Kevin", 2)

puts tree.only_children

puts tree.no_children

# most grandchildren
puts tree.most_successful(2)


# p Memory.analyze(tree)













