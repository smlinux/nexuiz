#!/usr/bin/ruby

require 'yaml'

def preprocess(s)
	return s.split(/\r?\n/).find_all() do |l| l[0, 2] != '//' end
end

base = ARGV[0]

mapstr = File.read("#{base}.map")
entstr = File.read("#{base}.ent")

# backup
File.open("#{base}.map~", "w") do |fh|
	fh.write(mapstr)
end
File.open("#{base}.ent~", "w") do |fh|
	fh.write(entstr)
end

def brushparse(l, index)
	brush = []
	nest = 0
	while index < l.length()
		case l[index]
			when '}'
				nest -= 1
				if nest < 0
					break
				else
					brush << '}'
				end
			when '{'
				nest += 1
				brush << '{'
			when %r{^(.*)$}
				brush << $1
			when ''
				true
			else
				raise SyntaxError, "in brush: " + l[index]
		end
		index += 1
	end
	return index, brush
end

def entparse(l, index)
	entity = {}
	brushes = []
	while index < l.length()
		case l[index]
			when '}'
				break
			when '{'
				index, brush = brushparse(l, index + 1)
				brushes << brush
			when %r{^"([^"]*)" "(.*)"$}
				entity[$1] = $2
			when ''
				true
			else
				raise SyntaxError, "in entity: " + l[index]
		end
		index += 1
	end
	if brushes != []
		entity[:brushes] = brushes
	end
	return index, entity
end

def mapparse(l)
	allents = []
	index = 0
	while index < l.length()
		case l[index]
			when '{'
				index, entity = entparse(l, index + 1)
				allents << entity
			when ''
				true
			else
				raise SyntaxError, "in map: " + l[index]
		end
		index += 1
	end
	return allents
end



def brushout(b)
	yield '{'
	b.each() do |l|
		yield l
	end
	yield '}'
end

def entout(e)
	yield '{'
	e.each() do |k, v|
		next if k == :brushes
		yield '"%s" "%s"' % [k, v]
	end
	if e[:brushes]
		e[:brushes].each() do |b|
			brushout(b) do |l|
				yield l
			end
		end
	end
	yield '}'
end

def mapout(entities)
	entities.each() do |e|
		entout(e) do |l|
			yield l
		end
	end
end

map = mapparse(preprocess(mapstr))
ent = mapparse(preprocess(entstr))

submodels = []
unchanged = []

map.each() do |e|
	case
		when e['classname'] == 'light'
			unchanged << e
		when e['classname'] == 'func_group'
			unchanged << e
		when e[:brushes]
			submodels << e[:brushes]
	end
end

ent.each() do |e|
	case
		when (e['classname'] == 'worldspawn') || (e['model'] && e['model'][0, 1] == '*')
			e.delete('model')
			e[:brushes] = submodels.shift()
	end
end

File.open("#{base}.map", "w") do |fh|
	mapout(ent + unchanged) do |l|
		fh.puts(l)
	end
end

File.unlink("#{base}.ent")
